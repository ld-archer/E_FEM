#include "MedCostsModule.h"
#include "Logger.h"
#include "SummaryModule.h"
#include <sstream>
#include "fem_exception.h"
#include "ConstantTimeSeries.h"
#include "EquationParser.h"
#include "GlobalVariable.h"

MedCostsModule::MedCostsModule(IVariableProvider* vp, ITimeSeriesProvider *tsp, NodeBuilder* bldr)
{
	/* Variables to hold predicted costs using the MCBS dataset for medicare elig */
	cost_vars_mcbs.push_back(Vars::totmd_mcbs);
	cost_vars_mcbs.push_back(Vars::caidmd_mcbs);
	cost_vars_mcbs.push_back(Vars::oopmd_mcbs);
	cost_vars_mcbs.push_back(Vars::mcare);
	cost_vars_mcbs.push_back(Vars::mcare_pta);
	cost_vars_mcbs.push_back(Vars::mcare_ptb);
	cost_vars_mcbs.push_back(Vars::mcare_ptd);
	
	/* Variables to hold predicted costs using the MEPS dataset for non medicare elig*/
	cost_vars_meps.push_back(Vars::totmd_meps);
	cost_vars_meps.push_back(Vars::caidmd_meps);
	cost_vars_meps.push_back(Vars::oopmd_meps);

	/* Create convenience vector, cost_vars, that holds all cost variables */
	for(unsigned int i = 0; i < cost_vars_mcbs.size(); i++)
		cost_vars.push_back(cost_vars_mcbs[i]);
	for(unsigned int i = 0; i < cost_vars_meps.size(); i++)
		cost_vars.push_back(cost_vars_meps[i]);


	event_vars.push_back(Vars::hspnit);
	event_vars.push_back(Vars::hsptim);
	event_vars.push_back(Vars::doctim);

	medicare_elig_var = vp->get("medicare_eligibility");
	frac_medicare_elig_var = vp->get("frac_medicare_elig");
		
	mcare_ptb_coin_elas = vp->get("mcare_ptb_coin_elas");
	mcare_ptb_coin_chg = vp->get("mcare_ptb_coin_chg");
	poverty_level = vp->get("poverty_level");
	
	// The summary_module will get set (and reset) in FEM.cpp for each new scenario
	summary_module = NULL;

	variable_provider=vp;
	timeSeriesProvider=tsp;
	builder=bldr;

}

MedCostsModule::~MedCostsModule(void)
{
}

double MedCostsModule::dDeltaMedgrowth(unsigned int start_year, unsigned int last_year) const {
  double delta_medgrowth = 1.0;
  for(unsigned int i=start_year; i <= last_year; i++) {
    delta_medgrowth *= (1 + cpi_yearly->Value(i) + min(medgrowth_max->Value(i), medgrowth_yearly->Value(i) + gdp_yearly->Value(i)));
  }
  // This labor force adjustment was suggested by Christine Eibner to make simulated Medicare expenditures closer to government projections 
  delta_medgrowth = delta_medgrowth / (labor->Value(last_year)/labor->Value(start_year));
  return delta_medgrowth;
}

double MedCostsModule::dMedicareSubsidy(unsigned int base_year, unsigned int curr_year, ITimeSeries* inflation, double premium_subsidy_share, std::string summ_variable, Random* r) const {
  double subsidy = 0.0;
  if(curr_year >= (scenario->StartYr() + scenario->YrStep())) {
    if(curr_year > base_year)
      subsidy = summary_module->getValue(base_year, summ_variable, r) * premium_subsidy_share;
  }
  for(unsigned int i= base_year; i <= curr_year; i++)
    subsidy *= (1 + cpi_yearly->Value(i) + inflation->Value(i));
  return subsidy;
}  

