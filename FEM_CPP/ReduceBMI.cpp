#include "ReduceBMI.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>
#include <random>






ReduceBMI::ReduceBMI(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
  Intervention(intervention_id, tp, vp)
{
	params_map["rbmi_start_yr"] = "2012";
}

ReduceBMI::~ReduceBMI(void)
{
}



void ReduceBMI::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	std::string param_name = "rbmi_start_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Reduce BMI intervention needs numbers for parameters (text given for rbmi_start_yr)!");
	} else {
		// User specified a number to use as a constant value
		start_yr = atoi(params_map[param_name].c_str());
	}
}



void ReduceBMI::intervene(PersonVector& persons, unsigned int year, Random* random)
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
				// Yes, treat them
                person->set(Vars::logbmi), person->get(Vars::logbmi) - log(5.0); // Reduce BMI by 5 points (reduce logbmi by log(5))
			}
		}
	}
}

bool SmokeStopIntervention::elig(Person* p) const {
	// Eligible for treatment if BMI > 35
	return p->get(Vars::l2logbmi) > log(35.0);
}

