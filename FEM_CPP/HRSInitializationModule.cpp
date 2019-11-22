#include "HRSInitializationModule.h"
#include "Logger.h"
#include "utility.h"
#include <sstream>

HRSInitializationModule::HRSInitializationModule(IVariableProvider* vp, ITimeSeriesProvider* tsp) {
  variable_provider = vp;
  timeSeriesProvider = tsp;
  
 	nwi = timeSeriesProvider->get("nwi");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");
}

HRSInitializationModule::~HRSInitializationModule() { }

void HRSInitializationModule::setScenario(Scenario* scen) {
  Module::setScenario(scen);
	ref_year = 2010;
}

void HRSInitializationModule::process(PersonVector& persons, unsigned int year, Random* random) {
  enabled = (variable_provider->get("hrs_data")->value() == 1);
  if(enabled) {
    Logger::log("Running HRS Initialization Module", FINE);
   	int simu_type = scenario->SimuType();
   	// Scaling in CPI and NWI
		double delta_cpi = 1.0;
		for(unsigned int i = ref_year; i <= year; i++)
	  	delta_cpi *= (1 + cpi_yearly->Value(i));
 		const double delta_nwi = nwi->Value(year)/nwi->Value(ref_year);

   	std::vector<Person*>::iterator itr;
		for(itr = persons.begin(); itr != persons.end(); ++itr) {
			Person* p = *itr;
			// Only initialize just added persons
			if(p->get(Vars::entry) == year)  {
				
				// Some special handling for base cohort 
				if(year == scenario->StartYr()) {
					// Initial AIME
					if(simu_type == 2 || simu_type == 3) {
						p->set(Vars::raime,  p->get(Vars::fraime));
					}
				}
				
				// If they havent claimed SS, then mark it - This should be assessed.
				// if(p->get(Vars::rssclyr) == 2100)
				//	p->set(Vars::ssclaim, false);

				// Set missing hearta and heartae to zero for those who are deceased at simulation start
				if(p->test(Vars::died) & p->is_missing(Vars::hearta))
				p->set(Vars::hearta, p->get(Vars::l2hearta));

				// Initialize the start/stop variables for cholesterol treatment

				if(p->test(Vars::died) & p->is_missing(Vars::rxchol))
				p->set(Vars::rxchol, 0.0);
				if(p->is_missing(Vars::l2rxchol))
				p->set(Vars::l2rxchol, 0.0);

				p->set(Vars::rxchol_start,0.0);
				p->set(Vars::rxchol_stop,0.0);


				// Initial quarters of earnings
				p->set(Vars::frq, p->get(Vars::rq));

				// Set up the functional status indicators
				p->set(Vars::iadl1, p->get(Vars::iadlstat) == 2);
				p->set(Vars::iadl2p, p->get(Vars::iadlstat) == 3);
	
				p->set(Vars::adl1, p->get(Vars::adlstat) == 2);
				p->set(Vars::adl2, p->get(Vars::adlstat) == 3);
				p->set(Vars::adl3p, p->get(Vars::adlstat) == 4);
	
				p->set(Vars::l2iadl1, p->get(Vars::l2iadlstat) == 2);
				p->set(Vars::l2iadl2p, p->get(Vars::l2iadlstat) == 3);
	
				p->set(Vars::l2adl1, p->get(Vars::l2adlstat) == 2);
				p->set(Vars::l2adl2, p->get(Vars::l2adlstat) == 3);
				p->set(Vars::l2adl3p, p->get(Vars::l2adlstat) == 4);
				
				if(p->is_missing(Vars::cogstate)) p->set(Vars::cogstate, 3);	
				p->set(Vars::cogstate1, p->get(Vars::cogstate) == 1);
				p->set(Vars::cogstate2, p->get(Vars::cogstate) == 2);
				p->set(Vars::cogstate3, p->get(Vars::cogstate) == 3);	
	
				if(p->is_missing(Vars::selfmem)) p->set(Vars::selfmem, 1);	
				p->set(Vars::selfmem1, p->get(Vars::selfmem) == 1);
				p->set(Vars::selfmem2, p->get(Vars::selfmem) == 2);
				p->set(Vars::selfmem3, p->get(Vars::selfmem) == 3);

				if(p->is_missing(Vars::l2cogstate)) p->set(Vars::l2cogstate, 3);	
				p->set(Vars::l2cogstate1, p->get(Vars::l2cogstate) == 1);
				p->set(Vars::l2cogstate2, p->get(Vars::l2cogstate) == 2);
				p->set(Vars::l2cogstate2, p->get(Vars::l2cogstate) == 3);
	
				if(p->is_missing(Vars::l2selfmem)) p->set(Vars::l2selfmem, 1);	
				p->set(Vars::l2selfmem1, p->get(Vars::l2selfmem) == 1);
				p->set(Vars::l2selfmem2, p->get(Vars::l2selfmem) == 2);
				p->set(Vars::l2selfmem3, p->get(Vars::l2selfmem) == 3);			
					
				if(p->is_missing(Vars::alzhe)) p->set(Vars::alzhe, 0);
				if(p->is_missing(Vars::l2alzhe)) p->set(Vars::l2alzhe, 0);					

				if(p->is_missing(Vars::painstat)) painstat_model->predict(p, random);
				p->set(Vars::painmild, p->get(Vars::painstat) == 2);
				p->set(Vars::painmoderate, p->get(Vars::painstat) == 3);
				p->set(Vars::painsevere, p->get(Vars::painstat) == 4);	
					
				if(p->is_missing(Vars::l2painstat)) p->set(Vars::l2painstat, p->get(Vars::painstat));
				p->set(Vars::l2painmild, p->get(Vars::l2painstat) == 2);
				p->set(Vars::l2painmoderate, p->get(Vars::l2painstat) == 3);
				p->set(Vars::l2painsevere, p->get(Vars::l2painstat) == 4);				

				// Initialize the property tax binary
				// The taxes will automatically be calculated in the EconGen model
				if(p->test(Vars::died) & p->is_missing(Vars::proptax_nonzero))
				  p->set(Vars::proptax_nonzero, false);

				p->set(Vars::l2proptax_nonzero, p->get(Vars::proptax_nonzero));
				if(p->is_missing(Vars::proptax_nonzero))
				  proptax_nonzero_model->predict(p, random);

				if(!p->test(Vars::proptax_nonzero)) p->set(Vars::proptax, 0);
				if(p->is_missing(Vars::l2proptax))
				  p->set(Vars::l2proptax, p->get(Vars::proptax));

				// Just need to initialize this here. Could have done it in Stata, but this is cleaner
				p->set(Vars::tcamt_cpl, p->get(Vars::htcamt) / (p->get(Vars::married) + 1));
				p->set(Vars::l2tcamt_cpl, p->get(Vars::tcamt_cpl));
				p->set(Vars::l2tcamt_cpl, p->get(Vars::l2tcamt_cpl) /(p->get(Vars::l2married) + 1));

				// Initialize the igxfr variables //
				if(p->is_missing(Vars::igxfr_nonzero))
				  igxfr_nonzero_model->predict(p, random);
				if(p->test(Vars::igxfr_nonzero)) {
				  igxfr_model->predict(p, random);
				}
				else 
				  p->set(Vars::igxfr, 0.0);
		
				// p->set(Vars::igxfr_nonzero,0);
				// p->set(Vars::igxfr,0);

				// Do not do the following for persons that are dead already 
				if (!p->test(Vars::died)) {
					// Scale up AIME based on NWI(year)/NWI(start_year)
					p->set(Vars::raime, p->get(Vars::raime)*delta_nwi);

					const double wlth_nonzero = p->get(Vars::wlth_nonzero);
				
					// Rescale Wealth based on CPI(year)/CPI(start_year)
					const double hatota = p->get(Vars::hatota)*delta_cpi*wlth_nonzero;			
					// Recalulate various wealth variables with the new scaled up wealth
					const double hatotax = std::min(2000.0, hatota);
					const double loghatota = arcsinh(hatota)/100.0;
					const double loghatotax = arcsinh(hatotax)/100.0;
	
					// Set the earnings variables for the current/lag/initial to be all the same for earnings
					p->set(Vars::hatota, hatota);
					p->set(Vars::hatotax, hatotax);
					p->set(Vars::l2hatotax, hatotax);
					
					p->set(Vars::loghatota, loghatota);
					p->set(Vars::l2loghatota, loghatota);
					
					p->set(Vars::loghatotax, loghatotax);
					p->set(Vars::l2loghatotax, loghatotax);
				}
				
				hicap_nonzero_model->predict(p, random);
    		p->set(Vars::l2hicap_nonzero, p->get(Vars::hicap_nonzero));
				if(p->test(Vars::hicap_nonzero)) {
		  		hicap_model->predict(p, random);
	  			p->set(Vars::hicap, p->get(Vars::hicap) * delta_cpi);
      		p->set(Vars::l2hicap, p->get(Vars::hicap));
				} else {
			  	p->set(Vars::hicap, 0.0);
      		p->set(Vars::l2hicap, 0.0);
				}
			}
		}
  }
}

void HRSInitializationModule::setModelProvider(IModelProvider* mp) {
  enabled = (variable_provider->get("hrs_data")->value() == 1);
  if(enabled) {
	  std::ostringstream ss;
		
		std::string model_name;
		try {
		  hicap_model = mp->get("hicap");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could not find the hicap model\n";
		}
		try {
		  hicap_nonzero_model = mp->get("hicap_nonzero");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could nto find the hicap_nonzero model\n";
		}
		try {
		  igxfr_nonzero_model = mp->get("igxfr_nonzero");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could not find the igxfr_nonzero model\n";
		}
		try {
		  igxfr_model = mp->get("igxfr");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could not find the igxfr model\n";
		}
	
		try {
		  proptax_nonzero_model = mp->get("proptax_nonzero");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could not find the proptax_nonzero model\n";
		}
			
		try {
		  painstat_model = mp->get("painstat");
		} catch (const fem_exception & e) {
		  ss << "HRS Initialization Module could not find the required painstat model\n";
		}
	
		if(ss.str().length() > 0)
		  throw fem_exception(ss.str().c_str());
	}
}