void MedCostsModule::process(PersonVector& persons, unsigned int year, Random* random)
{

  bool tmp_iadl1=false, tmp_iadl2p=false, tmp_adl1=false, tmp_adl2=false, tmp_adl3p=false;

	Logger::log("Running Medical Costs Module", FINE);
	
	double delta_medgrowth = dDeltaMedgrowth(ref_year, year);
	double tstep_medgrowth = dDeltaMedgrowth(year - scenario->YrStep(), year);

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {



			/* Set all costs to zero first */
			for(unsigned int i = 0; i < cost_vars.size(); i++)
				person->set(cost_vars[i], 0.0);

			/* Is the person eligible for medicare ? */
			int medicare_elig = IsMedicareElig(person) ? 1 : 0;
			person->set(Vars::medicare_elig, medicare_elig);
			
			/* Fraction of the year the person is Medicare eligibale */
			double frac_medicare_elig = frac_medicare_elig_var->value(person);
			
			if(medicare_elig) {

			  double mcare_pta_subsidy = dMedicareSubsidy((unsigned int) mcare_pta_premium_subsidy_year->value(person),
								      year,
								      mcare_premium_subsidy_inflation,
								      mcare_pta_premium_subsidy_share->value(person),
							      "mcare_pta", random);
			  double mcare_ptb_subsidy = dMedicareSubsidy((unsigned int) mcare_ptb_premium_subsidy_year->value(person),
								      year,
								      mcare_premium_subsidy_inflation,
								      mcare_ptb_premium_subsidy_share->value(person),
								      "mcare_ptb", random);

				/* In the mcbs dataset, If in a nursing home, adls are 0. So adjust the data */
				tmp_iadl1 = person->test(Vars::iadl1);
				tmp_iadl2p = person->test(Vars::iadl2p);
				tmp_adl1 = person->test(Vars::adl1);
				tmp_adl2 = person->test(Vars::adl2);
				tmp_adl3p = person->test(Vars::adl3p);
							
				if(person->test(Vars::nhmliv)) {
					person->set(Vars::iadl1, false);
					person->set(Vars::iadl2p, false);
					person->set(Vars::adl1, false);
					person->set(Vars::adl2, false);
					person->set(Vars::adl3p, false);
				}   

				/// Part A
				double new_pta_premium = mcare_pta_share->value(person) > 0 ? mcare_pta_stock->Value(year) * mcare_pta_share->value(person) : 0.0;
				if(year >= (scenario->StartYr() + scenario->YrStep()) && scenario->SimuType()==3) {
				  new_pta_premium = summary_module->getValue(year - scenario->YrStep(), "mcare_pta", random) * mcare_pta_share->value(person) * tstep_medgrowth;;
				}
				person->set(Vars::mcare_pta_premium, max(0, new_pta_premium - mcare_pta_subsidy)*frac_medicare_elig);
				if(person->is_missing(Vars::fmcare_pta_premium))
				  person->set(Vars::fmcare_pta_premium, max(0, mcare_pta_premium_baseline->value(person) * delta_medgrowth - mcare_pta_subsidy));

				/// Part B
				double new_ptb_premium = 0.0;
				if( mcare_ptb_history->StartYear() <= year && year <= mcare_ptb_history->EndYear())
				  new_ptb_premium = mcare_ptb_history->Value(year) * 12;
				else if(year >= (scenario->StartYr() + scenario->YrStep()) && scenario->SimuType()==3)
				  new_ptb_premium = summary_module->getValue(year - scenario->YrStep(), "mcare_ptb", random) * mcare_ptb_share->value(person) * tstep_medgrowth;
				else
				  new_ptb_premium = mcare_ptb_stock->Value(year) * mcare_ptb_share->value(person);
				person->set(Vars::mcare_ptb_premium, max(0, new_ptb_premium - mcare_ptb_subsidy)*frac_medicare_elig);
				if(person->is_missing(Vars::fmcare_ptb_premium))
				  person->set(Vars::fmcare_ptb_premium, max(0, new_ptb_premium - mcare_ptb_subsidy));

				// Poverty Exemptions
				if(poverty_level->value(person) <= premium_exemption->Value(year)) {
				  person->set(Vars::mcare_pta_premium, 0.0);
				  person->set(Vars::mcare_ptb_premium, 0.0);
				}
				

				// If the person does not have Medicare Part A, predict enrollment
				if(!person->test(Vars::mcare_pta_enroll)) {
					double base_prob = 1.0;
					double mod_prob = 1.0;
					IModel* mcarea_takeup = (!person->is_missing(Vars::l2medicare_elig) && person->test(Vars::l2medicare_elig)) ? mcarea_takeup_curenroll : mcarea_takeup_newenroll;
				     
					if(person->get(Vars::mcare_pta_premium) > 0)
				  	base_prob = mcarea_takeup->estimate(person);

					if(person->get(Vars::mcare_pta_premium) > 0) {
				  	if(person->get(Vars::fmcare_pta_premium) != 0) {
							double prm_chg = (person->get(Vars::mcare_pta_premium) - person->get(Vars::fmcare_pta_premium))/person->get(Vars::fmcare_pta_premium);
							mod_prob *= (1 + mcare_pta_prm_elas->value(person) * prm_chg);
						}
					}
				     
				  bool enroll_a = random->uniformDist(person->getID(), Vars::mcare_pta_enroll, person->getYear()) + (mod_prob * base_prob) > 1;
				  person->set(Vars::mcare_pta_enroll, enroll_a);
				}
				
				if(person->test(Vars::mcare_pta_enroll)) {
					// Test for Dropping Part A due to premium jump
				 	double stayProb = 1.0;
					if(!person->is_missing(Vars::l2mcare_pta_premium) && 
					(person->get(Vars::l2mcare_pta_premium) == 0) &&
					(person->get(Vars::mcare_pta_premium) > 0)) {
				   	stayProb *= 1 - dropPartA->value(person);
					}
				     
					// Test for dropping Part A due to elasticity
					if((person->get(Vars::mcare_pta_premium) > 0) &&  (person->get(Vars::fmcare_pta_premium) > 0)) {
						double prm_chg = (person->get(Vars::mcare_pta_premium) - person->get(Vars::fmcare_pta_premium))/person->get(Vars::fmcare_pta_premium);
						stayProb *= 1 + mcare_pta_prm_elas->value(person) * prm_chg;
					}
					bool stay = random->uniformDist(person->getID(), Vars::mcare_pta_enroll, person->getYear()) <= stayProb;
					person->set(Vars::mcare_pta_enroll, stay);
				}
				
				/* If the person does not have Medicare Part B, predict if they will get it */
				if(!person->test(Vars::mcare_ptb_enroll)) {
				  /* Pick which model to use for part B take up, new enrollee or current enrollee
				     This used to be based on Part A enrollment, but now it is just based on whether you
				     just became eligible for Part B or not 
				  */
				  double base_prob = 1.0;
				  double mod_prob = 1.0;
				  IModel* mcareb_takeup = (!person->is_missing(Vars::l2medicare_elig) && person->test(Vars::l2medicare_elig)) ? mcareb_takeup_curenroll : mcareb_takeup_newenroll;
				  
				  if(person->get(Vars::mcare_ptb_premium) > 0)
				    base_prob = mcareb_takeup->estimate(person);

				  if(person->get(Vars::mcare_ptb_premium) > 0) {
				    if(person->get(Vars::fmcare_ptb_premium) != 0) {
				      double prm_chg = (person->get(Vars::mcare_ptb_premium) - person->get(Vars::fmcare_ptb_premium))/person->get(Vars::fmcare_ptb_premium);
				      mod_prob *= (1 + mcare_ptb_prm_elas->value(person) * prm_chg);
				    }
				  }

				  /* Decide if the person is going to get Medicare part B based on the probability */
				  bool roll = random->uniformDist(person->getID(), Vars::mcare_ptb_enroll, person->getYear()) + (mod_prob * base_prob) > 1;
				  person->set(Vars::mcare_ptb_enroll, roll);
				}

				// Test for Dropping Part B due to premium jump
				if(person->test(Vars::mcare_ptb_enroll)) {
					double stayProb = 1.0;
					if(!person->is_missing(Vars::l2mcare_ptb_premium) && 
				     (person->get(Vars::l2mcare_ptb_premium) == 0) &&
				     (person->get(Vars::mcare_ptb_premium) > 0)) {
						stayProb *= 1 - dropPartB->value(person);
					}
				  
					// Test for dropping Part B due to elasticity
					if(person->test(Vars::mcare_ptb_enroll) && (person->get(Vars::mcare_ptb_premium) > 0) &&  (person->get(Vars::fmcare_ptb_premium) > 0)) {
						double prm_chg = (person->get(Vars::mcare_ptb_premium) - person->get(Vars::fmcare_ptb_premium))/person->get(Vars::fmcare_ptb_premium);
						stayProb *= 1 + mcare_ptb_prm_elas->value(person) * prm_chg;
					}
					bool stay = random->uniformDist(person->getID(), Vars::mcare_ptb_enroll, person->getYear()) <= stayProb;
					person->set(Vars::mcare_ptb_enroll, stay);
				}

				// Only do Medicare Part D 2006+
				if(year >= 2006) {
					// Apply the cross section part d enrollment model. This is NOT an absorbing state!
					mcare_ptd_enroll->predict(person, random);

				} else {
					person->set(Vars::mcare_ptd_enroll, false);
				}

				// Record the subsidies paid
				person->set(Vars::mcare_pta_subsidy, person->test(Vars::mcare_pta_enroll) ? min(new_pta_premium, mcare_pta_subsidy)*frac_medicare_elig : 0);
				person->set(Vars::mcare_ptb_subsidy, person->test(Vars::mcare_ptb_enroll) ? min(new_ptb_premium, mcare_ptb_subsidy)*frac_medicare_elig : 0);
				  

			} else {
				person->set(Vars::mcare_pta_subsidy, 0);
				person->set(Vars::mcare_ptb_subsidy, 0);
				person->set(Vars::mcare_pta_enroll, false);
				person->set(Vars::mcare_ptb_enroll, false);
				person->set(Vars::mcare_ptd_enroll, false);
				person->set(Vars::mcare_ptd, 0.0);
				person->set(Vars::mcare_pta, 0.0);
				person->set(Vars::mcare_ptb, 0.0);
				person->set(Vars::mcare, 0.0);
				person->set(Vars::mcare_pta_premium, 0.0);
				person->set(Vars::mcare_ptb_premium, 0.0);
			}


			/* If the person wasn't eligible for Medicare the whole year, predict the costs using MEPS based models */
			if(frac_medicare_elig < 1) {
				for(unsigned int i = 0; i < cost_models_meps.size(); i++)
					cost_models_meps[i]->predict(person, random);
			} 
			
			/* If the person eligible for Medicare for any part of the year, predict the costs using MCBS based models */
			if(frac_medicare_elig > 0) {
				for(unsigned int i = 0; i < cost_models_mcbs.size(); i++) {
					if(cost_models_mcbs[i]->getPredictedVar() == Vars::mcare_pta) {
				  	if(person->test(Vars::mcare_pta_enroll)) {
				    	/* Only predict Part A costs for those enrolled */
				    	cost_models_mcbs[i]->predict(person, random);
						}
				    else
				    	person->set(Vars::mcare_pta, 0.0);
					} else if(cost_models_mcbs[i]->getPredictedVar() == Vars::mcare_ptb) {
				  	if(person->test(Vars::mcare_ptb_enroll)) {
				    	/* Only predict medicare part B costs for those that are enrolled in it */
				    	cost_models_mcbs[i]->predict(person, random);
				      
				    	/* Adjust the medicare part b cost by the elasticity and percent change in coinsurance, as 
							ptb_new = ptb_modeled * (1 + elas * %chg in coinusrance)
				      */
				    	person->set(Vars::mcare_ptb, person->get(Vars::mcare_ptb)*(1+mcare_ptb_coin_elas->value(person)*mcare_ptb_coin_chg->value(person)));
						} else person->set(Vars::mcare_ptb, 0.0);
					} else if(cost_models_mcbs[i]->getPredictedVar() == Vars::mcare_ptd) {
				  	/* Only predict medicare part D costs for those that are enrolled in it */
				  	if(person->test(Vars::mcare_ptd_enroll)) 
				  		cost_models_mcbs[i]->predict(person, random);
						else 
							person->set(Vars::mcare_ptd, 0.0);
					} else {
				  	cost_models_mcbs[i]->predict(person, random);
					}
				}
				person->set(Vars::mcare, person->get(Vars::mcare_pta) + person->get(Vars::mcare_ptb) + person->get(Vars::mcare_ptd));
			} 
			
			  
			/* Predict medical events */
			if(medicare_elig) {
				/* Use MCBS based models for the medicare eligable */
				for(unsigned int i = 0; i < event_models_mcbs.size(); i++) 
					event_models_mcbs[i]->predict(person, random);
			} else {
				/* Use MEPS based models for the non medicare eligable */
				for(unsigned int i = 0; i < event_models_meps.size(); i++) 
					event_models_meps[i]->predict(person, random);
			}

			if(medicare_elig)	{
				// Reset original values
				person->set(Vars::iadl1, tmp_iadl1);
				person->set(Vars::iadl2p, tmp_iadl2p);
				person->set(Vars::adl1, tmp_adl1);
				person->set(Vars::adl2, tmp_adl2);
				person->set(Vars::adl3p, tmp_adl3p);
			}
			

			/* Scale each cost variable for MCBS/MEPS by the fraction of the year that the person had medicare */
			for(unsigned int i = 0; i < cost_vars_mcbs.size(); i++)
				person->set(cost_vars_mcbs[i], person->get(cost_vars_mcbs[i])*frac_medicare_elig);
			for(unsigned int i = 0; i < cost_vars_meps.size(); i++)
				person->set(cost_vars_meps[i], person->get(cost_vars_meps[i])*(1-frac_medicare_elig));
			
			// Apply growth in medical costs as the product of the real growth, medgrowth, and the cpi
			for(unsigned int i = 0; i < cost_vars.size(); i++)
				person->set(cost_vars[i], person->get(cost_vars[i])*delta_medgrowth);

			// Handle Medicaid eligibility
			if(medicare_elig)
				medicaid_elig_mcbs->predict(person, random);
			else
				medicaid_elig_meps->predict(person, random);
	
			// Since caidmd is already predicted via the cost_vars loops above,
			// all we really need to do is zero it out if the person wasn't eligible for medicaid
			if(!person->test(Vars::medicaid_elig)) {
				person->set(Vars::caidmd_meps, 0.0);
				person->set(Vars::caidmd_mcbs, 0.0);
			}

			// Apply adjustments, used to be based on age greater than or less than 65
			// Now based on Medicare enrollment, since some changes fiddle with eligibility and enrollment in Medicare
			double tot_adj, mcare_adj, mcaid_adj;
			if(person->test(Vars::mcare_pta_enroll) || 
			   person->test(Vars::mcare_ptb_enroll) ||
			   person->test(Vars::mcare_ptd_enroll)) {
				tot_adj = tot_mcbs->value();
				mcare_adj = mcare_mcbs->value();
				mcaid_adj = mcaid_mcbs->value();
			} else {
				tot_adj = tot_meps->value();
				mcare_adj = mcare_meps->value();
				mcaid_adj = mcaid_meps->value();
			}
			
			// Apply the adjustments and set the values
			const double totmd = (person->get(Vars::totmd_meps) + person->get(Vars::totmd_mcbs))*tot_adj;
			const double mcare = (person->get(Vars::mcare))*mcare_adj;
			const double mcare_pta = (person->get(Vars::mcare_pta))*mcare_adj;
			const double mcare_ptb = (person->get(Vars::mcare_ptb))*mcare_adj;
			const double mcare_ptd = (person->get(Vars::mcare_ptd))*mcare_adj;
			const double caidmd = (person->get(Vars::caidmd_meps) + person->get(Vars::caidmd_mcbs))*mcaid_adj;
			const double oopmd = (person->get(Vars::oopmd_mcbs) + person->get(Vars::oopmd_meps));

			// The 18/41 ratio is from Hadley, 2008 showing decline in spending when uninsured
			const double est_mcare_pta = mcare_pta_model->estimate(person) * delta_medgrowth * mcare_adj;
			const double est_mcare_ptb = mcare_ptb_model->estimate(person) * delta_medgrowth * mcare_adj;
			const double est_mcare_ptd = mcare_ptd_model->estimate(person) * delta_medgrowth * mcare_adj;
			const double est_mcare = est_mcare_pta + est_mcare_ptb + est_mcare_ptd;
			double uncovered_upper = totmd - est_mcare + (person->test(Vars::mcare_pta_enroll) ? 0 : est_mcare_pta) + (person->test(Vars::mcare_ptb_enroll) ? 0 : est_mcare_ptb) + (person->test(Vars::mcare_ptd_enroll) ? 0 : est_mcare_ptd);
			double uncovered_lower = totmd - est_mcare + 18.0/41 * ( (person->test(Vars::mcare_pta_enroll) ? 0 : est_mcare_pta) + (person->test(Vars::mcare_ptb_enroll) ? 0 : est_mcare_ptb) + (person->test(Vars::mcare_ptd_enroll) ? 0 : est_mcare_ptd) );

			person->set(Vars::totmd, totmd);
			person->set(Vars::mcare, mcare);
			person->set(Vars::mcare_pta, mcare_pta);
			person->set(Vars::mcare_ptb, mcare_ptb);
			person->set(Vars::mcare_ptd, mcare_ptd);
			person->set(Vars::caidmd, caidmd);
			person->set(Vars::uncovered_upper, uncovered_upper);
			person->set(Vars::uncovered_lower, uncovered_lower);
			person->set(Vars::oopmd, oopmd);
		
			// Assign any drug spending and then drug amount (if appropriate)

			if(variable_provider->get("hrs_data")->value() == 1) {	
						
				// Initialize
				person->set(Vars::anyrx_mcbs,0);
				person->set(Vars::anyrx_mcbs_di,0);
				person->set(Vars::anyrx_meps,0);
				person->set(Vars::rxexp_mcbs,0);	
				person->set(Vars::rxexp_mcbs_di,0);
				person->set(Vars::rxexp_meps,0);
				person->set(Vars::rxexp,0);
						
					
				// Prefer MEPS for under 67 (non-DI) and MCBS for either DI or 67+		
				if(person->get(Vars::age) >= 67) {
					// Expenditures from MCBS
					anyrx_mcbs_model->predict(person, random);
					if(person->test(Vars::anyrx_mcbs)) {
						rxexp_mcbs_model->predict(person, random);
					}
				}
				else {
					// Under 67 and not on DI
					if(!person->test(Vars::diclaim) & !person->test(Vars::l2diclaim)) {
						anyrx_meps_model->predict(person, random);
						if(person->test(Vars::anyrx_meps)) {
							rxexp_meps_model->predict(person, random);
						}
					}	
					// On DI for at least two waves
					else {
						anyrx_mcbs_di_model->predict(person, random);
						if(person->test(Vars::anyrx_mcbs_di)) {
							rxexp_mcbs_di_model->predict(person, random);
						}
					}	
				}	
				// Do accounting - at most one should be non-zero
				person->set(Vars::rxexp, person->get(Vars::rxexp_mcbs) + person->get(Vars::rxexp_mcbs_di) + person->get(Vars::rxexp_meps));
			}
				
		} else person->set(Vars::medicare_elig, false);
	}	
}


void MedCostsModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);
	ref_year = 2004;

	if(variable_provider->exists("mcare_pta_drop_percent"))
	  dropPartA = variable_provider->get("mcare_pta_drop_percent");
	else
	  dropPartA = NULL;

	if(variable_provider->exists("mcare_ptb_drop_percent"))
	  dropPartB = variable_provider->get("mcare_ptb_drop_percent");
	else
	  dropPartB = NULL;

	if(variable_provider->exists("mcare_pta_premium_subsidy_year"))
	  mcare_pta_premium_subsidy_year = variable_provider->get("mcare_pta_premium_subsidy_year");
	else
	  mcare_pta_premium_subsidy_year = variable_provider->addVariable(new GlobalVariable("mcare_pta_premium_subsidy_year", 9999));

	if(variable_provider->exists("mcare_pta_premium_subsidy_share"))
	  mcare_pta_premium_subsidy_share = variable_provider->get("mcare_pta_premium_subsidy_share");
	else
	  mcare_pta_premium_subsidy_share = variable_provider->addVariable(new GlobalVariable("mcare_pta_premium_subsidy_share", 0.0));

	if(variable_provider->exists("mcare_ptb_premium_subsidy_year"))
	  mcare_ptb_premium_subsidy_year = variable_provider->get("mcare_ptb_premium_subsidy_year");
	else
	  mcare_ptb_premium_subsidy_year = variable_provider->addVariable(new GlobalVariable("mcare_ptb_premium_subsidy_year", 9999));

	if(variable_provider->exists("mcare_ptb_premium_subsidy_share"))
	  mcare_ptb_premium_subsidy_share = variable_provider->get("mcare_ptb_premium_subsidy_share");
	else
	  mcare_ptb_premium_subsidy_share = variable_provider->addVariable(new GlobalVariable("mcare_ptb_premium_subsidy_share", 0.0));

	mcare_pta_share = variable_provider->get("mcare_pta_premium_share");
	mcare_ptb_share = variable_provider->get("mcare_ptB_premium_share");
	mcare_ptb_prm_elas = variable_provider->get("mcare_ptb_elasticity");
	mcare_pta_prm_elas = variable_provider->get("mcare_pta_elasticity");
	mcare_pta_premium_baseline = variable_provider->get("mcare_pta_premium_baseline");

	tot_mcbs = variable_provider->get("tot_mcbs");
	tot_meps = variable_provider->get("tot_meps");
	mcaid_mcbs = variable_provider->get("mcaid_mcbs");
	mcaid_meps = variable_provider->get("mcaid_meps");
	mcare_mcbs = variable_provider->get("mcare_mcbs");
	mcare_meps = variable_provider->get("mcare_meps");

	medgrowth_yearly = timeSeriesProvider->get("medgrowth.yearly");
	medgrowth_max = timeSeriesProvider->get("medgrowth.max");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");
	gdp_yearly = timeSeriesProvider->get("gdp.yearly");
	labor = timeSeriesProvider->get("labor");
	mcare_ptb_history = timeSeriesProvider->get("mcare_ptb_historic");
	premium_exemption = timeSeriesProvider->get("premium_exemption");
	mcare_pta_stock = timeSeriesProvider->get("mcare_pta");
	mcare_ptb_stock = timeSeriesProvider->get("mcare_ptb");

	if(timeSeriesProvider->hasSeries("mcare_premium_subsidy_inflation"))
	  mcare_premium_subsidy_inflation = timeSeriesProvider->get("mcare_premium_subsidy_inflation");
	else
	  mcare_premium_subsidy_inflation = new ConstantTimeSeries("mcare_premium_subsidy_inflation", 0, ref_year, medgrowth_yearly->EndYear());

	if(!summary_module->hasMeasure("pop_medicare"))
	  summary_module->addMeasure(new SummaryMeasure(variable_provider->get("weight"), EquationParser::parseString("l2died==0 & medicare_elig", builder), "pop_medicare", "Medicare Eligible population in Millions", 0.000001, EquationParser::parseString("1", builder), "sum"));
	if(!summary_module->hasMeasure("mcare_pta"))
	  summary_module->addMeasure(new SummaryMeasure(variable_provider->get("mcare_pta"), EquationParser::parseString("l2died==0 & mcare_pta_enroll==1", builder), "mcare_pta", "Average Medicare Part A Costs", 1, EquationParser::parseString("weight", builder), "mean"));
	if(!summary_module->hasMeasure("mcare_ptb"))
	  summary_module->addMeasure(new SummaryMeasure(variable_provider->get("mcare_ptb"), EquationParser::parseString("l2died==0 & mcare_ptb_enroll==1", builder), "mcare_ptb", "Average Medicare Part B Costs", 1, EquationParser::parseString("weight", builder), "mean"));
	
}



void MedCostsModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
	std::vector<std::string> missing_models;

	std::string model_name;

	/* Load Medicare Part D Enrollment Model */
	model_name = "mcare_ptd_enroll";
	try{
		mcare_ptd_enroll = mp->get(model_name); 
	} catch (fem_exception e) {
		missing_models.push_back(model_name);
	}

	/* Load Medicare Part B takeup models */
	/* For new enrollees */
	model_name = "mcareb_takeup_newenroll";
	try{
		mcareb_takeup_newenroll = mp->get(model_name); 
	} catch (fem_exception e) {
		missing_models.push_back(model_name);
	}

	/* For current enrollees */
	model_name = "mcareb_takeup_curenroll";
	try{
		mcareb_takeup_curenroll = mp->get(model_name); 
	} catch (fem_exception e) {
		missing_models.push_back(model_name);
	}

	model_name = "mcarea_takeup_newenroll";
	try {
	  mcarea_takeup_newenroll = mp->get(model_name);
	} catch (fem_exception e) {
	  missing_models.push_back(model_name);
	}
	
	model_name = "mcarea_takeup_curenroll";
	try {
	  mcarea_takeup_curenroll = mp->get(model_name);
	} catch (fem_exception e) {
	  missing_models.push_back(model_name);
	}

	model_name = "medicaid_elig_mcbs";
	try {
	  medicaid_elig_mcbs = mp->get(model_name);
	} catch (fem_exception e) {
	  missing_models.push_back(model_name);
	}

	model_name = "medicaid_elig_meps";
	try {
	  medicaid_elig_meps = mp->get(model_name);
	} catch (fem_exception e) {
	  missing_models.push_back(model_name);
	}

	/* Load MCBS based cost models */
	cost_models_mcbs.clear();
	for(unsigned int k = 0; k < cost_vars_mcbs.size(); k++) {
		model_name = VarsInfo::labelOf(cost_vars_mcbs[k]);
		try {
			cost_models_mcbs.push_back(mp->get(model_name)); 
		} catch (fem_exception e) {
			missing_models.push_back(model_name);
		}
	}

	/* Load MEPS based cost models */
	cost_models_meps.clear();
	for(unsigned int k = 0; k < cost_vars_meps.size(); k++) {
		model_name = VarsInfo::labelOf(cost_vars_meps[k]);
		try {
			cost_models_meps.push_back(mp->get(model_name)); 
		} catch (fem_exception e) {
			missing_models.push_back(model_name);
		}
	}
	
	if(variable_provider->get("hrs_data")->value() == 1) {

		/* Load event models for MCBS and MEPS */
		event_models_mcbs.clear();
		event_models_meps.clear();
		for(unsigned int k = 0; k < event_vars.size(); k++) {
			model_name = VarsInfo::labelOf(event_vars[k]) +  "_mcbs";
			try {
				event_models_mcbs.push_back(mp->get(model_name)); 
			} catch (fem_exception e) {
				missing_models.push_back(model_name);
			}
		
			model_name = VarsInfo::labelOf(event_vars[k]) +  "_meps";
			try {
				event_models_meps.push_back(mp->get(model_name)); 
			} catch (fem_exception e) {
				missing_models.push_back(model_name);
			}
		}
		
		/* Models for any Rx and cost of Rx */
		model_name = "anyrx_mcbs";
		try {
		  anyrx_mcbs_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
		
		model_name = "anyrx_mcbs_di";
		try {
		  anyrx_mcbs_di_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
		
		model_name = "anyrx_meps";
		try {
		  anyrx_meps_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
		
		model_name = "rxexp_mcbs";
		try {
		  rxexp_mcbs_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
		
		model_name = "rxexp_mcbs_di";
		try {
		  rxexp_mcbs_di_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
		
		model_name = "rxexp_meps";
		try {
		  rxexp_meps_model = mp->get(model_name);
		} catch (fem_exception e) {
		  missing_models.push_back(model_name);
		}
	}	
	

	mcare_pta_model = mp->get("mcare_pta");
	mcare_ptb_model = mp->get("mcare_ptb");
	mcare_ptd_model = mp->get("mcare_ptd");

	if(missing_models.size() > 0) {
		std::string missing_models_str = "(";
		for(unsigned int i = 0; i < missing_models.size(); i++) {
			missing_models_str += missing_models[i];
			if(i < missing_models.size() - 1)
				missing_models_str += ", ";
		}
		ss << "Medical Costs Module could not find the following needed models:  " << missing_models_str;
		throw fem_exception(ss.str().c_str());
	}
}
