#include "EconGenModule.h"
#include "EconGenModule.h"
#include <math.h>
#include "Logger.h"

EconGenModule::EconGenModule(ITimeSeriesProvider* timeSeriesProvider)
{
	
//	nra = timeSeriesProvider->get("nra");
	nwi = timeSeriesProvider->get("nwi");

	// Init db_type
	// sex, era, nra
	db_type[0][45][55] = 9.588;
	db_type[0][45][60] = 9.021;
	db_type[0][45][65] = 7.568;
	db_type[0][50][55] = 9.244;
	db_type[0][50][60] = 8.913;
	db_type[0][50][65] = 8.49;
	db_type[0][55][55] = 9.094;
	db_type[0][55][60] = 8.887;
	db_type[0][60][60] = 8.798;
	db_type[0][60][65] = 8.269;
	db_type[0][55][65] = 8.341;

	db_type[1][45][55] = 10.131;
	db_type[1][45][60] = 9.712;
	db_type[1][45][65] = 8.937;
	db_type[1][50][55] = 9.834;
	db_type[1][50][60] = 9.494;
	db_type[1][50][65] = 9.184;
	db_type[1][55][55] = 9.676;
	db_type[1][55][60] = 9.386;
	db_type[1][60][60] = 9.344;
	db_type[1][60][65] = 8.886;
	db_type[1][55][65] = 8.944;

}

EconGenModule::~EconGenModule(void)
{
}

void EconGenModule::setModelProvider(IModelProvider* modp) {
  mp = modp;
  
  try {
    proptax_model = mp->get("proptax");
  } catch (fem_exception& e) {
    throw fem_exception("EconGenModule cannot find the required proptax model");
  }
  
}

