#include "SSCalculator.h"
#include "fem_exception.h"
#include <math.h>
SSCalculator::SSCalculator(ITimeSeriesProvider *timeSeriesProvider)
{
	nra = timeSeriesProvider->get("nra");
	cola = timeSeriesProvider->get("cola");
	nwi = timeSeriesProvider->get("nwi");
	drc = timeSeriesProvider->get("drc");
	eadisreg1 = timeSeriesProvider->get("eadisreg1");
	eadisreg2 = timeSeriesProvider->get("eadisreg2");
}


SSCalculator::~SSCalculator() {
}

double SSCalculator::SSBenefit(Person* person, const int cyr, const int rclyr) {

	// Social Security Benefit Function for United States
	// Benefits are computed as if claimed on 6/1/Claim Year and received through 6/1/(Claim Year+1)

	// Computes all three benefit types: retirement, spousal, and widow
	// Prefixes indicate what what benefit a variable applies to: (r)etirement, (s)pouses, (w)idow

	// Year and month born
  const int rbyr = (int) person->get(Vars::rbyr);
  const int rbmonth = (int) person->get(Vars::rbmonth);

	// Age in months and yrs at claiming
	const int rage_months = (rclyr - rbyr)*12 + (6-rbmonth);
	const int rage_yrs = rage_months/12;
	
	// Normal retirement age in months and years, based on birth year
	const int nra_months = (int) nra->Value(rbyr);
	const int nra_yrs = nra_months/12;
	
	// Compute benefit amounts based on the age at the claiming year

	/*** Compute Retirement Benefits ***/
	double rben = RetBenefit(person, cyr, rclyr);
	// Apply the COLA adjustment, which is given by the change in the COLA series from age 62 to the current year
	rben	*= cola->Value(cyr-1) / cola->Value(rbyr+62-1);
	

	/*** Compute Benefits as Spouse ***/

	double sben = 0.0;
	
	// Determine eligibility for spousal retirement benefits
	// First, must be married
	if(person->test(Vars::married)) {

		// Get the Spouse
		const Person* spouse = person->getSpouse();

		// Spouse's year and month of birth
		const int sbyr = (int) spouse->get(Vars::rbyr);
		const int sbmonth = (int) spouse->get(Vars::rbmonth);

		// Spouse's age in yrs at claiming
		const int sage_yrs = (int) (((rclyr - sbyr)*12 + (6-sbmonth) )/12.0);

		// Determine eligibility for spousal benefits
		// Number of quarters of coverage required
		const int sq_min = (int) (spouse->get(Vars::rbyr) < 1929 ? 40 - (1929-spouse->get(Vars::rbyr)) : 40);
		// Spouse must have enough quarters of coverage, and be over age 62 since the spouse must file for benefits, and self must be over 62
		const bool selig = spouse->get(Vars::rq) >= sq_min && sage_yrs >= 62 && rage_yrs >= 62;

		if(selig) {

			// Compute the spouse's PIA. The spouse is alive of course
			const double spia = SsPIA(spouse->get(Vars::raime), spouse->get(Vars::rq), sbyr+62);

			// Determine actuarial reduction factor (arf) if retiring before NRA 
			/* Compute basic reduction formulas:
				- Wife's and husband's insurance benefits are reduced by 25/36 of one percent (or 0.0069) for each month of entitlement before FRA;
				- Retirement insurance benefits and spouse's benefits are reduced by 5/12 of one percent (or 0.0042) for each month of reduction in excess
				of 36 months. This applies to individuals whose full retirement age is after age 65. (See §723.)
			*/
			const double sarf = 1.0 - (std::max(0.0,(std::min(nra_months-rage_months,36))*25.0/36.0+std::max(0.0,nra_months-rage_months-36.0)*5.0/12.0))/100.0;
		
			// There is no delayed retirement credit (drc) for spousal benefits
			// Compute the benefit amount as 50% of the product of the spouse's PIA, and the reduction factor
			sben = spia*sarf*0.5;
		}
	}
	// Apply the COLA adjustment, which is given by the change in the COLA series from age 62 to the current year
	sben	*= cola->Value(cyr-1) / cola->Value(rbyr+62-1);

	/*** Compute Benefits as a Widow(er) ***/
	double wben = 0.0;

	// Determine eligibility for survivor retirement benefits
	// First, must be widowed
	if(person->test(Vars::widowed)) {

		// Do we know this person's spouse?
		if(person->getSpouse() != NULL) {
			// Get the dead spouse
			const Person* spouse = person->getSpouse();

			// Spouse's year and month of birth
			const int sbyr = (int) spouse->get(Vars::rbyr);
			const int sbmonth = (int) spouse->get(Vars::rbmonth);

			
			// Determine eligibility for widow benefits
			// Number of quarters of coverage required
			const int sq_min = (int) (spouse->get(Vars::rbyr) < 1929 ? 40 - (1929-spouse->get(Vars::rbyr)) : 40);
			// Spouse must have had enough quarters of coverage, and self must be over 60
			const bool welig = spouse->get(Vars::rq) >= sq_min && rage_yrs >= 60;

			if(welig) {
				
				// Did the dead spouse already claim benefits? 
				double spouse_retben = 0.0;
				if(spouse->get(Vars::ssclaim)) {
					// If so, then obtain the benefit amount the dead spouse would have gotten, had they been alive, 
					// including any arf and drc
				  spouse_retben = RetBenefit(spouse, cyr, (int) spouse->get(Vars::rssclyr));
				  wben = spouse_retben;
				} else {
					// Otherwise, was the spouse above the normal retirement age when they died?
				
					// Spouse's Age in months when the spouse died
				  const int sage_months = (int) (spouse->get(Vars::year) - sbyr)*12 + (6-sbmonth);
		
					// Dead spouse's normal retirement age in months and years, based on birth year
				  const int snra_months = (int) nra->Value(sbyr);

					if(sage_months > snra_months) {
						// The spouse died after NRA but without claiming benefits. 
						// What benefit would the dead spouse be entitled to if they claimed in the year of their death?
					  spouse_retben = RetBenefit(spouse, cyr, (int) spouse->get(Vars::year));
					} else {
						// The benefit entitled to the widow(er) is then just the amount the spouse would have
						// gotten if they calimed at their NRA, so just their PIA calculated 
					  spouse_retben = SsPIA(spouse->get(Vars::raime), spouse->get(Vars::rq), (int) spouse->get(Vars::year));

						// Apply the COLA
					  spouse_retben *= cola->Value(cyr-1) / cola->Value((int) spouse->get(Vars::year)-1);

						// Was the spouse less than 62 when died and the widow less than 60 when widowed?
						double windex_ben = 0.0;
						if(sage_months < 62*12 && spouse->get(Vars::year)-rbyr < 60) {
							// Yes, attempt to apply the 1983 widow reindexing
							const int windex_elig_yr = std::min(rbyr+60, sbyr+62);
							
							windex_ben = SsPIA(spouse->get(Vars::raime)*nwi->Value(windex_elig_yr-2)/nwi->Value((int) spouse->get(Vars::year)-2) ,
													  spouse->get(Vars::rq), windex_elig_yr);
							
							// Apply COLA
							windex_ben *= cola->Value(cyr-1) / cola->Value(windex_elig_yr-1);
						}

						// Take the largest one
						wben = std::max(windex_ben,  spouse_retben);
					}
				}

				// Determine actuarial reduction factor (arf) if retiring before NRA 
				/* Compute basic reduction formulas:
					- Widow(er)'s insurance benefits are reduced for each month of entitlement between ages 60 and FRA. The amount of the reduction for each 
					month is derived from dividing 28.5 percent by the number of possible months of early retirement. A person whose FRA is age 65 could be 
					entitled up to 60 months before FRA. Each month is therefore 28.5 percent divided by 60 (or 0.00475). A person whose FRA is age 66 could 
					be entitled up to 72 months before FRA. Each month is therefore 28.5 percent divided by 72 (or 0.00396). 
				*/
				const double warf = 1.0 - (.285/(nra_months-60*12))*std::max(0,nra_months-rage_months); // Reduction factor for wifow benefits
			
				// Compute the benefit amount
				wben *= warf; 
			} 
		} else {
			// Don't know the spouse. Use the cross-sectional regression model to estimate the benefits.
			wben = isret_wd_model->estimate(person) /12.0;
		}
	}
	
	// Compute the benefit amount as the maximum of all possible benefits
	double ben = std::max(std::max(rben, sben), wben);

	// If there are any benefits, apply adjustments
	if(ben > 0.0) {
	
		// If there are earnings, apply the earnings test
		if(person->get(Vars::ry_earn) > 0.0) {
			double earn_limit;  // Earnings limit before deductions
			double deduct_frac; // Fraction to deduct above the limit

			// If you are under full retirement age for the entire year, 
			// deduct $1 from your benefit payments for every $2 you earn above the annual limit.
			if(cyr - rbyr < nra_yrs) {
				earn_limit  =  eadisreg1->Value(cyr);
				deduct_frac = 1.0/2.0;
			}
			// If you are at or above the full retirement age for any or all of the year
			// deduct $1 from your benefit payments for every $3 you earn above the annual limit.
			else if (cyr - rbyr == nra_yrs) {
				earn_limit  =  eadisreg2->Value(cyr);
				deduct_frac = 1.0/3.0;
			} else {
				earn_limit  =  eadisreg2->Value(cyr);
				deduct_frac = 0.0;
			}

			// Calculate the amount to deduct
			const double deduct_amt = deduct_frac * std::max(person->get(Vars::ry_earn)- earn_limit, 0.0);

			// Apply the deduction 
			ben = std::max(0.0, ben - deduct_amt/12.0);
		}
	}
	// Return the benefit amount
	return ben;
}

