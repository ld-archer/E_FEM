#include "HealthModule.h"
#include "Logger.h"
#include <sstream>
#include <algorithm>
#include <fstream>
#include <math.h>
#include "utility.h"
#include "fem_exception.h"
#include "EquationParser.h"
#include "SummaryModule.h"
#include "ProbitRegression.h"

HealthModule::HealthModule(IVariableProvider* vp, ITimeSeriesProvider *tsp, NodeBuilder* builder, ITableProvider* tabp)
{
	timeSeriesProvider = tsp;
	
	nra = timeSeriesProvider->get("nra");
	eea = timeSeriesProvider->get("eea");
	
	tableProvider = tabp;
	
	mp = NULL;

	var_categories["condlist"] = &condlist;
	var_categories["bin_hzd"] = &bin_hzd;
	var_categories["bin_trst"] = &bin_trst;
	var_categories["cenbin"] = &cenbin;
	var_categories["ordered"] = &ordered;
	var_categories["continuous"] = &continuous;
	
	medicare_elig_var = vp->get("medicare_eligibility");
	diclaim2yr = vp->get("diclaim2yr");
	runcogstk_var = vp->get("runcogstk");
	runcog_var = vp->get("runcog");	
	variable_provider = vp;
	
	// Set up summary measure for median mortality probability
	std::string name = "median_pdied";
	std::string desc = "Median mortality probability";
	std::string type = "median";
	summ_median_pdied = new SummaryMeasure(vp->get("pdied"), 
	EquationParser::parseString("l2died == 0", builder), name, desc, 1.0, 
	EquationParser::parseString("weight", builder), type);
	median_pdied = new GlobalVariable("median_pdied", 1.0,"median mortality probability");
	vp->addVariable(median_pdied);
}

HealthModule::~HealthModule(void)
{

}

/** \todo Generate a conflict if there is a variable requested here that doesn't exist. Otherwise, typos in the scenario file go completely unnoticed */
void HealthModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);

	std::vector<std::string> var_names(10);
	std::map<std::string, std::vector<Vars::Vars_t>*>::iterator mit;
	for ( mit=var_categories.begin() ; mit != var_categories.end(); mit++ )	 {
		var_names.clear();
		str_tokenize(scen->get(mit->first), var_names);
		mit->second->clear();
		for(unsigned int i = 0; i < var_names.size(); i++) {
			if(VarsInfo::indexOf(var_names[i]) != Vars::_NONE)
				mit->second->push_back(VarsInfo::indexOf(var_names[i]));
			else
			  throw fem_exception("HealthModule wants to run non-existent model: " + var_names[i]);
		}
	}
	combo_set.clear();
	std::vector<Vars::Vars_t>::iterator it;
	for ( mit=var_categories.begin() ; mit != var_categories.end(); mit++ )
		for(it = (*mit).second->begin(); it != (*mit).second->end(); ++it)
			combo_set.push_back((*it));
	loadModels();
}

void HealthModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Health Module", FINE);
	std::vector<Person*>::iterator itr;

	bool psid_data = variable_provider->get("psid_data")->value() == 1;
	bool hrs_data = variable_provider->get("hrs_data")->value() == 1;
	bool elsa_data = variable_provider->get("elsa_data")->value() == 1;

	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		
		// Normal retirement age and Early Entitlement age for Social Security (based on birth year, from time series)
		const float rnra = (nra->Value(person->get(Vars::rbyr)) /12.0) - 2;
		const float reea = (eea->Value(person->get(Vars::rbyr)) /12.0) - 2;
					
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			bool smokev_prev = person->test(Vars::smokev);
			std::vector<Vars::Vars_t>::iterator it;
			for(it = combo_set.begin(); it != combo_set.end(); ++it) {
				Vars::Vars_t v = *it;
				bool do_model = true;
				switch(v) {
					case Vars::dbclaim: 
						// Only claim DB if fanydb == 1 & lag(dbclaim) == 0
						do_model = person->get(Vars::fanydb) == 1 && person->get(Vars::l2dbclaim) == 0; 
						break;
					case Vars::ssclaim:
						//If the person is over 68 or has already claimed ss, then they won't change their minds anymore
						// do_model = person->get(Vars::l2age) <= rnra+5 && person->get(Vars::l2ssclaim) == 0 && person->get(Vars::l2age) >= reea;   
						do_model = person->get(Vars::l2ssclaim) == 0 && person->get(Vars::l2age) >= reea;   
						break;
					case Vars::oasiclaim:
						// For PSID, we allow oasiclaim at all age.  Absorbing for those who claim once 62, those under 62 to be able to stop, 
						do_model = psid_data && ((person->get(Vars::l2oasiclaim) == 0 && person->get(Vars::l2age) < 68) || (person->get(Vars::l2oasiclaim) == 1 && person->get(Vars::l2age) < reea));
						break;
					case Vars::diclaim:
						do_model = person->get(Vars::l2age) < rnra;
						break;
					case Vars::anyhi:
						// For any HI, only if lag age < Medicare Eligibily Age - 2
						do_model = (medicare_elig_var->value(person) == 0.0);
						break;
					// This reflects the default case (hrs_data) 
					case Vars::work:
						// Assume people stop working after age 80 (Bryan's change to better reflect HRS)
						do_model = (person->get(Vars::l2age) < 78 && hrs_data) || (elsa_data);
						break;
					// Only rxchol_start if l2rxchol == 0
					case Vars::rxchol_start:
						do_model = person->get(Vars::l2rxchol) == 0 && hrs_data;
						break;
					// Only rxchol_stop if l2rxchol == 1
					case Vars::rxchol_stop:
					  do_model = person->get(Vars::l2rxchol) == 1 && hrs_data;
				    break;								
					// This is stage 1 of the psid case
					case Vars::laborforcestat:
						do_model = psid_data;
						break;
					// This is stage 2 of the psid case
					case Vars::fullparttime:
						do_model = psid_data;
						break;
					case Vars::cogstate:
 					  do_model = runcog_var->value(person) == 1;
						break;
					case Vars::afibe:
					     do_model = person->get(Vars::age) >= 65 && !person->test(Vars::l2afibe);
					     break;
					/*case Vars::mstat_new:
						do_model = psid_data;
						do_marriage(person, random);
						break;*/
				    case Vars::mstat:
				        do_model = elsa_data;
				        break;
					case Vars::births:
						do_model = psid_data && !person->test(Vars::male) && person->get(Vars::l2age) < 43;
						break;
					case Vars::paternity:
						do_model = psid_data && person->test(Vars::male) && person->get(Vars::l2age) < 54;
						break;
					case Vars::smoke_start:
						do_model = (psid_data || elsa_data) && person->get(Vars::l2smoken) == 0;
						break;
					case Vars::smoke_stop:
						do_model = (psid_data || elsa_data) && person->get(Vars::l2smoken) == 1;
						break;
				case Vars::nhmliv:
				  do_model = person->get(Vars::l2age) >= 49;
				  break;
					default:
						if(std::find(bin_hzd.begin(), bin_hzd.end(), v) != bin_hzd.end() || std::find(condlist.begin(), condlist.end(), v) != condlist.end()) {
							// For binary hazards or condition, only predict a transition if last year it was not in that state
							do_model = !person->test(VarsInfo::lagOf(v));
						} else {
							//Always attempt to predict
							do_model = true;
						}
						break;
				}

				if(do_model) {
					if(models.count(v) != 0) {
						models[v]->predict(person, random);
					} 
				} else {
					Vars::Vars_t pvar = VarsInfo::probOf(v);
					if(pvar != Vars::_NONE)
						person->set_missing(pvar);
				}


				// Adjustments
				//For HI, all covered after age 65
				if (v == Vars::anyhi && !do_model) {
					person->set(v, 1.0);
				} 
				// For working, all not working after age 75
				else if (v == Vars::work && !do_model) {
					person->set(v, 0.0);
				} 
				// DI benefit, not eligible after age 65
				else if (v == Vars::diclaim && !do_model) {
					person->set(v, 0.0);
				} 
				else if (v == Vars::ssclaim && person->test(Vars::l2ssclaim)) {
					person->set(v, 1.0);
				} 
				// else if (v == Vars::cogstate && !do_model) {
 				//        person->set(v, 3);
				//}
				else if (v == Vars::births && !do_model) {
					person->set(v,1.0);
				}
				else if (v == Vars::paternity && !do_model) {
					person->set(v,1.0);
				}
			
			}
			
			if(hrs_data) {
				// clean up diclaim and ssclaim
				if(person->test(Vars::l2diclaim) && person->get(Vars::l2age) >= rnra ) {
					person->set(Vars::ssclaim, 1.0);
				} 

				if(person->test(Vars::ssclaim)) {
					person->set(Vars::diclaim, 0.0);
				}
			}
			
			if(psid_data) {
				// clean up oasiclaim (make sure it is absorbing)
				if(person->test(Vars::l2oasiclaim) && person->get(Vars::l2age) >= reea ) {
					person->set(Vars::oasiclaim, 1.0);
				} 
				// Convert DI claimants to OASI at NRA
				if(person->test(Vars::l2diclaim) && person->get(Vars::l2age) >= rnra ) {
					person->set(Vars::oasiclaim, 1.0);	
				} 
				// Can't claim both DI and OASI 
				if(person->test(Vars::oasiclaim)) {
					person->set(Vars::diclaim, 0.0);
				}
			}
            // Do cogstock model if 65-66
			// if (runcogstk_var->value(person) == 1) {
 			//    cogstate_stock->predict(person, random);
			// }
				
			// Should not transition chfe if hearte==0
			if(!person->test(Vars::hearte))
				person->set(Vars::chfe, false);	
					
			// Should not transition hearta if hearte==0
            if(!person->test(Vars::hearte))
				person->set(Vars::hearta, false);	

			// Accounting for start/stop cholesterol treatment	
			if(hrs_data) {
				// Weren't on rxchol in lag
				if(!person->is_missing(Vars::l2rxchol) && !person->test(Vars::l2rxchol)) {
					// Start the treatment
					if(person->test(Vars::rxchol_start)){
						person->set(Vars::rxchol,1.0);
					}
					// Don't start the treatment
					else{
						person->set(Vars::rxchol,0.0);
						}
					}
				// Were on rxchol in lag	
				else {
					// Stop the treatment
					if(person->test(Vars::rxchol_stop)){
						person->set(Vars::rxchol,0.0);					
							}
					// Continue the treatment
					else {
						person->set(Vars::rxchol,1.0);
					}
				}
			}
			
			
			// Should never change smoke ever so set it back to what it was (HRS only!)
			if(hrs_data) {
				person->set(Vars::smokev, smokev_prev);
			}
			
			// Modeling smoking starting and stopping separately			
			if(psid_data || elsa_data) {
				// Smoked in previous period
				if(person->test(Vars::l2smoken)) {
					// Stopped smoking
					if(person->test(Vars::smoke_stop)) {
						// Now a former smoker
						person->set(Vars::smkstat,2.0);
						// Quit, so turn current off
						person->set(Vars::smoken,0.0);
						// Quit so smokef == 0
						//person->set(Vars::smokef,0.0);
						// Maintain smokev status
						person->set(Vars::smokev,person->get(Vars::l2smokev));
						// Clean up other vars - didn't start, too
						person->set(Vars::smoke_start,0.0);
						// Set intensity to non-smoker (smkint == 0)
						person->set(Vars::smkint, 0.0);
					}	
					else {
						// Didn't stop, so maintain smkstat, smoken, smokev, smkint
						person->set(Vars::smkstat,person->get(Vars::l2smkstat));
						person->set(Vars::smoken,person->get(Vars::l2smoken));
						person->set(Vars::smokev,person->get(Vars::l2smokev));
						//person->set(Vars::smkint,person->get(Vars::l2smkint)); Will this line mean that people will always have the same intensity if they continue to smoke? I.e. not being transitioned between states anymore
						// To above question: Yes I think so
						// Clean up other vars - didn't start, too
						person->set(Vars::smoke_start,0.0);
					}
				}
				// Didn't smoke in previous period
				else {
					// Started smoking
					if(person->test(Vars::smoke_start)) {
						// Now a current smoker
						person->set(Vars::smkstat,3.0);	
						// Started, so current smoker
						person->set(Vars::smoken,1.0);
						// Also an ever smoker
						person->set(Vars::smokev,1.0);
						// Clean up other vars - didn't stop, too
						person->set(Vars::smoke_stop,0.0);
						// How can I deal with smkint here? Will this happen automatically?
						// Smkint will be assigned a value from the transition model for anyone with smoken == 1
					}	
					else {
						// Didn't start, so maintain previous status for smkstat, smoken, smokev, smkint
						person->set(Vars::smkstat,person->get(Vars::l2smkstat));
						person->set(Vars::smoken,person->get(Vars::l2smoken));
						person->set(Vars::smokev,person->get(Vars::l2smokev));
						person->set(Vars::smkint,person->get(Vars::l2smkint));
						// Clean up other vars - didn't stop, too
						person->set(Vars::smoke_stop,0.0);
					}
				}
			}

			// If we change drink to 0 then we need to make sure drinkd is also 0
			// i.e. if we stop someone drinking at all, the number of days they drink must also be set to 0
			if (elsa_data) {
				// Doesn't drink/stopped drinking
				if(!person->test(Vars::drink)) {
					// Set drink days to 0
					person->set(Vars::drinkd, 0.0);
					// USE LAG VARIABLE
				}
			}

			// Handle marriage status transitions
			if (elsa_data) {
                // Married = mstat == 1
			    // Single = mstat == 2
			    // Cohab = mstat == 3
			    // Widowed = mstat == 4

			    // Single to other states
			    if(person->get(Vars::l2mstat) == 2) {
                    // Now married
                    if(person->get(Vars::mstat) == 1) {
                        person->set(Vars::married, 1.0);
                        person->set(Vars::single, 0.0);
                    }
                    // Now cohabiting
                    if(person->get(Vars::mstat) == 3) {
                        person->set(Vars::cohab, 1.0);
                        person->set(Vars::single, 0.0);
                    }
                    // Now widowed
                    if(person->get(Vars::mstat) == 4) {
                        person->set(Vars::widowed, 1.0);
                        person->set(Vars::single, 0.0);
                    }
                }
                // married to other states
                if(person->get(Vars::l2mstat) == 1) {
                    // Now single
                    if(person->get(Vars::mstat) == 2) {
                        person->set(Vars::single, 1.0);
                        person->set(Vars::married, 0.0);
                    }
                    // Now cohabiting (odd change, maybe rare but not impossible)
                    if(person->get(Vars::mstat) == 3) {
                        person->set(Vars::cohab, 1.0);
                        person->set(Vars::married, 0.0);
                    }
                    // Now widowed
                    if(person->get(Vars::mstat) == 4) {
                        person->set(Vars::widowed, 1.0);
                        person->set(Vars::married, 0.0);
                    }
                }
                // cohab to other states
                if(person->get(Vars::l2mstat) == 3) {
                    // Now single
                    if(person->get(Vars::mstat) == 2) {
                        person->set(Vars::single, 1.0);
                        person->set(Vars::cohab, 0.0);
                    }
                    // Now married
                    if(person->get(Vars::mstat) == 1) {
                        person->set(Vars::cohab, 1.0);
                        person->set(Vars::married, 0.0);
                    }
                    // Now widowed
                    if(person->get(Vars::mstat) == 4) {
                        person->set(Vars::widowed, 1.0);
                        person->set(Vars::cohab, 0.0);
                    }
                }
                // widowed to other states (again, this is odd but not impossible)
                // Should widowed be absorbing? Might be useful to keep this information even in marital status changes
                // in the future?
                if(person->get(Vars::l2mstat) == 4) {
                    // Now single
                    if(person->get(Vars::mstat) == 2) {
                        person->set(Vars::single, 1.0);
                        person->set(Vars::widowed, 0.0);
                    }
                    // Now married
                    if(person->get(Vars::mstat) == 1) {
                        person->set(Vars::cohab, 1.0);
                        person->set(Vars::widowed, 0.0);
                    }
                    // Now cohab
                    if(person->get(Vars::mstat) == 4) {
                        person->set(Vars::cohab, 1.0);
                        person->set(Vars::widowed, 0.0);
                    }
                }
			}

			// If someone develops a difficulty in ADL (or more than 1), need to make sure anyadl gets updated correclty
			//if (elsa_data) {
			//	// If no ADLs last wave...
			//	if (person->get(Vars::l2adlstat) == 1) {
			//		// ... and ADLs in current wave (1 or more) ...
			//		if (person->get(Vars::adlstat) > 1) {
			//			// ... set anyadl to true
			//			person->set(Vars::anyadl, 1.0);
			//		}
			//	}
			//	// Now do the same for IADLs
			//	if (person->get(Vars::l2iadlstat) == 1) {
			//		if (person->get(Vars::iadlstat) > 1) {
			//			person->set(Vars::anyiadl, 1.0);
			//		}
			//	}
			//}
					
			/*// Do partner/spouse mortality for PSID simulation
			if(psid_data && person->get(Vars::l2mstat_new) != 1) {
				models[Vars::partdied]->predict(person, random);
				// if partner died, set to single
				if(person->test(Vars::partdied)) {
					person->set(Vars::mstat_new,1);
					// if person was married when partner died, set to widowed
					if(person->get(Vars::l2mstat_new)==3) {
						person->set(Vars::widowed, true);
						person->set(Vars::widowev, true);
					}
				}
			}*/
			
			// Do mortality (with adjustment, if needed)
			if(person->get(Vars::l2age) >= 118)
			  person->set(Vars::died, 1.0);
			else
			  mortalityAdj(person, year, random);
		}
	}
	
	// Compute median mortality probability for the simulated population
	// the type of mpdied must be at least as large as the return type of SummaryMeasure::calculate in order to store SummaryModule::MISSING_VAL 
	double mpdied = summ_median_pdied->calculate(persons);
	median_pdied->setVal(mpdied);
	if(mpdied == SummaryModule::MISSING_VAL)
		Logger::log("  median pdied is missing -- everyone might be dead or zero weight", INFO);	
	else if(mpdied < 0.0 || mpdied > 1.0)
		throw fem_exception("In health module: median of pdied not in [0,1] range");
}

