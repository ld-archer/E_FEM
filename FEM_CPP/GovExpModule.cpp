#include "GovExpModule.h"
#include "Logger.h"
#include "utility.h"
#include <math.h>
#include "Random.h"
#include "fem_exception.h"
#include <sstream> 

GovExpModule::GovExpModule(ITimeSeriesProvider *timeSeriesProvider) : sscalc(timeSeriesProvider)
{
	// Load relevant time series
	sscap = timeSeriesProvider->get("sscap");
	nra = timeSeriesProvider->get("nra");
	cola = timeSeriesProvider->get("cola");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");
	nwi = timeSeriesProvider->get("nwi");
	drc = timeSeriesProvider->get("drc");
	sga = timeSeriesProvider->get("sga");
	eadisreg1 = timeSeriesProvider->get("eadisreg1");
	eadisreg2 = timeSeriesProvider->get("eadisreg2");
};

GovExpModule::~GovExpModule(void)
{
}


void GovExpModule::process(PersonVector& persons, unsigned int year, Random* random) {
	Logger::log("Running Govt Exp Module", FINE);


	// Prep tax parameters for this year
	// Some are constant, others are indexed to CPI changes from the base year, 2004

	const unsigned int base_year = 2004;
	double delta_cpi = 1.0;
	for(unsigned int i=base_year; i <= year; i++)
	  delta_cpi *= (1+cpi_yearly->Value(i));

	// Tax bracket amounts for singles
	current_tax_params.sbra[0] = 7150*delta_cpi;
	current_tax_params.sbra[1] = 29050*delta_cpi;
	current_tax_params.sbra[2] = 70350*delta_cpi;
	current_tax_params.sbra[3] = 146750*delta_cpi;
	current_tax_params.sbra[4] = 319100*delta_cpi;

	// Tax bracket amounts for couples
	current_tax_params.cbra[0] = 14300*delta_cpi;
	current_tax_params.cbra[1] = 58100*delta_cpi;
	current_tax_params.cbra[2] = 117250*delta_cpi;
	current_tax_params.cbra[3] = 178650*delta_cpi;
	current_tax_params.cbra[4] = 319100*delta_cpi;

	// Tax bracket rates. These are constant
	current_tax_params.mtr[0] = 0.10;
	current_tax_params.mtr[1] = 0.15;
	current_tax_params.mtr[2] = 0.25;
	current_tax_params.mtr[3] = 0.28;
	current_tax_params.mtr[4] = 0.33;
	current_tax_params.mtr[5] = 0.35;
	
	/// Basic deduction and old age deduction
	current_tax_params.bded_sing = 4850*delta_cpi;
	current_tax_params.bded_coup = 9700*delta_cpi;
	current_tax_params.oded_sing = 6050*delta_cpi;
	current_tax_params.oded_coup = 10650*delta_cpi;
	current_tax_params.pded = 3100*delta_cpi;
	current_tax_params.pded_r = 0.02;
	current_tax_params.pded_s = 2500*delta_cpi;
	current_tax_params.pded_tcoup = 214500*delta_cpi;
	current_tax_params.pded_tsing = 142700*delta_cpi;
	
	
	/// taxation of social security benefits 
	current_tax_params.base_ssa_sing = 25000*delta_cpi;
	current_tax_params.base_ssa_coup = 32000*delta_cpi;
	current_tax_params.base2_ssa_sing = 9000*delta_cpi;
    current_tax_params.base2_ssa_coup = 12000*delta_cpi;

	/// tax credit for low-income elderly
	current_tax_params.tc_max1_sing = 17500*delta_cpi;
	current_tax_params.tc_max1_one65 = 20000*delta_cpi; 
	current_tax_params.tc_max1_both65 = 25000*delta_cpi;
	current_tax_params.tc_max2_sing = 5000*delta_cpi;
	current_tax_params.tc_max2_one65 = 7500*delta_cpi; 
		
	/// Earned Income Tax Credit
	current_tax_params.eic_rate = 0.0765;
	current_tax_params.eic_lim = 5100*delta_cpi;
	current_tax_params.eic_tre_mar = 12490*delta_cpi;
	current_tax_params.eic_tre_sig = 11490*delta_cpi;
	current_tax_params.eic_phase = 0.765;

	/// City and State Taxes: Detroit, Michigan
	current_tax_params.city_ded = 750*delta_cpi;
	current_tax_params.state_ded = 3100*delta_cpi;
	current_tax_params.state_atr = 0.04;
	current_tax_params.city_atr = 0.0255;
	current_tax_params.city_tc_thres1 = 100*delta_cpi;
	current_tax_params.city_tc_thres2 = 150*delta_cpi;
	current_tax_params.city_tc_mtr1 = 0.20;
	current_tax_params.city_tc_mtr2 = 0.10;
	current_tax_params.city_tc_mtr3 = 0.05;

	/// social security tax witheld on earnings
	current_tax_params.oasi_tr = 0.062;
	current_tax_params.medc_tr = 0.0145;
	current_tax_params.stax_max = sscap->Value(year);

	std::vector<Person*>::iterator itr;

	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {

	
			/*
			int rbyr_tmp = person->get(Vars::rbyr);
			int sbyr_tmp = 2100;

			if (person->getSpouse() != NULL) 
				sbyr_tmp = person->getSpouse()->get(Vars::rbyr);
			else if(!person->test(Vars::married) && !person->test(Vars::single) && person->test(Vars::ssclaim))
				sbyr_tmp = rbyr_tmp;
			
			*/

			// Specify adjustment factors
			double adj_diben = 1.00;

			



			/******************************************************
			* Government expenditures and revenues
			* Expenditures:
			SS retirement benefits (OASI)
			SSDI
			SSI
			Medical care costs (in costs.ado)
			* Revenues
			Federal income tax
			state and city tax
			social security tax
			Medicare tax
			******************************************************/

			// Average monthly payments for SSI
			// From Table 7.A1 of the Annual statistical suppplement

			double ssiben65l = 450*12 ;
			double ssiben65p = 350*12;

			// Expenditure-OASI
			double ssben = person->test(Vars::ssclaim) ? 12*sscalc.SSBenefit(person, year, (unsigned int)person->get(Vars::rssclyr)) : 0.0;	
			double sswben = person->test(Vars::sswclaim) ? 12*sscalc.SSBenefit(person, year, (unsigned int)person->get(Vars::rsswclyr)) : 0.0;	

			/* For widowed, use the cross-sectional regression coefficients
			if(person->test(Vars::ssclaim) && person->test(Vars::widowed)) {
				isret_wd_model->predict(person, random);
				ssben = std::max(person->get(Vars::oasi_wd), ssben);
			}
			*/
			person->set(Vars::ssben,std::max(ssben,sswben));

			// Expenditure-Disability benefits
			double diben = 0.0;
			if(person->test(Vars::diclaim)) {
				diben = DiBenefit(person->get(Vars::raime), person->get(Vars::rq), person->get(Vars::ry_earn), (unsigned int) person->get(Vars::rbyr), year);
				diben*= adj_diben;
			}
			person->set(Vars::diben, diben);




			
			// Expenditure-SSI
			
			
			// Adjust for under-reporting of SSI claiming
			admin_ssi_model->predict(person, random);
			bool ssiclaim_old = person->test(Vars::ssiclaim);
			bool ssiclaim = person->get(Vars::admin_ssi) + random->normalDist(person->getID(), Vars::ssiclaim, year,0,1) >= 0;
			person->set(Vars::ssiclaim, ssiclaim);
			person->set(Vars::ssiben, ssiclaim ? (person->get(Vars::age) < 65 ? ssiben65l : ssiben65p ) : 0);
			person->set(Vars::ssiclaim, ssiclaim_old);
		}
	}

	/* Because we will be doing some totaling in the next step, need to wait until all people have been processed */

	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {


			
			// Government revenues
			
			// HH SS benefits (including OASI, DI)

			double ry_pub = person->get(Vars::ssben) + person->get(Vars::diben);
			double sy_pub = 0;
			if(person->getSpouse() != NULL && person->test(Vars::married))
				sy_pub = person->getSpouse()->get(Vars::ssben) + person->getSpouse()->get(Vars::diben);

			
			// Generate household DB pension income
			double hhdbpen = person->get(Vars::dbpen);
			if(person->getSpouse() != NULL && !person->getSpouse()->test(Vars::l2died))
				hhdbpen += person->getSpouse()->get(Vars::dbpen);
			
			// HH SSI income
			double hhssiben = person->get(Vars::ssiben);
			if(person->getSpouse() != NULL && !person->getSpouse()->test(Vars::l2died) )
				hhssiben += person->getSpouse()->get(Vars::ssiben);
			
	
			// Now define the input/output vector
			double gross, net, ftax, stax, ctax, hoasi, hmed, agi;
			
			ftax = 0.0;
			stax = 0.0;
			ctax = 0.0;
			hoasi = 0.0;
			hmed = 0.0;
			gross = 0.0;
			net = 0.0;
			agi = 0.0;

// Bryan replaced ry_earn with ry_earnuc for the respondent and spouse, hoping that these variables will be passed to the tax modules correctly

			if(person->getSpouse() != NULL)
				GovRevenues(person->get(Vars::ry_earnuc),
							person->getSpouse()->test(Vars::l2died) ? 0.0 : person->getSpouse()->get(Vars::ry_earnuc),
							ry_pub,
							sy_pub,
							hhssiben,
							hhdbpen,
							0.0,  // hhothinc
							0.0,  //hicap
							person->test(Vars::l2married),
							person->get(Vars::age),
							person->getSpouse()->test(Vars::l2died) ? 0 : person->getSpouse()->get(Vars::age),
					    gross, agi, net, ftax, stax, ctax, hoasi, hmed, current_tax_params);
			else
				GovRevenues(person->get(Vars::ry_earnuc),
					0.0,
					ry_pub,
					sy_pub,
					hhssiben,
					hhdbpen,
					0.0,  // hhothinc
					0.0,  //hicap
					person->test(Vars::l2married),
					person->get(Vars::age),
					0,
					    gross, agi, net, ftax, stax, ctax, hoasi, hmed, current_tax_params);

			if(person->getSpouse() != NULL && person->test(Vars::l2married)) {
				ftax /= 2.0;
				agi /= 2.0;
				stax /= 2.0;
				ctax /= 2.0;
				hoasi /= 2.0;
				hmed /= 2.0	;
			}

			person->set(Vars::gross, gross);
			person->set(Vars::agi, agi);
			person->set(Vars::net, net);
			person->set(Vars::ftax, ftax);
			person->set(Vars::stax, stax);
			person->set(Vars::ctax, ctax);
			person->set(Vars::hoasi, hoasi);
			person->set(Vars::hmed, hmed);

			
		}
	}
}
/* This was commented out in header file - see header file for explanation.
void GovExpModule::SSBenefit(double raime, double rq, double ry_earn, unsigned int rclyr, unsigned int rbyr, bool rl, unsigned int rdthyr,
							 double saime, double sq, double sy_earn, unsigned int sclyr, unsigned int sbyr, bool sl, unsigned int sdthyr ,
							 bool rmar, unsigned int yr,
							 double &rben_g, double &rben_s, double &rben_v, double &sben_g, double &sben_s, double &sben_v) {

	// 	 ----------------------------------------------------
	//	 Social Security Benefit Function for United States -
	//	 Based on Social Security Handbook 2004
	//	 ----------------------------------------------------

		 // 2.A Important Indicators ----------------------
		 unsigned int ry60, sy60, rynra, synra, ry70, sy70, rage, sage;

		 ry60 = rbyr + 60;
		 ry70 = rbyr + 70;
		 rynra = rbyr + (unsigned int)(nra->Value(rbyr) /12.0);

		 sy60 = sbyr + 60;
		 sy70 = sbyr + 70;
		 synra = sbyr + (unsigned int)(nra->Value(sbyr)  /12.0);

		 rage = yr - rbyr ;
		 sage = yr - sbyr ;


		 /// Determine Eligibility based on age and quarters or coverage
		 unsigned int rmin, smin, re, se;
		 rmin = rbyr < 1929 ? 40 - (1929-rbyr) : 40;
		 smin = sbyr < 1929 ? 40 - (1929-sbyr) : 40;

		 re = (rage>=(sl==1 ? 62 : 60))&&(rq>=rmin);
		 se = (sage>=(rl==1 ? 62 : 60))&&(sq>=smin);

		 /// Get PIA based on AIME, quarters (for minimum PIA) and birth year
		 double rpia, spia;
		 rpia = SsPIA(raime, rq, rbyr, rl, rdthyr);
		 spia = SsPIA(saime, sq, sbyr, sl, sdthyr);


		 /// Get DRC or ARF based on birth year and claiming date
		 double arf;
		 double rdrc, sdrc, rr, sr;
		 arf = 0.0678;
		 rdrc = drc->Value(rbyr);
		 sdrc = drc->Value(sbyr);

		 if(rclyr<=rynra)
		   rdrc = exp(arf*std::max<unsigned int>(std::min<unsigned int>(rclyr-rynra,0), 62-rynra));
		 else 
		   rdrc = exp(rdrc*std::min<unsigned int>(rclyr-rynra, ry70-rynra));
		 rr = rclyr<=yr;
		 if(rl==0||rr==0||re==0)
			 rdrc = 0;

		 if(sclyr<=synra)
			 sdrc = exp(arf*std::max<unsigned int>(std::min<unsigned int>(sclyr-synra,0),62-synra));
		 else
			 sdrc = exp(sdrc*std::min<unsigned int>(sclyr-synra,sy70-synra));

		 sr = sclyr<=yr;
		 if(sl==0||sr==0||se==0)
			 sdrc = 0;

		 /// Calculate Admissible Benefits on own account
		 rben_g = rdrc*rpia;
		 sben_g = sdrc*spia;



		 /// Calculate Benefit admissible as spouse
		 double sp_factor = 0.5;
		 if(sr != 0)
			 rben_s = std::max(sp_factor*rdrc*spia - rben_g,0.0);
		 else
			 rben_s = 0;
		 if(rr != 0)
			 sben_s = std::max(sp_factor*sdrc*rpia - sben_g,0.0);
		 else
			 sben_s = 0;


		 /// If not married, no spousal benefits
		 if(!rmar) {
			 rben_s = 0;
			 sben_s = 0;
		 }


		 /// Survivor Benefits
		 rben_v = 0;
		 sben_v = 0;
		 if(sl == 0)
			 rben_v = std::max(rdrc*spia - rben_g,0.0);
		 if(rl == 0)
			 sben_v = std::max(sdrc*rpia - sben_g,0.0);


		 /// If married, no survival benefits
		 if(rmar) {
			 rben_v = 0;
			 sben_v = 0;
		 }

		 /// Calculate Total Benefit for Purpose of Earnings Test
		 double rben_all, sben_all;
		 rben_all = rben_g + rben_s + rben_v;
		 sben_all = sben_g + sben_s + sben_v;


		 /// Get Earnings Disregard
		 double rea_cap, sea_cap;
		 rea_cap =  eadisreg(yr, rage);
		 sea_cap =  eadisreg(yr, sage); 

		 /// Apply Tax Rates to Earnings Over Cap
		 double ea_era = 1.0/2.0;
		 double ea_nra = 1.0/3.0;
		 double rea_tax = 0;
		 double sea_tax = 0;
		 if(yr < rynra)
			 rea_tax = ea_era*std::max(ry_earn-rea_cap,0.0);
		 else
			 rea_tax = ea_nra*std::max(ry_earn-rea_cap,0.0);
		 if(yr < synra)
			 sea_tax = ea_era*std::max(sy_earn-sea_cap,0.0);
		 else
			 sea_tax = ea_nra*std::max(sy_earn-sea_cap,0.0);

		 if(rben_all != 0)
			 rea_tax = std::max(std::min(rea_tax/rben_all,1.0),0.0);
		 if(sben_all != 0)
			 sea_tax = std::max(std::min(sea_tax/sben_all,1.0),0.0);


		 // Proportional Reduction of All benefits
		 rben_g *= (1-rea_tax);
		 rben_s *= (1-rea_tax);
		 rben_v *= (1-rea_tax);

		 // Proportional Reduction of All benefits
		 sben_g *= (1-sea_tax);
		 sben_s *= (1-sea_tax);
		 sben_v *= (1-sea_tax);


		 /// Adjust to 2004 dollars ;
		 double cola_r60 = cola->Value(ry60);
		 double cola_s60 = cola->Value(sy60);
		 double cola_04  = cola->Value(2004);

		 rben_g *= (cola_04/cola_r60);
		 rben_s *= (cola_04/cola_r60);
		 rben_v *= (cola_04/cola_r60);

		 sben_g *= (cola_04/cola_s60);
		 sben_s *= (cola_04/cola_s60);
		 sben_v *= (cola_04/cola_s60);

}
*/