double SSCalculator::RetBenefit(const Person* person, const int cyr, const int rclyr) {

	// Social Security Benefit Function for United States
	// Benefits are computed as if claimed on 6/1/Claim Year and received through 6/1/(Claim Year+1)

	// Year and month born
  const int rbyr = (int) person->get(Vars::rbyr);
  const int rbmonth = (int) person->get(Vars::rbmonth);

	// Age in months and yrs at claiming
	const int rage_months = (rclyr - rbyr)*12 + (6-rbmonth);
	const int rage_yrs = rage_months/12;
	
	// Normal retirement age in months and years, based on birth year
	const int nra_months = (int) nra->Value(rbyr);


	// Compute benefit amount based on the age at the claiming year

	/*** Compute Retirement Benefits ***/
	double rben = 0.0;

	// Determine eligibility for retirement benefits
	// Number of quarters of coverage required
	const int rq_min = (rbyr < 1929 ? 40 - (1929-rbyr) : 40);
	// Must have enough quarters of coverage, and be at least 62, and either be claiming or be dead (for calculating widow's benefits)
	const bool relig = person->get(Vars::rq) >= rq_min && rage_yrs >= 62 && (person->get(Vars::ssclaim) || person->get(Vars::died));
	if(relig) {

		// Compute self PIA, assuming the retiree is alive, since this function would never be called for a dead retiree
		const double rpia = SsPIA(person->get(Vars::raime), person->get(Vars::rq), rbyr+62);

		// Determine actuarial reduction factor (arf) if retiring before NRA 
		/* Compute basic reduction formulas:
			- A retirement insurance benefit is reduced by 5/9 of one percent (or 0.0056) for each month of entitlement before FRA;
			- Retirement insurance benefits and spouse's benefits are reduced by 5/12 of one percent (or 0.0042) for each month of reduction in excess
			of 36 months. This applies to individuals whose full retirement age is after age 65. (See §723.)
		*/
		const double rarf = 1.0 - (std::max(0.0,(std::min(nra_months-rage_months,36))*5.0/9.0+std::max(0,nra_months-rage_months-36)*5.0/12.0))/100.0;
		
		// Determine delayed retirement credit (drc) based on birth year
		// First, compute the number of delayed months. 
		const int delay_months = std::max(std::min(rage_months,70*12) - nra_months, 0);
		// Now compute the drc		
		const double rdrc = 1.0 + (double)delay_months * drc->Value(rbyr)/12.0; // drc time series is per year
	
		// Compute the retiree benefit amount
		rben = rpia*rdrc*rarf; // At least on of (rdrc, rarf) will be equal to 1.0
	}

	return rben;
}