/*void HealthModule::do_marriage(Person* person, Random* random) {
	*//** \todo Load one mstat model, but allow model definition to change according to lmstat value. Then, remove the following code and treat mstat like other models.  Even better: create a separate Marriage/Family module *//*

	// model for whether or not a person exits their current status
	Vars::Vars_t mstatex_model_var = Vars::_NONE;
	// model for new status if person leaves their current status
	Vars::Vars_t mstatsw_model_var = Vars::_NONE;
		
	// select the appropriate model for mstat
	int lmstat = (int)person->get(Vars::l2mstat_new);
	switch(lmstat) {
		case 1: // lag mstat == single
			if(person->test(Vars::male)) {
				mstatex_model_var = Vars::exitsingle_m;
				mstatsw_model_var = Vars::single2married_m;
			}
			else {
				mstatex_model_var = Vars::exitsingle_f;
				mstatsw_model_var = Vars::single2married_f;
			}
			break;
		case 2: // lag mstat == cohab
			if(person->test(Vars::male)) {
				mstatex_model_var = Vars::exitcohab_m;
				mstatsw_model_var = Vars::cohab2married_m;
			}
			else {
				mstatex_model_var = Vars::exitcohab_f;
				mstatsw_model_var = Vars::cohab2married_f;
			}
			break;
		case 3: // lag mstat == married
			if(person->test(Vars::male)) {
				mstatex_model_var = Vars::exitmarried_m;
				mstatsw_model_var = Vars::married2cohab_m;
			}
			else {
				mstatex_model_var = Vars::exitmarried_f;
				mstatsw_model_var = Vars::married2cohab_f;
			}
			break;
		default:
			throw fem_exception("Invalid value for lag of marital status");
			break;
	}
	// predict exit from previous mstat
	IModel* mstatex_model = mp->get(VarsInfo::labelOf(mstatex_model_var));
	mstatex_model->predict(person, random);

	// predict current mstat if exiting previous status
	unsigned int mstat = lmstat;
	if(person->get(mstatex_model_var)==1) {
		IModel* mstatsw_model = mp->get(VarsInfo::labelOf(mstatsw_model_var));
		mstatsw_model->predict(person, random);
		switch(lmstat) {
			case 1: // lag mstat == single
				mstat = person->get(mstatsw_model_var)==1 ? 3 : 2;
				break;
			case 2: // lag mstat == cohab
				mstat = person->get(mstatsw_model_var)==1 ? 3 : 1;		
				break;
			case 3: // lag mstat == married
				mstat = person->get(mstatsw_model_var)==1 ? 2 : 1;
				break;
		}
	}
	person->set(Vars::mstat_new, mstat);
	
	// update dummies and spouse (if needed)
	Person* spouse;
	switch((int)person->get(Vars::mstat_new)) {
		case 1:
			person->set(Vars::single, true);
			person->set(Vars::cohab, false);
			person->set(Vars::married, false);
			//if there is a spouse, update their marital status to reflect seperation
			spouse = person->getSpouse();
			if(spouse != NULL) {
				spouse->set(Vars::mstat_new, 1);
				spouse->set(Vars::single, true);
				spouse->set(Vars::cohab, false);
				spouse->set(Vars::married, false);
				spouse->set(Vars::eversep, true);
				spouse->setSpouse(NULL);
				person->setSpouse(NULL);
			}
			if(lmstat == 2 || lmstat == 3)
				person->set(Vars::eversep, true);
			break;
		case 2:
			person->set(Vars::single, false);
			person->set(Vars::cohab, true);
			person->set(Vars::married, false);
			person->set(Vars::widowed, false);
			person->set(Vars::partdied, false);
			break;
		case 3:
			person->set(Vars::single, false);
			person->set(Vars::cohab, false);
			person->set(Vars::married, true);
			person->set(Vars::widowed, false);
			person->set(Vars::partdied, false);
			person->set(Vars::everm, true);
			break;
		default:
			throw fem_exception("Invalid value for marital status");
			break;
	}
	return;
}*/

