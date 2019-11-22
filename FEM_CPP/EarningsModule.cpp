#include "EarningsModule.h"
#include "Logger.h"
#include "utility.h"
#include <sstream>
#include "fem_exception.h"

EarningsModule::EarningsModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider)
{
	nwi = timeSeriesProvider->get("nwi");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");
	interest_rate = timeSeriesProvider->get("interest_rate");
	
	variable_provider = vp;
	
}

EarningsModule::~EarningsModule(void)
{
}


void EarningsModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);
	if (scen->get("psid_data")=="1") {
		ref_year = 2009;
	}
	else {
		ref_year = 2010;
	}
}



void EarningsModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Earnings Module", FINE);

	// Rise in CPI and NWI
	const double delta_cpi = (1.0 + cpi_yearly->Value(year)) * (1.0 + cpi_yearly->Value(year-scenario->YrStep()));
	const double delta_nwi = nwi->Value(year)/nwi->Value(ref_year);
	const double delta_rate = interest_rate->Value(year)/interest_rate->Value(year-scenario->YrStep());

	bool hrs_data = variable_provider->get("hrs_data")->value() == 1;
	bool psid_data = variable_provider->get("psid_data")->value() == 1;
	
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			// Only run wealth models in HRS-based and PSID-based simulations
			if(hrs_data || psid_data) {
				// Does this person have non zero wealth?
				if(person->test(Vars::wlth_nonzero))  {
					// Yes, predict the wealth
					hatota_model->predict(person, random);
					
					// Scale up the wealth by the interest rate
					person->set(Vars::hatota, person->get(Vars::hatota)*delta_rate*delta_cpi);
	
					// Calculate the derived wealth variables
					person->set(Vars::hatotax, std::min(2000.0, person->get(Vars::hatota)));
					person->set(Vars::hatotax, std::max(-2000.0, person->get(Vars::hatotax)));	
					person->set(Vars::loghatota, arcsinh(person->get(Vars::hatota))/100.0);
					person->set(Vars::loghatotax, arcsinh(person->get(Vars::hatotax))/100.0);
				} else {
					// Wealth is not non-zero. Set to zero
					person->set(Vars::hatota, 0.0);
					person->set(Vars::hatotax, 0.0);
					person->set(Vars::loghatota, 0.0);
					person->set(Vars::loghatotax, 0.0); 
				}
			}  
			
			// Does this person have non-zero capital income?
			if(person->test(Vars::hicap_nonzero)) {
			  hicap_model->predict(person, random);
			  person->set(Vars::hicap_real, person->get(Vars::hicap));			  
			  person->set(Vars::hicap, person->get(Vars::hicap) * delta_cpi);
			} else {
				person->set(Vars::hicap_real, 0.0);
			  person->set(Vars::hicap, 0.0);
			}
			if(person->test(Vars::igxfr_nonzero)) {
			  igxfr_model->predict(person, random);
			  person->set(Vars::igxfr, person->get(Vars::igxfr) * delta_cpi);
			} else 
			  person->set(Vars::igxfr, 0.0);
			
					// Assigning a categorical work status variable
		if(psid_data) {
			if ( person->get(Vars::laborforcestat) == 1 ) {
				person->set(Vars::workcat,1);
			}
			if (person->get(Vars::laborforcestat) == 2) {
				person->set(Vars::workcat,2);
			}
			if ((person->get(Vars::laborforcestat) == 3) && (person->get(Vars::fullparttime) == 0)) {
				person->set(Vars::workcat,3);
			}
			if ((person->get(Vars::laborforcestat) == 3) && (person->get(Vars::fullparttime) == 1)) {
				person->set(Vars::workcat,4);
			}				
			
			
			// Assign work binary variable
			if (person->get(Vars::workcat) == 3 ||  person->get(Vars::workcat) == 4) {
				person->set(Vars::work,1);
			}
			else {
				person->set(Vars::work,0);
			}
		}
			
			// Handle earnings the HRS way		
			if (hrs_data) {
				// Is the person working?
				if(person->test(Vars::work)) {
					// Yes, predict earnings 
					iearn_model->predict(person, random);
					iearnuc_model->predict(person, random);
	
					// Calculate the derived earnings variables
					person->set(Vars::iearnx, std::max(std::min(200.0, person->get(Vars::iearn) * delta_nwi),0.0));
					person->set(Vars::iearnuc, person->get(Vars::iearnuc) * delta_nwi);
					person->set(Vars::logiearn, arcsinh(person->get(Vars::iearn))/100.0);
					person->set(Vars::logiearnuc, arcsinh(person->get(Vars::iearnuc))/100.0);
					person->set(Vars::logiearnx, arcsinh(person->get(Vars::iearnx))/100.0);		
				} else {
					// Not working. Set all earnings vars to zero
					person->set(Vars::iearn, 0.0);
					person->set(Vars::iearnx, 0.0);
					person->set(Vars::logiearn, 0.0);
					person->set(Vars::logiearnx, 0.0);
					person->set(Vars::iearnuc, 0.0);
					person->set(Vars::logiearnuc, 0.0);
				}		
			}
		
			// Handle earnings for the PSID
			if(psid_data) {
				// Is the person out of the labor force?
				if (person->get(Vars::workcat) == 1) {
					// Predict if they had any earnings
					any_iearn_nl_model->predict(person, random);
					// If so, predict their ln(earnings)
					if(person->test(Vars::any_iearn_nl)) {
						lniearn_nl_model->predict(person,random);
						person->set(Vars::iearn, exp(person->get(Vars::lniearn_nl)));
					}
					else{
						person->set(Vars::iearn, 0.0);
					}
				}
				// Is the person unemployed?
				if (person->get(Vars::workcat) == 2) {
					// Predict if they had any earnings
					any_iearn_ue_model->predict(person, random);
					// If so, predict their ln(earnings)
					if(person->test(Vars::any_iearn_ue)) {
						lniearn_ue_model->predict(person,random);
						person->set(Vars::iearn, exp(person->get(Vars::lniearn_ue)));
					}
					else{
						person->set(Vars::iearn, 0.0);
					}
				}
				// Is the person working part-time?  Don't worry about censoring
				if (person->get(Vars::workcat) == 3) {
					// If so, predict their ln(earnings)
					lniearn_pt_model->predict(person,random);
					person->set(Vars::iearn, exp(person->get(Vars::lniearn_pt)));
				}
				// Is the person working full-time?
				if (person->get(Vars::workcat) == 4) {
					// If so, predict their ln(earnings)
					lniearn_ft_model->predict(person,random);
					person->set(Vars::iearn, exp(person->get(Vars::lniearn_ft)));
				}
				
				// Calculate the derived earnings variables
				person->set(Vars::iearn, person->get(Vars::iearn) * delta_nwi);
				person->set(Vars::iearnx, std::max(std::min(200.0, person->get(Vars::iearn) * delta_nwi),0.0));
				person->set(Vars::iearnuc, person->get(Vars::iearnuc) * delta_nwi);
				person->set(Vars::logiearn, arcsinh(person->get(Vars::iearn))/100.0);
				person->set(Vars::logiearnuc, arcsinh(person->get(Vars::iearnuc))/100.0);
				person->set(Vars::logiearnx, arcsinh(person->get(Vars::iearnx))/100.0);	
				
			}
		}
	}
}

void EarningsModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
	bool hrs_data = variable_provider->get("hrs_data")->value() == 1;
	bool psid_data = variable_provider->get("psid_data")->value() == 1;
		
	if(hrs_data || psid_data) {	
		try {
			hatota_model = mp->get("hatota");
		} catch (fem_exception e) {
			ss << this->description() << " needs hatota model";
		}
	}
	
	if(hrs_data) {
		try {
			iearn_model = mp->get("iearn");
		} catch (fem_exception e) {
			ss << this->description() << " needs iearn model";
		}
		
		try {
			iearnuc_model = mp->get("iearnuc");
		} catch (fem_exception e) {
			ss << this->description() << " needs iearnuc model";
		}
	}

	try {
	  hicap_model = mp->get("hicap");
	} catch (fem_exception e) {
	  ss << this->description() << " needs hicap model";
	}

	try {
	  igxfr_model = mp->get("igxfr");
	} catch (fem_exception e) {
	  ss << this->description() << " needs model igxfr";
	}

	if(psid_data) {
		try {
			any_iearn_ue_model = mp->get("any_iearn_ue");
		} catch (fem_exception e) {
			ss << this->description() << " needs any_iearn_ue model";
		}	
		try {
			any_iearn_nl_model = mp->get("any_iearn_nl");
		} catch (fem_exception e) {
			ss << this->description() << " needs any_iearn_nl model";
		}	
	
	
		try {
			lniearn_ft_model = mp->get("lniearn_ft");
		} catch (fem_exception e) {
			ss << this->description() << " needs lniearn_ft model";
		}
		try {
			lniearn_pt_model = mp->get("lniearn_pt");
		} catch (fem_exception e) {
			ss << this->description() << " needs lniearn_pt model";
		}
		try {
			lniearn_ue_model = mp->get("lniearn_ue");
		} catch (fem_exception e) {
			ss << this->description() << " needs lniearn_ue model";
		}
		try {
			lniearn_nl_model = mp->get("lniearn_nl");
		} catch (fem_exception e) {
			ss << this->description() << " needs lniearn_nl model";
		}
	}



	if(ss.str().length() > 0)
		throw fem_exception(ss.str().c_str());
}