void SSCalculator::test() {

	Person p;
	p.set(Vars::married, false);
	p.set(Vars::widowed, false);
	p.set(Vars::ry_earn, 0.0);
	p.set(Vars::rq, 400);

	std::vector<double> benRet;
	std::vector<double> ben2010;


	p.set(Vars::rbmonth, 5);
	p.set(Vars::rbyr, 1925); 	p.set(Vars::raime, 2205); 	benRet.push_back(SSBenefit(&p, 1987,1987)); 	ben2010.push_back(SSBenefit(&p, 2010,1987)); 
	p.set(Vars::rbyr, 1926); 	p.set(Vars::raime, 2311); 	benRet.push_back(SSBenefit(&p, 1988,1988)); 	ben2010.push_back(SSBenefit(&p, 2010,1988)); 
	p.set(Vars::rbyr, 1927); 	p.set(Vars::raime, 2490); 	benRet.push_back(SSBenefit(&p, 1989,1989)); 	ben2010.push_back(SSBenefit(&p, 2010,1989)); 
	p.set(Vars::rbyr, 1928); 	p.set(Vars::raime, 2648); 	benRet.push_back(SSBenefit(&p, 1990,1990)); 	ben2010.push_back(SSBenefit(&p, 2010,1990)); 
	p.set(Vars::rbyr, 1929); 	p.set(Vars::raime, 2792); 	benRet.push_back(SSBenefit(&p, 1991,1991)); 	ben2010.push_back(SSBenefit(&p, 2010,1991)); 
	p.set(Vars::rbyr, 1930); 	p.set(Vars::raime, 2978); 	benRet.push_back(SSBenefit(&p, 1992,1992)); 	ben2010.push_back(SSBenefit(&p, 2010,1992)); 
	p.set(Vars::rbyr, 1931); 	p.set(Vars::raime, 3154); 	benRet.push_back(SSBenefit(&p, 1993,1993)); 	ben2010.push_back(SSBenefit(&p, 2010,1993)); 
	p.set(Vars::rbyr, 1932); 	p.set(Vars::raime, 3384); 	benRet.push_back(SSBenefit(&p, 1994,1994)); 	ben2010.push_back(SSBenefit(&p, 2010,1994)); 
	p.set(Vars::rbyr, 1933); 	p.set(Vars::raime, 3493); 	benRet.push_back(SSBenefit(&p, 1995,1995)); 	ben2010.push_back(SSBenefit(&p, 2010,1995)); 
	p.set(Vars::rbyr, 1934); 	p.set(Vars::raime, 3657); 	benRet.push_back(SSBenefit(&p, 1996,1996)); 	ben2010.push_back(SSBenefit(&p, 2010,1996)); 
	p.set(Vars::rbyr, 1935); 	p.set(Vars::raime, 3877); 	benRet.push_back(SSBenefit(&p, 1997,1997)); 	ben2010.push_back(SSBenefit(&p, 2010,1997)); 
	p.set(Vars::rbyr, 1936); 	p.set(Vars::raime, 4144); 	benRet.push_back(SSBenefit(&p, 1998,1998)); 	ben2010.push_back(SSBenefit(&p, 2010,1998)); 
	p.set(Vars::rbyr, 1937); 	p.set(Vars::raime, 4463); 	benRet.push_back(SSBenefit(&p, 1999,1999)); 	ben2010.push_back(SSBenefit(&p, 2010,1999)); 
	p.set(Vars::rbyr, 1938); 	p.set(Vars::raime, 4775); 	benRet.push_back(SSBenefit(&p, 2000,2000)); 	ben2010.push_back(SSBenefit(&p, 2010,2000)); 
	p.set(Vars::rbyr, 1939); 	p.set(Vars::raime, 5126); 	benRet.push_back(SSBenefit(&p, 2001,2001)); 	ben2010.push_back(SSBenefit(&p, 2010,2001)); 
	p.set(Vars::rbyr, 1940); 	p.set(Vars::raime, 5499); 	benRet.push_back(SSBenefit(&p, 2002,2002)); 	ben2010.push_back(SSBenefit(&p, 2010,2002)); 
	p.set(Vars::rbyr, 1941); 	p.set(Vars::raime, 5729); 	benRet.push_back(SSBenefit(&p, 2003,2003)); 	ben2010.push_back(SSBenefit(&p, 2010,2003)); 
	p.set(Vars::rbyr, 1942); 	p.set(Vars::raime, 5892); 	benRet.push_back(SSBenefit(&p, 2004,2004)); 	ben2010.push_back(SSBenefit(&p, 2010,2004)); 
	p.set(Vars::rbyr, 1943); 	p.set(Vars::raime, 6137); 	benRet.push_back(SSBenefit(&p, 2005,2005)); 	ben2010.push_back(SSBenefit(&p, 2010,2005)); 
	p.set(Vars::rbyr, 1944); 	p.set(Vars::raime, 6515); 	benRet.push_back(SSBenefit(&p, 2006,2006)); 	ben2010.push_back(SSBenefit(&p, 2010,2006)); 
	p.set(Vars::rbyr, 1945); 	p.set(Vars::raime, 6852); 	benRet.push_back(SSBenefit(&p, 2007,2007)); 	ben2010.push_back(SSBenefit(&p, 2010,2007)); 
	p.set(Vars::rbyr, 1946); 	p.set(Vars::raime, 7260); 	benRet.push_back(SSBenefit(&p, 2008,2008)); 	ben2010.push_back(SSBenefit(&p, 2010,2008)); 
	p.set(Vars::rbyr, 1947); 	p.set(Vars::raime, 7685); 	benRet.push_back(SSBenefit(&p, 2009,2009)); 	ben2010.push_back(SSBenefit(&p, 2010,2009)); 
	p.set(Vars::rbyr, 1948); 	p.set(Vars::raime, 7949); 	benRet.push_back(SSBenefit(&p, 2010,2010)); 	ben2010.push_back(SSBenefit(&p, 2010,2010)); 
	
	p.set(Vars::rbmonth, 6);
	p.set(Vars::rbyr, 1922); 	p.set(Vars::raime, 2009); 	benRet.push_back(SSBenefit(&p, 1987,1987)); 	ben2010.push_back(SSBenefit(&p, 2010,1987)); 
	p.set(Vars::rbyr, 1923); 	p.set(Vars::raime, 2139); 	benRet.push_back(SSBenefit(&p, 1988,1988)); 	ben2010.push_back(SSBenefit(&p, 2010,1988)); 
	p.set(Vars::rbyr, 1924); 	p.set(Vars::raime, 2287); 	benRet.push_back(SSBenefit(&p, 1989,1989)); 	ben2010.push_back(SSBenefit(&p, 2010,1989)); 
	p.set(Vars::rbyr, 1925); 	p.set(Vars::raime, 2417); 	benRet.push_back(SSBenefit(&p, 1990,1990)); 	ben2010.push_back(SSBenefit(&p, 2010,1990)); 
	p.set(Vars::rbyr, 1926); 	p.set(Vars::raime, 2531); 	benRet.push_back(SSBenefit(&p, 1991,1991)); 	ben2010.push_back(SSBenefit(&p, 2010,1991)); 
	p.set(Vars::rbyr, 1927); 	p.set(Vars::raime, 2716); 	benRet.push_back(SSBenefit(&p, 1992,1992)); 	ben2010.push_back(SSBenefit(&p, 2010,1992)); 
	p.set(Vars::rbyr, 1928); 	p.set(Vars::raime, 2878); 	benRet.push_back(SSBenefit(&p, 1993,1993)); 	ben2010.push_back(SSBenefit(&p, 2010,1993)); 
	p.set(Vars::rbyr, 1929); 	p.set(Vars::raime, 3024); 	benRet.push_back(SSBenefit(&p, 1994,1994)); 	ben2010.push_back(SSBenefit(&p, 2010,1994)); 
	p.set(Vars::rbyr, 1930); 	p.set(Vars::raime, 3219); 	benRet.push_back(SSBenefit(&p, 1995,1995)); 	ben2010.push_back(SSBenefit(&p, 2010,1995)); 
	p.set(Vars::rbyr, 1931); 	p.set(Vars::raime, 3402); 	benRet.push_back(SSBenefit(&p, 1996,1996)); 	ben2010.push_back(SSBenefit(&p, 2010,1996)); 
	p.set(Vars::rbyr, 1932); 	p.set(Vars::raime, 3634); 	benRet.push_back(SSBenefit(&p, 1997,1997)); 	ben2010.push_back(SSBenefit(&p, 2010,1997)); 
	p.set(Vars::rbyr, 1933); 	p.set(Vars::raime, 3750); 	benRet.push_back(SSBenefit(&p, 1998,1998)); 	ben2010.push_back(SSBenefit(&p, 2010,1998)); 
	p.set(Vars::rbyr, 1934); 	p.set(Vars::raime, 3926); 	benRet.push_back(SSBenefit(&p, 1999,1999)); 	ben2010.push_back(SSBenefit(&p, 2010,1999)); 
	p.set(Vars::rbyr, 1935); 	p.set(Vars::raime, 4161); 	benRet.push_back(SSBenefit(&p, 2000,2000)); 	ben2010.push_back(SSBenefit(&p, 2010,2000)); 
	p.set(Vars::rbyr, 1936); 	p.set(Vars::raime, 4440); 	benRet.push_back(SSBenefit(&p, 2001,2001)); 	ben2010.push_back(SSBenefit(&p, 2010,2001)); 
	p.set(Vars::rbyr, 1937); 	p.set(Vars::raime, 4770); 	benRet.push_back(SSBenefit(&p, 2002,2002)); 	ben2010.push_back(SSBenefit(&p, 2010,2002)); 
	p.set(Vars::rbyr, 1938); 	p.set(Vars::raime, 5099); 	benRet.push_back(SSBenefit(&p, 2003,2003)); 	ben2010.push_back(SSBenefit(&p, 2010,2003)); 
	p.set(Vars::rbyr, 1939); 	p.set(Vars::raime, 5457); 	benRet.push_back(SSBenefit(&p, 2004,2004)); 	ben2010.push_back(SSBenefit(&p, 2010,2004)); 
	p.set(Vars::rbyr, 1940); 	p.set(Vars::raime, 5827); 	benRet.push_back(SSBenefit(&p, 2005,2005)); 	ben2010.push_back(SSBenefit(&p, 2010,2005)); 
	p.set(Vars::rbyr, 1941); 	p.set(Vars::raime, 6058); 	benRet.push_back(SSBenefit(&p, 2006,2006)); 	ben2010.push_back(SSBenefit(&p, 2010,2006)); 
	p.set(Vars::rbyr, 1942); 	p.set(Vars::raime, 6229); 	benRet.push_back(SSBenefit(&p, 2007,2007)); 	ben2010.push_back(SSBenefit(&p, 2010,2007)); 
	p.set(Vars::rbyr, 1943); 	p.set(Vars::raime, 6479); 	benRet.push_back(SSBenefit(&p, 2008,2008)); 	ben2010.push_back(SSBenefit(&p, 2010,2008)); 
	p.set(Vars::rbyr, 1944); 	p.set(Vars::raime, 6861); 	benRet.push_back(SSBenefit(&p, 2009,2009)); 	ben2010.push_back(SSBenefit(&p, 2010,2009)); 
	p.set(Vars::rbyr, 1945); 	p.set(Vars::raime, 7189); 	benRet.push_back(SSBenefit(&p, 2010,2010)); 	ben2010.push_back(SSBenefit(&p, 2010,2010)); 
	p.set(Vars::rbyr, 1917); 	p.set(Vars::raime, 1725); 	benRet.push_back(SSBenefit(&p, 1987,1987)); 	ben2010.push_back(SSBenefit(&p, 2010,1987)); 
	p.set(Vars::rbyr, 1918); 	p.set(Vars::raime, 1859); 	benRet.push_back(SSBenefit(&p, 1988,1988)); 	ben2010.push_back(SSBenefit(&p, 2010,1988)); 
	p.set(Vars::rbyr, 1919); 	p.set(Vars::raime, 2000); 	benRet.push_back(SSBenefit(&p, 1989,1989)); 	ben2010.push_back(SSBenefit(&p, 2010,1989)); 
	p.set(Vars::rbyr, 1920); 	p.set(Vars::raime, 2154); 	benRet.push_back(SSBenefit(&p, 1990,1990)); 	ben2010.push_back(SSBenefit(&p, 2010,1990)); 
	p.set(Vars::rbyr, 1921); 	p.set(Vars::raime, 2332); 	benRet.push_back(SSBenefit(&p, 1991,1991)); 	ben2010.push_back(SSBenefit(&p, 2010,1991)); 
	p.set(Vars::rbyr, 1922); 	p.set(Vars::raime, 2470); 	benRet.push_back(SSBenefit(&p, 1992,1992)); 	ben2010.push_back(SSBenefit(&p, 2010,1992)); 
	p.set(Vars::rbyr, 1923); 	p.set(Vars::raime, 2605); 	benRet.push_back(SSBenefit(&p, 1993,1993)); 	ben2010.push_back(SSBenefit(&p, 2010,1993)); 
	p.set(Vars::rbyr, 1924); 	p.set(Vars::raime, 2758); 	benRet.push_back(SSBenefit(&p, 1994,1994)); 	ben2010.push_back(SSBenefit(&p, 2010,1994)); 
	p.set(Vars::rbyr, 1925); 	p.set(Vars::raime, 2896); 	benRet.push_back(SSBenefit(&p, 1995,1995)); 	ben2010.push_back(SSBenefit(&p, 2010,1995)); 
	p.set(Vars::rbyr, 1926); 	p.set(Vars::raime, 3012); 	benRet.push_back(SSBenefit(&p, 1996,1996)); 	ben2010.push_back(SSBenefit(&p, 2010,1996)); 
	p.set(Vars::rbyr, 1927); 	p.set(Vars::raime, 3189); 	benRet.push_back(SSBenefit(&p, 1997,1997)); 	ben2010.push_back(SSBenefit(&p, 2010,1997)); 
	p.set(Vars::rbyr, 1928); 	p.set(Vars::raime, 3348); 	benRet.push_back(SSBenefit(&p, 1998,1998)); 	ben2010.push_back(SSBenefit(&p, 2010,1998)); 
	p.set(Vars::rbyr, 1929); 	p.set(Vars::raime, 3496); 	benRet.push_back(SSBenefit(&p, 1999,1999)); 	ben2010.push_back(SSBenefit(&p, 2010,1999)); 
	p.set(Vars::rbyr, 1930); 	p.set(Vars::raime, 3707); 	benRet.push_back(SSBenefit(&p, 2000,2000)); 	ben2010.push_back(SSBenefit(&p, 2010,2000)); 
	p.set(Vars::rbyr, 1931); 	p.set(Vars::raime, 3912); 	benRet.push_back(SSBenefit(&p, 2001,2001)); 	ben2010.push_back(SSBenefit(&p, 2010,2001)); 
	p.set(Vars::rbyr, 1932); 	p.set(Vars::raime, 4165); 	benRet.push_back(SSBenefit(&p, 2002,2002)); 	ben2010.push_back(SSBenefit(&p, 2010,2002)); 
	p.set(Vars::rbyr, 1933); 	p.set(Vars::raime, 4321); 	benRet.push_back(SSBenefit(&p, 2003,2003)); 	ben2010.push_back(SSBenefit(&p, 2010,2003)); 
	p.set(Vars::rbyr, 1934); 	p.set(Vars::raime, 4532); 	benRet.push_back(SSBenefit(&p, 2004,2004)); 	ben2010.push_back(SSBenefit(&p, 2010,2004)); 
	p.set(Vars::rbyr, 1935); 	p.set(Vars::raime, 4786); 	benRet.push_back(SSBenefit(&p, 2005,2005)); 	ben2010.push_back(SSBenefit(&p, 2010,2005)); 
	p.set(Vars::rbyr, 1936); 	p.set(Vars::raime, 5072); 	benRet.push_back(SSBenefit(&p, 2006,2006)); 	ben2010.push_back(SSBenefit(&p, 2010,2006)); 
	p.set(Vars::rbyr, 1937); 	p.set(Vars::raime, 5406); 	benRet.push_back(SSBenefit(&p, 2007,2007)); 	ben2010.push_back(SSBenefit(&p, 2010,2007)); 
	p.set(Vars::rbyr, 1938); 	p.set(Vars::raime, 5733); 	benRet.push_back(SSBenefit(&p, 2008,2008)); 	ben2010.push_back(SSBenefit(&p, 2010,2008)); 
	p.set(Vars::rbyr, 1939); 	p.set(Vars::raime, 6090); 	benRet.push_back(SSBenefit(&p, 2009,2009)); 	ben2010.push_back(SSBenefit(&p, 2010,2009)); 
	p.set(Vars::rbyr, 1940); 	p.set(Vars::raime, 6450); 	benRet.push_back(SSBenefit(&p, 2010,2010)); 	ben2010.push_back(SSBenefit(&p, 2010,2010)); 

}

