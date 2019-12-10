#include "ReduceDrinkDays.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>






ReduceDrinkDays::ReduceDrinkDays(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
  Intervention(intervention_id, tp, vp)
{
	params_map["rdd_start_yr"] = "2012";
}

ReduceDrinkDays::~ReduceDrinkDays(void)
{
}



void ReduceDrinkDays::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	std::string param_name = "rdd_start_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Reduce Drink Days intervention needs numbers for parameters (text given for rdd_start_yr)!");
	} else {
		// User specified a number to use as a constant value
		start_yr = atoi(params_map[param_name].c_str());
	}
}



void ReduceDrinkDays::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << std::endl;
	ss << "\t" << "start year = " << start_yr << std::endl;
	Logger::log(ss.str(), FINE);
	ss.str("");
	if(year <= start_yr)
		return;
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && !person->test(Vars::l2died)) {
			//Are they eligible?
			if(elig(person)) {
				//  Yes, treat them
				person->set(Vars::rdd_treated, true);
				person->set(Vars::logbmi, person->get(Vars::drinkd_e) - 2);
			}
		}
	}
}

bool ReduceDrinkDays::elig(Person* p) const {
	// Eligible for treatment if not treated yet, and BMI >= 25
	return !p->test(Vars::rdd_treated) && p->get(Vars::drinkd_e) >= 4;
}