void EconGenModule::process(PersonVector& persons, unsigned int year, Random* random) {
	Logger::log("Running Economics Module", FINE);

	std::vector<Person*>::iterator itr;
	double delta_nwi = -1;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
		  delta_nwi = nwi->Value(year-scenario->YrStep()) / nwi->Value(year - scenario->YrStep()*2.0);
			//  For now, including grandkid care hours logic here
			if(person->get(Vars::fkids) == 0) 
				 person->set(Vars::gkcarehrs, 0);
				 	
				 	
			// Also adding logic for assigning spousal help hours here
			if(person->test(Vars::married))
				{
					const Person* spouse = person->getSpouse();
					const int spouse_help = (int) spouse->get(Vars::helphoursyr_sp);
					person->set(Vars::help_to_spouse,spouse_help);
									}
			else
				{ 
				person->set(Vars::help_to_spouse,0);
				person->set(Vars::helphoursyr_sp,0);
				}	
				
			double age = person->get(Vars::age);

			// Setting nra_eligible variable (eligible for normal retirement Social Security)
	/*		int rbyr = (int) person->get(Vars::rbyr);
			if( age > nra->Value(rbyr)/12.0) {
					person->set(Vars::nra_elig, 1);
				}
			else
				person->set(Vars::nra_elig, 0);
		*/
					
			if(person->test(Vars::ssclaim) && person->get(Vars::rssclyr) == 2100)
				person->set(Vars::rssclyr, year);

			if(person->test(Vars::sswclaim) && person->get(Vars::rsswclyr) == 2100)
				person->set(Vars::rsswclyr, year);

			if(person->test(Vars::dbclaim) && person->get(Vars::rdbclyr) == 2100)
				person->set(Vars::rdbclyr, year);

			// Does this person have non-zero property taxes?
			if(person->test(Vars::proptax_nonzero)) {
			  proptax_model->predict(person, random);
			}
			else
			  person->set(Vars::proptax, 0);

			// Update year of claiming SS, claiming DB
			const double ssage = person->get(Vars::ssclaim) == 1 && person->get(Vars::ssage) == 1000 ? age : person->get(Vars::ssage);
			person->set(Vars::ssage, ssage);

			const double dbage = person->get(Vars::dbclaim) == 1 && person->get(Vars::dbage) == 1000 ? age : person->get(Vars::dbage);
			person->set(Vars::dbage, dbage);

			// Rescale earnings and HH wealth
			person->set(Vars::ry_earn, person->is_missing(Vars::iearnx) ? 0.0 : person->get(Vars::iearnx) * 1000);
			person->set(Vars::hhwealth, person->is_missing(Vars::hatotax) ? 0.0 : person->get(Vars::hatotax) * 1000);
		    // Bryan's addition - trying to make an uncapped ry_earn variable
			person->set(Vars::ry_earnuc, person->is_missing(Vars::iearnuc) ? 0.0 : person->get(Vars::iearnuc) * 1000);
		
					
			// Update db tenure
			if (person->test(Vars::work) && person->test(Vars::fanydb)) {
				person->set(Vars::db_tenure, person->get(Vars::db_tenure) + scenario->YrStep());
			}

			if (person->get(Vars::year) > scenario->StartYr()) {
				
				// Rescale the AIME by the increase in the NWI, if the person is not yet 62 years old
				if(person->get(Vars::age) <= 62)
					person->set(Vars::raime, person->get(Vars::raime)*delta_nwi);

				// Update AIME and quarters worked
				double faime = updateAIME(
					person->get(Vars::raime),
					person->get(Vars::ry_earn),
					person->get(Vars::age) - scenario->YrStep(),
					person->test(Vars::male),
					year);

				if (person->test(Vars::work) && !person->test(Vars::ssclaim)) {
					person->set(Vars::raime, faime);
				}

				

				// Update Quarters worked
				if (person->test(Vars::work)) {
					person->set(Vars::rq, person->get(Vars::rq) + scenario->YrStep() * 4.0);
				}

			}

			// DB pension benefits
			// Tenure (need to construct the variable first)
			double dbpen = DbBenefit(
				(double)person->get(Vars::ry_earn),
				(double)person->get(Vars::db_tenure),
				(double)person->get(Vars::educ),
				person->get(Vars::age),
				(int)person->get(Vars::era),
				(int)person->get(Vars::nra),
				year,
				(bool)person->test(Vars::male));
			person->set(Vars::dbpen, dbpen);

		}

	}
	/*
	********************************
	* HH income: Other, asset income and total income
	* Not account for SS benefits, DI benefis, DB pension benefits
	* Put capital income and other income as zero, hh income only include earnings+OASI+DI+SSI+DB pension
	********************************	
	* Other income (other than earnings, OASDI, SSI, DB pension income, asset return)
	*/
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
		  person->set(Vars::hhearn, person->get(Vars::ry_earn) + ((person->getSpouse() != NULL && !person->getSpouse()->test(Vars::l2died) && person->getSpouse()->test(Vars::active)) ? person->getSpouse()->get(Vars::ry_earn) : 0.0));

			// Total HH income
			person->set(Vars::hhttlinc, person->get(Vars::hhearn));
		}
	}

	

}