/** \todo If someone turned 65 during the last time step their adjustment factor should be averaged over the u65 table in years when they are < 65 and the 65p table after they turn 65.*/
void HealthModule::mortalityAdj(Person* person, unsigned int year, Random* random) const {
	Vars::Vars_t predvar = Vars::died;
	Vars::Vars_t probvar = VarsInfo::probOf(predvar);
	bool do_mortality_adj = false;

	if(person->test(Vars::l2died))
		throw fem_exception("Cannot do mortality adjustment for person who has died");
	else if(probvar == Vars::_NONE)
		throw fem_exception("Mortality adjustment: probability variable for \"died\" does not exist");

	// Check if mortality adjustment is needed and get table
	if(tableProvider->hasTable("mortality_adj")) {
		do_mortality_adj = true;
	}
	
	// Compute and store unadjusted probability
	((ProbitRegression*)models.at(predvar))->storeProb(person);

	// Compute and store adjusted probability, if needed
	if(do_mortality_adj) {
		// Set up a table index with person's values so that we can iterate the year
		ITable* adj_tab = tableProvider->get("mortality_adj");
		TableIndex idx = adj_tab->getIndexTemplate();
		idx.set(*person);
		
		// Compute adjustment factor using average of yearly adjustment factors since last time step
		double sum = 0.0;
		double adj = 1.0;
		unsigned int steplen = scenario->YrStep();
		for(unsigned int i=year; i > year-steplen; i--) { 
			idx.set("year",i);
	  	sum += adj_tab->Value(idx);
	  }
		adj = std::min(1.0, sum / steplen);
				
		// Adjust probability
		double pdied = person->get(probvar);
		pdied = std::max(std::min(pdied*adj, 1.0), 0.0); //pdied *= adj;
		person->set(probvar, pdied);
	}
	
	// Simulate outcome using stored (adjusted) probability
	((ProbitRegression*)models.at(predvar))->predictWithProb(person, random, person->get(probvar));
	
}

