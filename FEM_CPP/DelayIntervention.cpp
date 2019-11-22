#include "DelayIntervention.h"
#include "Logger.h"
#include "Random.h"
#include "utility.h"
#include "ConcreteTimeSeries.h"

#include <sstream>
DelayIntervention::DelayIntervention(std::string name, Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)  
  : Intervention(intervention_id, tp, vp), _name(name), var(v)
{
	param_name = "delay_";
	param_name += VarsInfo::labelOf(var);

	this->const_delay_yrs = 0;
	this->use_ts = false;
	std::ostringstream ss;
	ss << const_delay_yrs;
	params_map[param_name] = ss.str();

}

DelayIntervention::DelayIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)
  : Intervention(intervention_id, tp, vp), var(v)
{
	_name = "Delay";
	std::string tmp = VarsInfo::labelOf(var).substr(0,1);
	_name += StringToUpper(tmp);
	_name += VarsInfo::labelOf(var).substr(1);

	param_name = "delay_";
	param_name += VarsInfo::labelOf(var);

	elig_var_param_name = "elig_delay_";
	elig_var_param_name += VarsInfo::labelOf(var);

	this->const_delay_yrs = 0;
	this->use_ts = false;
	elig_var = vp->get("true");

	std::ostringstream ss;
	ss << const_delay_yrs;
	params_map[param_name] = ss.str();
	params_map[elig_var_param_name] = "true";
}

DelayIntervention::~DelayIntervention(void)
{
}


void DelayIntervention::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		this->ts_delay_yrs = tp->get(params_map[param_name]);
		this->use_ts = true;

	} else {
		// User specified a number to use as a constant value
	  const_delay_yrs = std::strtoul(params_map[param_name].c_str(), NULL, 10);
		this->use_ts = false;
	}

	// Clear the vectors storing the persons with alzheimers and the delays
	for(int i = 0; i < MAX_DELAY; i++)
		delay_persons[i].clear();
	curr_delay = 0;

	// Get the number of years between steps
	yr_step = scen->YrStep();
	
	elig_var = vp->get(params_map[elig_var_param_name]);
}


void DelayIntervention::reset() {
  Intervention::reset();
	// Clear the vectors storing the persons with alzheimers and the delays
	for(int i = 0; i < MAX_DELAY; i++)
		delay_persons[i].clear();
	curr_delay = 0;

}

void DelayIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << " (" ;
	if(use_ts)
		ss << ts_delay_yrs->getName();
	else 
		ss << const_delay_yrs;
	ss << " years)";
	Logger::log(ss.str(), FINE);
	ss.str("");
	unsigned int delay =  (use_ts ? (unsigned int) ts_delay_yrs->Value(year) : const_delay_yrs);
	std::vector<Person*>::iterator itr;
	
	// Process all alive persons. For each one that has a new occurance of this condition, set the condition to false
	// and add the person to the delay structure
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		// Is the person alive?
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			// Is it a new event of this condition?
			if(person->test(var) && !person->test(VarsInfo::lagOf(var))) {
				// Yes! First, check/generate eligibility 
				double elig_prob = std::max(std::min(elig_var->value(person), 1.0), 0.0);
				bool elig = random->uniformDist(person->getID(), intervention_id, year) + elig_prob > 1.0;
				if(elig) {
					//Eligible, so unset the persons status in this variable
					person->set(var, false);
				
					// Add this person to the delay structure. We want this person to be delayed "delay" years,
					// so add them to the vector at index (curr_delay + delay+yr_step) % MAX_DELAY
					// The extra yr_step is there because we have not yet applied the condition to those that have
					// waited their full delay. So it is as if these persons need to wait their delay, PLUS the yr_step
					// that has not yet occured (but will in a moment)
					delay_persons[(curr_delay + delay+yr_step) % MAX_DELAY].push_back(person);
				}
			}
		}
	}
	
	// Apply the year steps. In case the delay is not a multiple of year step (for example, delay = 3 yrs and year step is 2 yrs),
	// what we will do is iteratively
	//		shift by 1 year, 
	//		find who has waited long enough (meaning they are at index curr_delay % MAX_DELAY),
	//		apply the condition
	// until we have done the required number of year steps
	for(unsigned int i = 0; i < yr_step; i++) {
		curr_delay++; // Shift the number the tracks the people who have waited long enough
		
		// Iterate through the persons that have waited long enough, and apply the condition to them
		for(itr = delay_persons[curr_delay % MAX_DELAY].begin(); itr != delay_persons[curr_delay % MAX_DELAY].end(); ++itr) {
			Person* person = *itr;
			// Is this person still alive or did they die this wave? We dont want to do anything to them if they died before getting the condition.  
			// We do want to assign the condition to those who died in the same wave that they would get the condition.
			if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
				// Yes, the person is alive. Set the value of the condition
				person->set(var, true);
			}
		}

		// After processing the persons that have waited the full amount, clear out that vector
		delay_persons[curr_delay % MAX_DELAY].clear();
	}
}