double EconGenModule::updateAIME(double aime, double ry_earn, double age, bool male, unsigned int yr) const {

	double nwiyr = nwi->Value(1992) / nwi->Value(yr);

	// Use NWI to adjust current AIME and earnings
	aime *= nwiyr;
	ry_earn *= nwiyr;

	/// 2.A Loading Parameters -------------------

	double m = log(aime);
	double e = log(ry_earn);
	double a = age;
	double m2 = m * m;
	double e2 = e * e;
	double a2 = a * a;
	double me = m * e;
	double am = a * m;
	double ae = a * e;
	double a3 = a2 * a;
	double m3 = m2 * m;
	double e3 = e2 * e;
	double ame = a * m * e;
	double am2 = a * m2;
	double ae2 = a * e2;
	double a2m = a2 * m;
	double a2e = a2 * e;
	double m2e = m2 * e;
	double e2m = e2 * m;
	double cons = 1;

	double x[] = {cons, m, e, a, m2, e2, a2, me, am, ae, a3, m3, e3, ame, am2, ae2, a2m, a2e, m2e, e2m};

	static const double betas_f[] = {
		-0.6428344,
		0.956511,
		-0.0148539,
		0.0404891,
		0.0095312,
		0.0102989,
		-0.0008079,
		-0.0139591,
		0.0032182,
		-0.0016385,
		5.02E-06,
		-0.0070748,
		0.0039112,
		0.0000205,
		-0.0003838,
		0.0001103,
		0.000011,
		-5.75E-06,
		0.0190655,
		-0.0155299};

		static const double betas_m[] = {
			1.736857,
			0.6951943,
			0.00041,
			-0.0685375,
			0.0407903,
			0.0191816,
			0.0007148,
			-0.0479509,
			0.0101093,
			0.0000246,
			-5.85E-06,
			-0.006154,
			0.0019137,
			-0.0004902,
			-0.000729,
			0.0002401,
			0.0000348,
			-8.00E-06,
			0.0158903,
			-0.0099898};

			static const int NCOEFFS = 20;



			/// Generating Prediction
			double faime = 0.0;
			for (int i = 0; i < NCOEFFS; i++) {
				faime += x[i] * (male ? betas_m[i] : betas_f[i]);
			}


			double diff = std::max(std::min(faime - m, 0.25), 0.0);
			faime = ry_earn != 0 ? exp(m + diff) : aime;

			// Rescale the new AIME back to the current year
			return faime / nwiyr;

}

double EconGenModule::DbBenefit(double ry_earn, double tenure, double edu, double age, int era, int nra, unsigned int yr, bool sex) const {
	
	// Setup means for men and women
	static const double mean_f[] = {
		10.104,
		19.468,
		2.142,
		0.052,
		0.336,
		37.357,
		1487.887};

	static const double mean_m[] = {
		10.561,
		23.138,
		1.956,
		0.115,
		0.303,
		34.012,
		1277.413};

	static const int N_mean = 7;


	// Setup pars for men and women
	static const double pars_f[] = {
		0.986445,
		0.084910,
		0.038673,
		-0.204026,
		0.111589,
		0.117000,
		-0.000943,
		1.000};
	
	static const double pars_m[] = {
		1.08835,
		0.07272,
		0.03849,
		-0.10443,
		0.01962,
		0.11168,
		-0.00093,
		1.000};

	static const int N_pars = 8;

	const double* mean = sex ? mean_m : mean_f;
	const double* pars = sex ? pars_m : pars_f;
/*
	static const double pars[] = {
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1.000};
*/	

	double age_s, age_s2, logearn, ten_bnra, ten_anra, edu1, edu3, type;

	// Calculating variables of interest
	age_s = age-tenure;
	age_s2 = age_s*age_s;
	logearn = log(ry_earn);
	if(age < nra) 
		ten_bnra = tenure;
	else 
		ten_bnra = nra-age_s;
	if(age > nra)
		ten_anra = age-nra;
	else
		ten_anra = 0;
	edu1 = edu==1;	
	edu3 = edu==3;

	double* x[] = {&logearn, &ten_bnra, &ten_anra, &edu1, &edu3, &age_s, &age_s2};

	for(int i = 0; i < N_mean; i++)
		*(x[i]) -= mean[i];

	// recode era and nra
	int era_c, nra_c;
	if(era <=  47)
		era_c = 45;
	else if (era <= 52)
		era_c = 50;
	else if (era <= 57)
		era_c = 55;
	else
		era_c = 60;

	if(nra <=  57)
		nra_c = 55;
	else if (nra <= 62)
		nra_c = 60;
	else
		nra_c = 65;

	type = db_type.at(sex ? 1 : 0).at(era_c).at(nra_c);

	double y[] = {logearn, ten_bnra, ten_anra, edu1, edu3, age_s, age_s2, type};

	// Generating Prediction
	double dbben = 0;
	for(int i = 0; i < N_pars; i++)
		dbben += y[i]*pars[i];
	return exp(dbben)*(age >= era);
}