/* This was commented out in header file - see header file for explanation.
double GovExpModule::SsPIA(double raime, double rq, unsigned int rbyr, bool alive, unsigned int dthyr) {


	///2. Get Bendpoints for PIA formula 
	///(based on year reach 62 or death yr, minus 2 years

	unsigned int y_pia;
	double nwi_pia;
	y_pia = alive ? (rbyr + 62) : std::min<unsigned int>(rbyr + 62, dthyr);
	nwi_pia = nwi->Value(y_pia - 2);

	double nwi77, b77_1, b77_2;
	nwi77 = 9779.44;
	b77_1 = 180;
	b77_2 = 1085;	

	double bend1, bend2;
	bend1 = (nwi_pia/nwi77)*b77_1;
	bend2  = (nwi_pia/nwi77)*b77_2;

	double pia, pia_min;
	double pia_mtr1 = 0.9;
	double pia_mtr2 = 0.32;
	double pia_mtr3 = 0.15;
	double pia_minrate = 11.50;

	pia =  pia_mtr1*std::min(raime,bend1)
		+ pia_mtr2*std::min(std::max(raime-bend1,0.0),bend2-bend1)
		+ pia_mtr3*std::max(raime-bend2,0.0);

	pia_min = pia_minrate*std::min(std::max((rq/4.0)-10.0,0.0),30.0);					 	
	pia = std::max(pia,pia_min);
	return pia;
}
*/

