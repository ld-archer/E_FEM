#include "CureIntervention.h"
#include "Logger.h"
#include "utility.h"

#include <sstream>
CureIntervention::CureIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)  :
  Intervention(intervention_id, tp, vp), var(v)
{
	_name = "Cure";
	std::string tmp = VarsInfo::labelOf(var).substr(0,1);
	_name += StringToUpper(tmp);
	_name += VarsInfo::labelOf(var).substr(1);

	param_name = "cure_rate_";
	param_name += VarsInfo::labelOf(var);

	param_cure_perm = "cure_perm_";
	param_cure_perm += VarsInfo::labelOf(var);
		
	cure_elig_var_param_name = "cure_elig_";
	cure_elig_var_param_name += VarsInfo::labelOf(var);

	this->const_cure_rate = 0.5;
	this->use_ts = false;
	this->perm_cure = false;
	cure_elig_var = vp->get("true");
	params_map[cure_elig_var_param_name] = "true";
	params_map[param_cure_perm] = "0";
	std::ostringstream ss;
	ss << const_cure_rate;
	params_map[param_name] = ss.str();
}

CureIntervention::~CureIntervention(void)
{
}



void CureIntervention::setScenario(Scenario* scen)  {
	Intervention::setScenario(scen);

	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a time series name to use for the factor
		this->ts_cure_rate = tp->get(params_map[param_name]);
		this->use_ts = true;

	} else {
		// User specified a number to use as a constant value
		this->const_cure_rate = atof(params_map[param_name].c_str());
		this->use_ts = false;
	}

	if(atof(params_map[param_cure_perm].c_str()) == 0.0 && params_map[param_cure_perm] != "0") {
		// User specified a time series name to use as whether or not to use a permanent cure. 
		// We arent setup to do this yet, so throw exception
		throw fem_exception("Cure intervention needs numbers for perm cure parameters!");
	} else {
		// User specified a number to use as a constant value
		this->perm_cure = atof(params_map[param_cure_perm].c_str());
	}
	
	cure_elig_var = vp->get(params_map[cure_elig_var_param_name]);

}


void CureIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	double cure_rate = (use_ts ? ts_cure_rate->Value(year) : const_cure_rate);
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << " (" << cure_rate << ") Permanent: " << perm_cure;
	Logger::log(ss.str(), FINE);
	ss.str("");
	

	// If doing a permanent cure, iterate through the list of cured persons, and if any got the condition again,
	// then turn it back off 
	if(perm_cure) {
	  for(std::set<Person*>::iterator itr = ever_treated.begin(); itr != ever_treated.end(); itr++) {
			Person* person = *itr;
			if(!person->test(Vars::l2died)) {
				person->set(var, false);
				person->set(VarsInfo::probOf(var), 0);
			}
		}
	}

	// Cure people that are eligible for cures
	for(std::set<Person*>::iterator itr = last_elig.begin(); itr != last_elig.end(); itr++) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			bool roll = random->uniformDist(person->getID(), intervention_id, year) + cure_rate > 1.0;
			person->set(Vars::treat_now, true);
			if(roll) {
				// Cured!
				person->set(var, false);
				person->set(Vars::treat_effective, true);
				mark_treated(person);
			}
		}
	}

	// Set eligibility to be cured next year
	for(PersonVector::iterator itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died)) {
			// Eligible if has condition this year
			if(person->test(var)) {
				// Get eligibility from eligibility var
				double cure_elig_prob = std::max(std::min(cure_elig_var->value(person), 1.0), 0.0);
				bool elig = random->uniformDist(person->getID(), intervention_id, year) + cure_elig_prob > 1.0;
				
				if(elig) mark_eligible(person);
			}
		}
	}
			
}

void CureIntervention::reset()  {
  Intervention::reset();
}
