#include "PSIDInitializationModule.h"
#include "Logger.h"
#include "utility.h"
#include <sstream>

PSIDInitializationModule::PSIDInitializationModule(IVariableProvider* vp, ITimeSeriesProvider* tsp) {
  variable_provider = vp;
  timeSeriesProvider = tsp;
  
  cpi_yearly = timeSeriesProvider->get("cpi.yearly");
}

PSIDInitializationModule::~PSIDInitializationModule() { }

void PSIDInitializationModule::setScenario(Scenario* scen) {
  Module::setScenario(scen);
  ref_year = 2009;
}

void PSIDInitializationModule::process(PersonVector& persons, unsigned int year, Random* random) {
  enabled = (variable_provider->get("psid_data")->value() == 1);
  if(enabled) {
    Logger::log("Running PSID Initialization Module", FINE);


   	// Scaling in CPI
		double delta_cpi = 1.0;
		for(unsigned int i = ref_year; i <= year; i++)
	  	delta_cpi *= (1 + cpi_yearly->Value(i));

    std::vector<Person*>::iterator itr;
		for(itr = persons.begin(); itr != persons.end(); ++itr) {
			Person* p = *itr;
			// Only initialize just added persons
			if(p->get(Vars::entry) == year)  {
				
				/*// Assume married if single but spouse is present
				if(p->getSpouse() != NULL && p->get(Vars::mstat_new) == 1)
					p->set(Vars::mstat_new, 3);*/
					
				/*// current marital status dummies
				p->set(Vars::married, p->get(Vars::mstat_new) == 3);
				p->set(Vars::cohab, p->get(Vars::mstat_new) == 2);
				p->set(Vars::single, p->get(Vars::mstat_new) == 1);
				if(p->test(Vars::married) || p->test(Vars::cohab))
					p->set(Vars::widowed, false);*/

				/*// lag marital status dummies
				p->set(Vars::l2married, p->get(Vars::l2mstat_new) == 3);
				p->set(Vars::l2cohab, p->get(Vars::l2mstat_new) == 2);
				if(p->test(Vars::l2married) || p->test(Vars::l2cohab))
					p->set(Vars::l2widowed, false);*/

				/*// marital status "ever" variables
				if(p->test(Vars::widowed) || p->test(Vars::l2widowed))
					p->set(Vars::widowev, true);

				if(p->test(Vars::l2married))
					p->set(Vars::l2everm, true);*/

				// currently married or previously ever married => married at some point
				//p->set(Vars::everm, p->test(Vars::married) || p->test(Vars::l2everm));

				/*if(p->test(Vars::l2everm) && p->get(Vars::l2mstat_new) != 3)
					// lag ever married but not lag married => separated at some point
					p->set(Vars::l2eversep, true);

				if(p->test(Vars::l2eversep) || (p->get(Vars::l2mstat_new) != 1 && p->get(Vars::mstat_new) == 1))
					// lag ever seperated or just seperated => separated at some point
					p->set(Vars::eversep, true);
							
				if(p->test(Vars::everm) && p->get(Vars::mstat_new) != 3)
					// ever married but not married now => separated at some point
					p->set(Vars::eversep, true);
						
			 	if(!p->test(Vars::l2eversep) && p->get(Vars::mstat_new) != 1)
			 		// lag never separated and currently partnered => never seperated
			 		p->set(Vars::eversep, false);*/


				/*if(p->is_missing(Vars::partdied)) {
					if(p->get(Vars::mstat_new) != 1)
						p->set(Vars::partdied, false);
					if(p->get(Vars::l2mstat_new) == 3)
						p->set(Vars::partdied, p->test(Vars::widowed));		
				}		
				if(p->is_missing(Vars::l2partdied)) {
					if(p->get(Vars::l2mstat_new) != 1)
						p->set(Vars::l2partdied, false);
				}*/

				/* Set earnings to 0 for those out of labor force or unemployed */
				if(p->get(Vars::workcat )== 1 || p->get(Vars::workcat) == 2){
					p->set(Vars::iearnx, 0);
				}	
				
					
				// Initialize more_educ ... this is assigned in the education model, which isn't run for new cohorts
				p->set(Vars::more_educ, 0);	
					
				// Initialize l2iearn to iearn	
				p->set(Vars::l2iearn, p->get(Vars::iearn));        
					
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
				  	
				  	
				// SSI, DI, OA, and Survivor benefits not populated in our PSID data before 2005, so initialize here if missing
				if(p->test(Vars::diclaim)) {
				  if(p->is_missing(Vars::ssdiamt))
				  ssdiamt_model->predict(p, random);
				}
				else {
				  if(p->is_missing(Vars::ssdiamt))
				  p->set(Vars::ssdiamt, 0.0); 	
				}  	
				
				if(p->test(Vars::ssiclaim)) {
				  if(p->is_missing(Vars::ssiamt))
				  ssiamt_model->predict(p, random);
				}
				else {
				  if(p->is_missing(Vars::ssiamt))
				  p->set(Vars::ssiamt, 0.0); 	
				}  	

				if(p->test(Vars::oasiclaim)) {
				  if(p->is_missing(Vars::ssoasiamt))
				  ssoasiamt_model->predict(p, random);
				}
				else {
				  if(p->is_missing(Vars::ssoasiamt))
				  p->set(Vars::ssoasiamt, 0.0); 	
				}  	
				

				// Do not do the following for persons that are dead already 
				if (!p->test(Vars::died)) {
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

void PSIDInitializationModule::setModelProvider(IModelProvider* mp) {
  enabled = (variable_provider->get("psid_data")->value() == 1);
  if(enabled) {
	  std::ostringstream ss;
		
		std::string model_name;
		try {
	  	hicap_model = mp->get("hicap");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the hicap model\n";
		}
		try {
	  	hicap_nonzero_model = mp->get("hicap_nonzero");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could nto find the hicap_nonzero model\n";
		}			
			
		try {
		  igxfr_nonzero_model = mp->get("igxfr_nonzero");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the igxfr_nonzero model\n";
		}
		try {
		  igxfr_model = mp->get("igxfr");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the igxfr model\n";
		}
		try {
		  ssdiamt_model = mp->get("ssdiamt");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the ssdiamt model\n";
		}
		try {
		  ssiamt_model = mp->get("ssiamt");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the ssiamt model\n";
		}
		
		try {
		  ssoasiamt_model = mp->get("ssoasiamt");
		} catch (fem_exception e) {
		  ss << "PSID Initialization Module could not find the ssoasiamt model\n";
		}

		if(ss.str().length() > 0)
	  	throw fem_exception(ss.str().c_str());

	}
}
                        