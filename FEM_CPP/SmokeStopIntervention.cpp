#include "SmokeStopIntervention.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>
#incldue <random.h>






SmokeStopIntervention::SmokeStopIntervention(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
  Intervention(intervention_id, tp, vp)
{
	params_map["ssi_start_yr"] = "2012";
	elig_threshold = 0.5;
}

SmokeStopIntervention::~SmokeStopIntervention(void)
{
}



void SmokeStopIntervention::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	std::string param_name = "ssi_start_yr";
	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Smoke stop intervention needs numbers for parameters (text given for rdd_pill_start_yr)!");
	} else {
		// User specified a number to use as a constant value
		start_yr = atoi(params_map[param_name].c_str());
	}
}



void SmokeStopIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
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
				person->set(Vars::ssi_treated, true);
				// Set smoke_stop to 1 for this wave
				person->set(Vars::smoke_stop, 1);
				
				// Now a former smoker
				person->set(Vars::smkstat,2.0);
				// Quit, so turn current off
				person->set(Vars::smoken,0.0);
				// Maintain smokev status
				person->set(Vars::smokev,person->get(Vars::l2smokev));
				// Clean up other vars - didn't start, too
				person->set(Vars::smoke_start,0.0);
			}
		}
	}
}

bool SmokeStopIntervention::elig(Person* p) const {
	// Eligible for treatment if not treated yet, and smoken == 1
	// Want to call a random uniform distribution between 0 & 1 so 
	// we can "decide" who gets the intervention. i.e. check if 
	// sample is above threshold (defined above) and then make eligible

//	return !p->test(Vars::ssi_treated) && p->get(Vars::smoken) == 1;

    std::default_random_engine generator;
    std::uniform_real_distribution<double> distribution(0.0,1.0);

    double sample = distribution(generator);



    return !p->test(Vars::ssi_treated) && p->get(Vars::smoken) == 1 && sample > elig_threshold;
}