/*
double SSCalculator::SsPIA(double raime, double rq, int rbyr, bool alive, int dthyr) {

	// Calculate the year for the PIA bend points, 
	// the year in which a worker attains age 62, becomes disabled before age 62, or dies before attaining age 62
	const int y_pia = alive ? (rbyr + 62) : std::min(rbyr + 62, dthyr);

	// The {1,2} Bent Point in yr X are given by BP_{1,2}(X) = NWI(X-2)/NWI(1977) * BP_{1,2}(1979)
	// Where BP_1 (1979) = 180 and BP_2 (1979) = 1085
	const double nwi77  = nwi->Value(1977);
	const double nwi_y2 = nwi->Value(y_pia-2);
	const double bend1  = (nwi_y2/nwi77)*180.0;
	const double bend2  = (nwi_y2/nwi77)*1085.0;


	// The PIA formula is then, 
	// (a) 90 percent of the first bend point of his/her average indexed monthly earnings, plus
	// (b) 32 percent of his/her average indexed monthly earnings over the first bend point and through second bend point, plus
	// (c) 15 percent of his/her average indexed monthly earnings over the second bend point
	// or, PIA = 0.90*MIN(AIME, BP1) + 0.32*MAX(0, MIN(AIME, BP2) - BP1) + 0.15*MAX(0, AIME-BP2)

	double pia, pia_min;
	const double pia_mtr1 = 0.9;
	const double pia_mtr2 = 0.32;
	const double pia_mtr3 = 0.15;
	const double pia_minrate = 11.50;

	pia =  pia_mtr1*std::min(raime,bend1)
		+ pia_mtr2*std::min(std::max(raime-bend1,0.0),bend2-bend1)
		+ pia_mtr3*std::max(raime-bend2,0.0);

	pia_min = pia_minrate*std::min(std::max((rq/4.0)-10.0,0.0),30.0);					 	
	pia = std::max(pia,pia_min);
	return pia;
}
*/

