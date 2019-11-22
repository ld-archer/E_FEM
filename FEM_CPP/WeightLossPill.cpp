#include "WeightLossPill.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>






WeightLossPill::WeightLossPill(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
  Intervention(intervention_id, tp, vp)
{
	params_map["wl_pill_start_yr"] = "2010";
	reduction = 0.05;
}

WeightLossPill::~WeightLossPill(void)
{
}



void WeightLossPill::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	std::string param_name = "wl_pill_start_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Weight Loss Pill intervention needs numbers for parameters (text given for wl_pill_start_yr)!");
	} else {
		// User specified a number to use as a constant value
		start_yr = atoi(params_map[param_name].c_str());
	}
}



void WeightLossPill::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << std::endl;
	ss << "\t" << "start year = " << start_yr << std::endl;
	ss << "\t" << " reduction = " << reduction*100 << "%" << std::endl;
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
				person->set(Vars::wlp_treated, true);
				person->set(Vars::logbmi, person->get(Vars::logbmi) + log(1.0-reduction));
			}
		}
	}
}

bool WeightLossPill::elig(Person* p) const {
	// Eligible for treatment if not treated yet, and BMI >= 25
	return !p->test(Vars::wlp_treated) && p->get(Vars::l2logbmi) >= log(25.0);
}