double GovExpModule::eadisreg(unsigned int yr, unsigned int age) {
	unsigned int my_nra = (unsigned int)(nra->Value(yr - age) /12);
	int type = 0;
	if (age >= 62 && age < my_nra)
		type = 1;
	else if (age >= my_nra && age < 70)
		type = 2;
	else 
		type = 3;

	// for type 0 or 3, disregard all
	if(type == 0 || type == 3)
		return 9999999;
	else if(type == 1)
		return eadisreg1->Value(yr);
	else
		return eadisreg2->Value(yr);
}


void GovExpModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
	try {
		sscalc.setModelProvider(mp);
	} catch (const fem_exception & e) {
		ss << e.what();
	}
	try {
		admin_ssi_model = mp->get("admin_ssi");
	} catch (const fem_exception & e) {
		ss << this->description() << " needs admin_ssi model";
	}
	if(ss.str().length() > 0)
		throw fem_exception(ss.str().c_str());
}



double GovExpModule::DiBenefit(double raime, double rq, double ry_earn, unsigned int rbyr, unsigned int yr) {
	/// 2.A Important Indicators ----------------------
	unsigned int rynra, rage;
	rynra = (unsigned int)(nra->Value(rbyr)/12.0);
	rynra = rbyr + rynra;
	rage = yr - rbyr;


	/// Determine Eligibility based on age and quarters or coverage
	unsigned int rmin, re;
	rmin = rbyr>1929 ? (rage<62 ? 40 - (62-rage) : 40) : 40 - (1929-rbyr);
	re = (rq>=rmin)&&(yr<rynra);

	/// Get PIA based on AIME, quarters (for minimum PIA) and birth year
	double rpia = sscalc.SsPIA(raime, rq, rbyr+62);
	/// Get DRC or ARF based on birth year and claiming date
	double rdrc = re == 0 ? 0 : 1;	

	/// Calculate Admissible Benefits on own account
	double	 rben_g = rdrc*rpia;
	/// Get Substancial Gainful Activity
	double rea_cap = sga->Value(yr);

	rea_cap = ry_earn<=rea_cap;

	/// Only pay benefit if above SGA

	// Proportional Reduction of All benefits
	rben_g = rea_cap*rben_g;	
	return rben_g*12;
}