// the year in which a worker attains age 62, becomes disabled before age 62, or dies before attaining age 62
double SSCalculator::SsPIA(double raime, double rq, int elig_yr) {

	// Calculate the year for the PIA bend points, the (elig_yr - 2)
	const int index_yr = elig_yr - 2;

	// The {1,2} Bent Point in yr X are given by BP_{1,2}(X) = NWI(X-2)/NWI(1977) * BP_{1,2}(1979)
	// Where BP_1 (1979) = 180 and BP_2 (1979) = 1085
	const double nwi77  = nwi->Value(1977);
	const double nwi_y2 = nwi->Value(index_yr);
	const double bend1  = (nwi_y2/nwi77)*180.0;
	const double bend2  = (nwi_y2/nwi77)*1085.0;


	// The PIA formula is then, 
	// (a) 90 percent of the first bend point of his/her average indexed monthly earnings, plus
	// (b) 32 percent of his/her average indexed monthly earnings over the first bend point and through second bend point, plus
	// (c) 15 percent of his/her average indexed monthly earnings over the second bend point
	// or, PIA = 0.90*MIN(AIME, BP1) + 0.32*MAX(0, MIN(AIME, BP2) - BP1) + 0.15*MAX(0, AIME-BP2)

	double pia, pia_min;
	const double pia_mtr1 = 0.9;
	const double pia_mtr2 = 0.32;
	const double pia_mtr3 = 0.15;
	const double pia_minrate = 11.50;

	pia =  pia_mtr1*std::min(raime,bend1)
		+ pia_mtr2*std::min(std::max(raime-bend1,0.0),bend2-bend1)
		+ pia_mtr3*std::max(raime-bend2,0.0);

	pia_min = pia_minrate*std::min(std::max((rq/4.0)-10.0,0.0),30.0);					 	
	pia = std::max(pia,pia_min);
	return pia;
}



void SSCalculator::setModelProvider(IModelProvider* mp) {
	try {
		isret_wd_model = mp->get("isret_wd");
	} catch (fem_exception e) {
		throw fem_exception("Social Security Calculator needs isret_wd model");
	}
}

