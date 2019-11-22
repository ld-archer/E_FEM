#include "VarProbIntervention.h"
#include "Logger.h"
#include "Random.h"
#include "utility.h"
#include "ConcreteTimeSeries.h"
#include "GlobalVariable.h"
#include "ProbitRegression.h"

#include <sstream>
VarProbIntervention::VarProbIntervention(std::string name, Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)  
  :  Intervention(intervention_id, tp, vp), _name(name), var(v)
{
	param_name = "mult_p";
	param_name += VarsInfo::labelOf(var);

	elig_var_param_name = "elig_mult_p";
	elig_var_param_name += VarsInfo::labelOf(var);

	this->const_mult = vp->addVariable(new GlobalVariable(param_name + "_const_mult", 0.5));
	this->use_ts = false;
	elig_var = vp->get("true");
	std::ostringstream ss;
	ss << const_mult->name();
	params_map[param_name] = ss.str();
	params_map[elig_var_param_name] = "true";

}

VarProbIntervention::VarProbIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)
  : Intervention(intervention_id, tp, vp), var(v)
{
	_name = "P";
	std::string tmp = VarsInfo::labelOf(var).substr(0,1);
	_name += StringToUpper(tmp);
	_name += VarsInfo::labelOf(var).substr(1);
	_name += "Mult";

	param_name = "mult_p";
	param_name += VarsInfo::labelOf(var);

	elig_var_param_name = "elig_mult_p";
	elig_var_param_name += VarsInfo::labelOf(var);

	this->const_mult = vp->addVariable(new GlobalVariable(param_name + "_const_mult", 0.5));
	this->use_ts = false;
	elig_var = vp->get("true");
	std::ostringstream ss;
	ss << const_mult->name();
	params_map[param_name] = ss.str();
	params_map[elig_var_param_name] = "true";
}

VarProbIntervention::~VarProbIntervention(void)
{
}


void VarProbIntervention::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
		// User specified a name to use for the factor
	  if(tp->hasSeries(params_map[param_name])) {
	  	// The name is a time series
	    this->ts_mult = tp->get(params_map[param_name]);
	    this->use_ts = true;
	  } else if(vp->exists(params_map[param_name])) {
	  	// The name is a variable
	    this->use_ts = false;
	    const_mult = vp->get(params_map[param_name]);
	  } else {
	  	// The name is not a time series or variable
	  	throw fem_exception(param_name + " = \"" + params_map[param_name] + "\" is not a valid time series or variable");
	  }
	} else {
		// User specified a number to use as a constant value
	  this->const_mult = vp->addVariable(new GlobalVariable(param_name, atof(params_map[param_name].c_str())));
	    this->use_ts = false;
	}

	elig_var = vp->get(params_map[elig_var_param_name]);
}

void VarProbIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << " (" ;
	if(use_ts)
		ss << ts_mult->getName();
	else 
	  ss << const_mult->name();
	ss << "%)";
	Logger::log(ss.str(), FINE);
	ss.str("");
	double mult = -1.0;
	Vars::Vars_t pvar = VarsInfo::probOf(var);
	std::vector<Person*>::iterator itr;
	ProbitRegression* var_model = (ProbitRegression*)mp->get(VarsInfo::labelOf(var));
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && !person->test(Vars::l2died) && !person->is_missing(pvar)) {
		  mult = (use_ts ? ts_mult->Value(year) : const_mult->value(person));
		  double elig_prob = std::max(std::min(elig_var->value(person), 1.0), 0.0);
		  bool elig = random->uniformDist(person->getID(), intervention_id, year) + elig_prob > 1.0; // Uniform distribution draw; Seeded draw, reproducible
		  if(elig) {
				double new_prob = std::max(std::min(mult*person->get(pvar), 1.0), 0.0);
				person->set(pvar, new_prob);
				var_model->predictWithProb(person, random, new_prob);
		  }
		}
	}
}