void HealthModule::loadModels() {
	if(mp == NULL)
		return;
		
	// bool hrs_data = variable_provider->get("hrs_data")->value() == 1;
	bool psid_data = variable_provider->get("psid_data")->value() == 1;

	std::vector<Vars::Vars_t>::iterator it;
	for(it = combo_set.begin(); it != combo_set.end(); ++it) {		
		//if(*it != Vars::mstat_new) {
        if(*it != Vars::mstat) {
			try {
				models[*it] = mp->get(VarsInfo::labelOf(*it));
			} catch (const fem_exception & e) {
				std::ostringstream ss;
				ss << this->description() << " needs model " << VarsInfo::labelOf(*it);
				throw fem_exception(ss.str().c_str());
			}
		}
	}
	try {
		models[Vars::died] = mp->get("died");
	} catch (const fem_exception & e) {
		std::ostringstream ss;
		ss << this->description() << " needs model died";
		throw fem_exception(ss.str().c_str());
	}
	if(psid_data) {
		try {
			models[Vars::partdied] = mp->get("partdied");
		} catch (const fem_exception & e) {
			std::ostringstream ss;
			ss << this->description() << " needs model partdied";
			throw fem_exception(ss.str().c_str());
		}
	}
	// if(hrs_data) {
	//	try {
	//		cogstate_stock = mp->get("cogstate_stock");
	//	} catch (fem_exception e) {
	//		std::ostringstream ss;
	//		ss << this->description() << " needs model cogstate_stock";
	//		throw fem_exception(ss.str().c_str());
	//	}
	// }

}

void HealthModule::setModelProvider(IModelProvider* modp) {
	mp = modp;
	loadModels();
}