void GovExpModule::GovRevenues(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
							 double y_ot, double y_as, bool mar, double rage, double sage,
			       double &gross, double &agi, double &ninc, double &ftax, double &stax, double &ctax, double &hoasi, double &hmed, tax_params& cur_tax_params) {

	///  Calculate Taxes paid
  double roasi, soasi, rmed, smed;
	gross = ry_earn + sy_earn + ry_pub + sy_pub + y_ben	+ y_pen + y_ot + y_as;
	FedTax(ry_earn, sy_earn, ry_pub, sy_pub, y_ben, y_pen, y_ot, y_as, mar, rage, sage, ftax, agi, current_tax_params);
	StateTax(ry_earn, sy_earn, ry_pub, sy_pub, y_ben, y_pen, y_ot, y_as, mar, rage, sage, stax, ctax, current_tax_params);
	SsTax(ry_earn, roasi, rmed, current_tax_params);
	SsTax(sy_earn, soasi, smed, current_tax_params);
	hoasi = roasi + soasi;
	hmed  = rmed + smed;
	ninc =  gross - ftax - stax - ctax  - hoasi - hmed;		
}

void GovExpModule::FedTax(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
			  double y_ot, double y_as, bool mar, double rage, double sage, double &ftax, double &agi, tax_params& cur_tax_params) {

		
	/// Calculations -------------------------------
	/// indicators
	
	/// Age Status
	 int agestat;
	 if(rage < 65 && sage < 65)
		 agestat = 1;
	 else if ((rage >= 65 && sage < 65) || (rage < 65 && sage >= 65))
		 agestat = 2;
	 else 
		 agestat = 3;

	 
	/// Taxable SS benefit
	double rtax_ben, rothinc, t1, t2;
	rtax_ben = 0.5*ry_pub;
	
	rothinc = sy_pub + y_pen + ry_earn + sy_earn + y_ben + y_ot + y_as;
	
	if(mar)
		t1 = 0.85*std::max(rtax_ben + rothinc - cur_tax_params.base_ssa_coup,0.0);
	else
		t1 = 0.85*std::max(rtax_ben + rothinc - cur_tax_params.base_ssa_sing,0.0);
	
	if(mar)
		t2 = std::min(rtax_ben + rothinc,   cur_tax_params.base_ssa_coup);
	else
		t2 = std::min(rtax_ben + rothinc,cur_tax_params.base_ssa_sing);
	
	t2 = std::min(rtax_ben,0.5*t2);
	t1 = std::min(t1 + t2,0.85*ry_pub); 		
	rtax_ben = t1;
	
	double stax_ben, sothinc;
	stax_ben = 0.5*sy_pub;
	sothinc = ry_pub + y_pen + ry_earn + sy_earn + y_ben + y_ot + y_as;

	if(mar)
		t1 = 0.85*std::max(stax_ben + sothinc - cur_tax_params.base_ssa_coup,0.0);
	else
		t1 = 0;
	
	if(mar)
		t2 = std::min(stax_ben + sothinc, cur_tax_params.base_ssa_coup);
	else
		t2 = 0;
	
	t2 = std::min(stax_ben,0.5*t2);
	t1 = std::min(t1 + t2,0.85*sy_pub); 		
	stax_ben = t1;
	
	
	/// Taxable income for federal tax
    double y_gross, ded, exempt, cut, y_taxble;
	bool a65;

	y_gross = ry_earn + sy_earn + rtax_ben + stax_ben + y_pen + y_ben + y_ot + y_as ;
	
	a65 = agestat>1;
	if(!a65 && !mar)
		ded = cur_tax_params.bded_sing;
	else if(!a65 && mar)
		ded = cur_tax_params.bded_coup;
	else if (a65 && !mar)
		ded = cur_tax_params.oded_sing;
	else
		ded = cur_tax_params.oded_coup;
	
	exempt = cur_tax_params.pded*(1+mar);
	if(mar)
		cut = std::min(cur_tax_params.pded_r*floor((std::max(y_gross-cur_tax_params.pded_tcoup,0.0))/cur_tax_params.pded_s),1.0);
	else
		cut = std::min(cur_tax_params.pded_r*floor((std::max(y_gross-cur_tax_params.pded_tsing,0.0))/cur_tax_params.pded_s),1.0);
	exempt = (1-cut)*exempt;
	
	y_taxble = std::max(y_gross-ded - exempt,0.0);	
	agi = y_taxble;

	/// Federal taxes paid
	double ftax_gross;

	double ts[6];
	double tc[6];
	mkspline(y_taxble, 5, cur_tax_params.sbra, ts);
	mkspline(y_taxble, 5, cur_tax_params.cbra, tc);
	double* t = mar ?  tc : ts;

	ftax_gross = 0;
	for(int i = 0; i < 6; i++)
		ftax_gross += cur_tax_params.mtr[i]*t[i];

	/// Tax credit on federal tax for low income elderly
	bool test1,  test2;
	test1 = false;
	test2 = false;
	double  nontaxable, tcredit;
	/// determine eligibility
	if(!mar && rage >= 65)
		test1 = y_gross<cur_tax_params.tc_max1_sing;
	if(mar && agestat == 2)
		test1 = y_gross<cur_tax_params.tc_max1_one65;
	if(mar && agestat == 3)
		test1 = y_gross<cur_tax_params.tc_max1_both65;
	
	nontaxable = ry_pub + sy_pub - rtax_ben - stax_ben;

	if(!mar && rage >= 65)
		test2 = nontaxable < cur_tax_params.tc_max2_sing;
	if(mar && agestat > 1)
		test2 = nontaxable < cur_tax_params.tc_max2_one65;
	
	/// determine credit
	tcredit = 0;
	if(test1 && test2)
		tcredit = cur_tax_params.tc_max2_sing;
	if(mar && test1 && test2 && agestat==3)
		tcredit = cur_tax_params.tc_max2_one65;

	ftax = std::max(ftax_gross - tcredit,0.0);
		
	/// Earned Income Tax Credit
	double hy_earn, eic, pen;
	hy_earn = ry_earn + sy_earn;
	
	eic = std::min(cur_tax_params.eic_rate*hy_earn,cur_tax_params.eic_lim);
	if(mar)
		pen = cur_tax_params.eic_phase*std::max(hy_earn-cur_tax_params.eic_tre_mar,0.0);
	else
		pen = cur_tax_params.eic_phase*std::max(hy_earn-cur_tax_params.eic_tre_sig,0.0);
	
	eic = std::max(eic - pen,0.0);
	if((mar && std::min(rage, sage) >= 65) || (!mar && rage >= 65))
		eic = 0;
	
			
	/// Net income
	ftax -= eic;
}

