#include "BariatricSurg.h"
#include "Logger.h"
#include "Random.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>

BariatricSurg::BariatricSurg(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) : Intervention(intervention_id, tp, vp)
{
	params_map["lapband_start_yr"] = "2010";
	params_map["lapband_full_yr"] = "2050";
	params_map["lapband_full_rate"] = "0.5";
	params_map["lapband_type"] = "1";
	params_map["lapband_10yr_reduction"] = "0.13";
	params_map["bs_elig_bmi1"] = "35";
	params_map["bs_elig_bmi2"] = "40";

	logbmi_model = NULL;


	
	bs_elig_bmi1 = new GlobalVariable("bs_elig_bmi1", 35.0, "Min BMI for Bariatric Surgery, having comorbid conditions");
	bs_elig_bmi2 = new GlobalVariable("bs_elig_bmi2", 40.0, "Min BMI for Bariatric Surgery, without having comorbid conditions");
	yr_step = vp->get("yr_step");

	vp->addVariable(bs_elig_bmi1);
	vp->addVariable(bs_elig_bmi2);
		
}

BariatricSurg::~BariatricSurg(void)
{
}


void BariatricSurg::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	std::string param_name = "lapband_start_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for lapband_start_yr)!");
	} else {
		// User specified a number to use as a constant value
		lapband_start_yr = atoi(params_map[param_name].c_str());
	}

	param_name = "lapband_full_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for lapband_full_yr)!");
	} else {
		// User specified a number to use as a constant value
		lapband_full_yr = atoi(params_map[param_name].c_str());
	}

	param_name = "lapband_full_rate";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for lapband_full_rate)!");
	} else {
		// User specified a number to use as a constant value
		lapband_full_rate = atof(params_map[param_name].c_str());
	}

	param_name = "lapband_type";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for lapband_type)!");
	} else {
		// User specified a number to use as a constant value
		lapband_type = atoi(params_map[param_name].c_str());
	}

	param_name = "lapband_10yr_reduction";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for lapband_10yr_reduction)!");
	} else {
		// User specified a number to use as a constant value
		lapband_10yr_reduction = atof(params_map[param_name].c_str());
	}

	param_name = "bs_elig_bmi1";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for bs_elig_bmi1)!");
	} else {
		// User specified a number to use as a constant value
		bs_elig_bmi1->setVal(atof(params_map[param_name].c_str()));
		log_bs_elig_bmi1 = log(atof(params_map[param_name].c_str()));
	}

	param_name = "bs_elig_bmi2";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Bariatric Surgery intervention needs numbers for parameters (text given for bs_elig_bmi2)!");
	} else {
		// User specified a number to use as a constant value
		bs_elig_bmi2->setVal(atof(params_map[param_name].c_str()));
		log_bs_elig_bmi2 = log(atof(params_map[param_name].c_str()));
	}
	
	// Clear any saved information about the previous run
	pre_treat_logbmi.clear();
	treat_year.clear();
}



void BariatricSurg::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << std::endl;
	ss << "\t" << "start year = " << lapband_start_yr << std::endl;
	ss << "\t" << " full year = " << lapband_full_yr << std::endl;
	ss << "\t" << " full rate = " << lapband_full_rate << std::endl;
	Logger::log(ss.str(), FINE);
	ss.str("");
	if(year <= lapband_start_yr)
		return;
	double prob10yr = std::min(std::max(lapband_full_rate/(lapband_full_yr-lapband_start_yr)*((int)year-lapband_start_yr),0.0),lapband_full_rate);
	double prob = -1.0;
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		prob = 1-pow((1-prob10yr), yr_step->value(person)/10.0);
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			if(!person->test(Vars::bs_treated)) {
				// Person is not treated yet. Are they eligible?
				if(elig(person)) {
					//  Yes, attempt to treat
					bool roll = random->uniformDist(person->getID(), this->intervention_id, year) + prob > 1.0;
					person->set(Vars::bs_treated, roll);
					if(roll)  {
						
						// Save the year the treatment was performed
						treat_year[person->getID()] = year;

						// Apply treatment if treated
						person->set(Vars::logbmi, person->get(Vars::logbmi) + log(1.0-0.2));
					}
				}
			} else {
				// Person already treated. 
				if(this->lapband_type == 1) {
					//	Dont simulate BMI
					person->set(Vars::logbmi, person->get(Vars::l2logbmi));
				} else if(this->lapband_type == 2) { 
					// Simulate using pre-treatment bmi, and then reshift based on the 10yr reduction rate

					// Save the lagged BMI
					double l2logbmi = person->get(Vars::l2logbmi);

					// Restore the pretreatment logbmi
					person->set(Vars::l2logbmi, pre_treat_logbmi[person->getID()]);

					// Predict new bmi based on current traits and pretreatment bmi
					logbmi_model->predict(person, random);

					// Save the new BMI
					pre_treat_logbmi[person->getID()] = person->get(Vars::logbmi);

					// Restore the lagged BMI, reflecting treatment
					person->set(Vars::l2logbmi, l2logbmi);

					// Figure out what is the new reduction based on the 10yr reduction rate
					double reduce;
					if(year - treat_year[person->getID()] >= 10)
						reduce = lapband_10yr_reduction;
					else 
						reduce = (lapband_10yr_reduction - 0.2)/(10.0) * (year - treat_year[person->getID()]) + 0.2;

					// Apply the reduction
					person->set(Vars::logbmi, person->get(Vars::logbmi) + log(1.0-reduce));

				} else {
					// Let the program simulate BMI as it would normally 
				}
			}
		}
	}
}

bool BariatricSurg::elig(Person* p) const {
	// Eligible for treatment if either BMI 35+ and comorbid or func status, or just BMI 40+, and not yet treated, and 50 <= age < =60
	return !p->test(Vars::bs_treated) && p->get(Vars::l2age) < 61 && p->get(Vars::l2age) >= 50 && 
		  (p->get(Vars::l2logbmi) >= log_bs_elig_bmi2 || 
			(p->get(Vars::l2logbmi) >= log_bs_elig_bmi1 &&
			 (p->test(Vars::l2adl1) || p->test(Vars::l2adl2) || p->test(Vars::l2adl3p) || p->test(Vars::l2diabe) || 
				 p->test(Vars::l2hibpe) || p->test(Vars::l2hearte) || p->test(Vars::l2cancre) || 
				 p->test(Vars::l2stroke) || p->test(Vars::l2lunge))
			)
		   );
		
}


void BariatricSurg::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
	try {
		logbmi_model = mp->get("logbmi");
	} catch (fem_exception e) {
		ss << "Bariatric Surgery Intervention needs logbmi model";
	}
	if(ss.str().length() > 0)
		throw fem_exception(ss.str().c_str());
}


void BariatricSurg::postIntervetion(PersonVector& persons, unsigned int year, Random* random) {
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		// Has the person been treated?
		if(person->test(Vars::bs_treated)) {
			// Were they treated this year?
			if(treat_year[person->getID()] == year) {
				// Save the BMI that the person was prior to treatment, by undoing the treatment.
				// Note, that doing it this way allows effects from other interventions on BMI to stick around
				pre_treat_logbmi[person->getID()] = person->get(Vars::logbmi) - log(1.0-0.2);
			}
		}
	}
}

void BariatricSurg::reset() {
  Intervention::reset();
  pre_treat_logbmi.clear();
  treat_year.clear();
}
