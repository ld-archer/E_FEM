#include "GlobalPreInitializationModule.h"
#include "Logger.h"
#include "SummaryModule.h"
#include "utility.h"
#include <math.h>
#include <sstream>
#include "fem_exception.h"

GlobalPreInitializationModule::GlobalPreInitializationModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider)
{
	medicare_elig_var = vp->get("medicare_eligibility");
	nwi = timeSeriesProvider->get("nwi");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");

}

GlobalPreInitializationModule::~GlobalPreInitializationModule(void)
{
}



void GlobalPreInitializationModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);
	if(scen->get("psid_data")=="1")
		ref_year = 2009;
	else
		ref_year = 2010;
}

void GlobalPreInitializationModule::process(PersonVector& persons, unsigned int year, Random* random) {

	Logger::log("Running Global Pre-Initialization Module", FINE);
 	int simu_type = scenario->SimuType();

	// Scaling in CPI and NWI
	double delta_cpi = 1.0;
	for(unsigned int i = ref_year; i <= year; i++)
	  delta_cpi *= (1 + cpi_yearly->Value(i));

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* p = *itr;
		// Only initialize just added persons
		if(p->get(Vars::entry) == year)  {
		  p->set(Vars::active, true);

		  // Set the variable to track the current MC rep
		  p->set(Vars::mcrep, random->rep());

			// Some special handling for base cohort
			if(year == scenario->StartYr()) {
				// First year claiming DB benefits
				if(simu_type != 2 && !p->test(Vars::died)) {
					p->set(Vars::rdbclyr, p->test(Vars::dbclaim) ? (double)scenario->StartYr() : 2100.0);
				}

				if (!p->test(Vars::died))
					p->set(Vars::year, (double)scenario->StartYr());
			}

			// Need to make sure all marital status dummies are set correctly
            // current marital status dummies
            p->set(Vars::married, p->get(Vars::mstat) == 1);
            p->set(Vars::single, p->get(Vars::mstat) == 2);
            p->set(Vars::cohab, p->get(Vars::mstat) == 3);
            p->set(Vars::widowed, p->get(Vars::mstat) == 4);
            if(p->test(Vars::married) || p->test(Vars::cohab)) {
                p->set(Vars::widowed, false);
            }

            // lag marital status dummies
            p->set(Vars::l2married, p->get(Vars::l2mstat) == 1);
            p->set(Vars::l2single, p->get(Vars::l2mstat) == 2);
            p->set(Vars::l2cohab, p->get(Vars::l2mstat) == 3);
            p->set(Vars::l2widowed, p->get(Vars::l2mstat) == 4);
            if(p->test(Vars::l2married) || p->test(Vars::l2cohab)) {
                p->set(Vars::l2widowed, false);
            }


			// If this is a married dead person, then if the spouse died before them set to them to widowed
			if(p->test(Vars::died) && p->test(Vars::married) && p->getSpouse() != NULL) {
				if(p->getSpouse()->test(Vars::died) && p->getSpouse()->getYear() < p->getYear() ) {
					p->set(Vars::married, false);
					p->set(Vars::widowed, true);
				}
			}

			// By default, set everyone not to be in medicare
			p->set(Vars::mcare_pta_enroll, false);
			p->set(Vars::mcare_ptb_enroll, false);
			p->set(Vars::mcare_ptd_enroll, false);

			// No one should have premiums calculated yet
			p->set_missing(Vars::mcare_ptb_premium);

			// Not treated with Bariatric Surg yet
			if(p->is_missing(Vars::bs_treated)) {
				p->set(Vars::bs_treated, false);
				p->set(Vars::l2bs_treated, false);
			}

			// Not treated with Weight Loss Pill yet
			if(p->is_missing(Vars::wlp_treated)) {
				p->set(Vars::wlp_treated, false);
				p->set(Vars::l2wlp_treated, false);
			}

			// Not treated yet with any intervention
			p->set(Vars::treat_effective, false);
			p->set(Vars::treat_now, false);


			// Set lag(died) to true only if the person is dead and the year of death is less than this year
			p->set(Vars::l2died, p->test(Vars::died) && p->get(Vars::year) < year);

			// For persons who are already dead, set their QALY to zero
			if(p->test(Vars::died)) p->set(Vars::qaly, 0.0);

			// Set lag cogstate to normal if missing
			// was if(p->get(Vars::age) < 65 || (p->get(Vars::weight) < .01 && p->is_missing(Vars::cogstate))) {
			//if(p->is_missing(Vars::cogstate)) {
			//	p->set(Vars::cogstate, 3);
			//	p->set(Vars::l2cogstate, 3);
			//}
			//if(p->is_missing(Vars::l2cogstate))
			//  p->set(Vars::l2cogstate, p->get(Vars::cogstate) < 3 ? p->get(Vars::cogstate) : 3);

			if(p->is_missing(Vars::memrye))
				p->set(Vars::memrye, false);

			if(p->is_missing(Vars::l2memrye))
				p->set(Vars::l2memrye, false);

			// Haven't calculated taxes, so we don't have an AGI for anyone yet
			p->set(Vars::agi, 0.0);

			//p->set(Vars::cogstate1, p->get(Vars::cogstate) == 1);
			//p->set(Vars::cogstate2, p->get(Vars::cogstate) == 2);
			//p->set(Vars::cogstate3, p->get(Vars::cogstate) == 3);

			//p->set(Vars::l2cogstate1, p->get(Vars::l2cogstate) == 1);
			//p->set(Vars::l2cogstate2, p->get(Vars::l2cogstate) == 2);
			//p->set(Vars::l2cogstate3, p->get(Vars::l2cogstate) == 3);

			p->set(Vars::pcancre, 0.0);
			p->set(Vars::pdiabe,0.0);
			p->set(Vars::phearte,0.0);
			p->set(Vars::phibpe,0.0);
			p->set(Vars::plunge,0.0);
			p->set(Vars::pstroke,0.0);
      p->set(Vars::phearta,0.0);

			// Initialize afibe
			if(p->is_missing(Vars::afibe) && afibe_prev_model != NULL) {
			  afibe_prev_model->predict(p, random);
			}
			if(p->is_missing(Vars::l2afibe) && !p->is_missing(Vars::afibe))
			  p->set(Vars::l2afibe, p->get(Vars::afibe));

			// Predict missing education
			if(p->is_missing(Vars::educ) && educ_model != NULL) {
				educ_model->predict(p, random);
				// Accounting for hsless and college
				if(p->get(Vars::educ) == 1) {
					p->set(Vars::hsless, 1.0);
				}
				else if(p->get(Vars::educ) == 3) {
					p->set(Vars::college, 1.0);
				}
			}

			// Do not do the following for persons that are dead already
			if (!p->test(Vars::died)) {
				/*
				// Scale up AIME based on NWI(year)/NWI(start_year)
				p->set(Vars::raime, p->get(Vars::raime)*delta_nwi);
				*/
				const double work = p->get(Vars::work);

				const double fiearnuc = p->get(Vars::iearnuc)*work;
				p->set(Vars::flogiearnuc, arcsinh(fiearnuc)/100.0);

				// Scale up earnings based on NWI(year)/NWI(start_year)
  			const double iearn = p->get(Vars::iearnx)*work;
				// Recalulate various earnings variables with the new scaled up earnings
				const double iearnx = std::max(std::min(200.0, iearn),0.0);
				const double logiearn = arcsinh(iearn)/100.0;
				const double logiearnx = arcsinh(iearnx)/100.0;

				// Mimicing the above for uncapped earnings
				const double iearnuc = p->get(Vars::iearnuc)*work;
				const double logiearnuc = arcsinh(iearnuc)/100.0;

				// Set the earnings variables for the current/lag/initial to be all the same for earnings
				p->set(Vars::iearn, iearn);
				p->set(Vars::iearnx, iearnx);
				p->set(Vars::l2iearnx, iearnx);

				p->set(Vars::iearnuc, iearnuc);
				p->set(Vars::l2iearnuc, iearnuc);

				p->set(Vars::logiearnuc, logiearnuc);
				p->set(Vars::l2logiearnuc, logiearnuc);

				p->set(Vars::logiearn, logiearn);
				p->set(Vars::l2logiearn, logiearn);

				p->set(Vars::logiearnx, logiearnx);
				p->set(Vars::l2logiearnx, logiearnx);

				p->set(Vars::l2died, 0.0);

			}

			// Update marital status for dead persons with missing marital status to be consistent
			if(p->test(Vars::died)) {
				if(p->getSpouse() != NULL) {
					// If there is a living spouse, then the person must have died married if there is no other info
					p->set(Vars::married, p->is_missing(Vars::married) ? true : p->test(Vars::married));
					p->set(Vars::single, p->is_missing(Vars::single) ? false : p->test(Vars::single));
					p->set(Vars::widowed, p->is_missing(Vars::widowed) ? false : p->test(Vars::widowed));
				} else {
					// The person did not have a spouse at death. If we dont know anything else about them, then most likely they were single
					p->set(Vars::married, p->is_missing(Vars::married) ? false : p->test(Vars::married));
					p->set(Vars::single, p->is_missing(Vars::single) ? true : p->test(Vars::single));
					p->set(Vars::widowed, p->is_missing(Vars::widowed) ? false : p->test(Vars::widowed));
				}
			}


			// Do the following for both dead and alive persons we just read in

			// If we dont know when the person claimed SS, then just assume they havent
			if(p->is_missing(Vars::rssclyr))
				p->set(Vars::rssclyr, 2100);

			// If the claiming year is in the past, and ssclaim is missing, then set it, otherwise unset it
			if(p->is_missing(Vars::ssclaim))
				p->set(Vars::ssclaim, p->get(Vars::rssclyr) <= year);


			// SS Claiming age
			p->set(Vars::ssage, p->test(Vars::ssclaim) ? p->get(Vars::rssclyr) - p->get(Vars::rbyr) : 1000.0);

			// No one is claiming SS widows benefits yet - Assigned in cross-sectional module
			if(p->is_missing(Vars::rsswclyr))
				p->set(Vars::rsswclyr, 2100);
			if(p->get(Vars::rsswclyr) == 2100)
				p->set(Vars::sswclaim, false);

			// If we dont know when the person claimed DB, then just assume they havent
			if(p->is_missing(Vars::rdbclyr))
				p->set(Vars::rdbclyr, 2100);

			// If they havent claimed DB, then mark it
			if(p->get(Vars::rdbclyr) == 2100)
				p->set(Vars::dbclaim, false);


			// If the DB claiming year is in the past, and dbclaim is missing, then set it, otherwise unset it
			if(p->is_missing(Vars::dbclaim))
				p->set(Vars::dbclaim, p->get(Vars::rdbclyr) <= year);

			// DB Claiming age
			p->set(Vars::dbage, p->test(Vars::dbclaim) ? p->get(Vars::rdbclyr) - p->get(Vars::rbyr) : 1000.0);

			p->set(Vars::alzhmr, false);

			p->set(Vars::cum_totmd, 0.0);

			double gross = p->get(Vars::iearnx)*1000;
			if(p->getSpouse() != NULL && p->test(Vars::married)) {
			  Person* s = p->getSpouse();
			  gross += s->get(Vars::iearnx)*1000;
			}
			p->set(Vars::gross, gross);

			// Set initial medicare premiums to missing
			p->set_missing(Vars::fmcare_pta_premium);
			p->set_missing(Vars::fmcare_ptb_premium);

			// Set initial rdd_treated and ssi_treated vars to false
			p->set(Vars::rdd_treated, false);
			p->set(Vars::ssi_treated, false);
		}
	}
}



void GlobalPreInitializationModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;

	std::string model_name;

	try {
	  afibe_prev_model = mp->get("afibe_prev");
	} catch (const fem_exception & e) {
	  afibe_prev_model = NULL;
	  Logger::log("Global Pre-Initialization Module could not find the afibe_prev model\n", WARNING);
  	}

	try {
	  educ_model = mp->get("educ");
	} catch (const fem_exception & e) {
	  educ_model = NULL;
	  Logger::log("Global Pre-Initialization Module could not find the educ model\n", WARNING);
  	}

	if(ss.str().length() > 0)
	  throw fem_exception(ss.str().c_str());
}