void GovExpModule::StateTax(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
							 double y_ot, double y_as, bool mar, double rage, double sage, double &stax, double &ctax, tax_params& cur_tax_params) {
	
	double y_total = ry_earn + sy_earn + ry_pub + sy_pub + y_ben + y_pen + y_ot + y_as; 

	///  taxes: Detroit, Michigan
	double city_taxble, state_taxble, city_taxgross, city_tc;
	
	city_taxble = std::max(y_total - cur_tax_params.city_ded*(1+mar),0.0);
	state_taxble = std::max(y_total - cur_tax_params.state_ded*(1+mar),0.0);
	
	city_taxgross = city_taxble*cur_tax_params.city_atr;
	stax = state_taxble*cur_tax_params.state_atr;
	
	city_tc = cur_tax_params.city_tc_mtr1*std::min(cur_tax_params.city_tc_thres1,city_taxgross)
							+ cur_tax_params.city_tc_mtr2*std::min(cur_tax_params.city_tc_thres2 - cur_tax_params.city_tc_thres1,std::max(city_taxgross - cur_tax_params.city_tc_thres1,0.0)) 
							+ cur_tax_params.city_tc_mtr3*std::max(city_taxgross - cur_tax_params.city_tc_thres2,0.0); 
	ctax = std::max(city_taxgross - city_tc,0.0); 		

}


void GovExpModule::SsTax(double ry_earn, double &rtax, double &rmed, tax_params& cur_tax_params) {

     ///Social security taxes and other contributions
	 rtax = cur_tax_params.oasi_tr*std::min(ry_earn,cur_tax_params.stax_max);
	 rmed = cur_tax_params.medc_tr*(ry_earn);
}



