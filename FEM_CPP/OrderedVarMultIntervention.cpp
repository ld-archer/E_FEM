#include "OrderedVarMultIntervention.h"
#include "Logger.h"
#include "Random.h"
#include "utility.h"
#include "ConcreteTimeSeries.h"
#include "GlobalVariable.h"
#include "ProbitRegression.h"
#include <cmath>
#include <sstream>

OrderedVarMultIntervention::OrderedVarMultIntervention(std::string name, Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)  
  :  Intervention(intervention_id, tp, vp), _name(name), var(v)
{
	param_name = "mult_";
	param_name += VarsInfo::labelOf(var);

	elig_var_param_name = "elig_mult_";
	elig_var_param_name += VarsInfo::labelOf(var);

	this->const_mult = vp->addVariable(new GlobalVariable(param_name + "_const_mult", 0.5));
	this->use_ts = false;
	elig_var = vp->get("true");
	std::ostringstream ss;
	ss << const_mult->name();
	params_map[param_name] = ss.str();
	params_map[elig_var_param_name] = "true";
	
 	var_model = NULL;
	var_max = 0;
}

OrderedVarMultIntervention::OrderedVarMultIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)
  : Intervention(intervention_id, tp, vp), var(v)
{
	std::string tmp = VarsInfo::labelOf(var).substr(0,1);
	_name = StringToUpper(tmp);
	_name += VarsInfo::labelOf(var).substr(1);
	_name += "Mult";

	param_name = "mult_";
	param_name += VarsInfo::labelOf(var);

	elig_var_param_name = "elig_mult_";
	elig_var_param_name += VarsInfo::labelOf(var);

	this->const_mult = vp->addVariable(new GlobalVariable(param_name + "_const_mult", 0.5));
	this->use_ts = false;
	elig_var = vp->get("true");
	std::ostringstream ss;
	ss << const_mult->name();
	params_map[param_name] = ss.str();
	params_map[elig_var_param_name] = "true";
	
 	var_model = NULL;
	var_max = 0;
}

OrderedVarMultIntervention::~OrderedVarMultIntervention(void)
{
}

void OrderedVarMultIntervention::setScenario(Scenario* scen) {
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
}

void OrderedVarMultIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Intervention: " << name() << " (" ;
	if(use_ts)
		ss << ts_mult->getName();
	else 
	  ss << const_mult->name();
	ss << ")";
	Logger::log(ss.str(), FINE);
	ss.str("");
	double mult = -1.0;
	elig_var = vp->get(params_map[elig_var_param_name]);
 	var_model = (OrderedProbitRegression*)mp->get(VarsInfo::labelOf(var));
	var_max = var_model->getNumLevels();
	dummy_vars.resize(var_max);
	for(unsigned int i = 0; i < var_max; i++) {
		dummy_vars[i] = Vars::_NONE;
		for(unsigned int j = 0; j < Vars::NVars; j++) {
			if(VarsInfo::infoOf((Vars::Vars_t)j).dummy_for == var && (unsigned int)(VarsInfo::infoOf((Vars::Vars_t)j).category_index) == i + 1) {
				dummy_vars[i] = (Vars::Vars_t)j;
			}
		}
	}
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && !person->test(Vars::l2died) && !person->is_missing(var)) {
		  mult = (use_ts ? ts_mult->Value(year) : const_mult->value(person));
		  double elig_prob = std::max(std::min(elig_var->value(person), 1.0), 0.0);
		  bool elig = random->uniformDist(person->getID(), intervention_id, year) + elig_prob > 1.0;
		  if(elig) {
				unsigned int new_val = std::max(std::min(std::floor(mult*(person->get(var)-1.0) + 0.5)+1.0, (double)var_max), 1.0);
				person->set(var, new_val);
			
				//update any indicators for the levels of var
				for (unsigned int i = 0; i < var_max; i++) {
					if (dummy_vars[i] != Vars::_NONE)
						person->set(dummy_vars[i], new_val == i + 1 ? 1.0 : 0.0);
				}
		  }
		}
	}
}
