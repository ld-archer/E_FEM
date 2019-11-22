#include "InitVarDelta.h"
#include "Logger.h"
#include "Random.h"
#include "utility.h"
#include <sstream>
InitVarDelta::InitVarDelta(std::string name, Vars::Vars_t v, unsigned int intervention_id, bool r, ITimeSeriesProvider* tp, IVariableProvider* vp)  
  : Intervention(intervention_id, tp, vp), _name(name), var(v), reduce(r)
{
	param_name = "p_";
	param_name += VarsInfo::labelOf(var);
	param_name += reduce ? "_reduce" : "_increase";

	prob = 0.5;
	params_map[param_name] = "0.5";

	elig_var_param_name = "elig_p_" ;
	elig_var_param_name += VarsInfo::labelOf(var); 
	elig_var_param_name += reduce ? "_reduce" : "_increase";
	params_map[elig_var_param_name] = "true";
	elig_var = vp->get("true");

	prepCategoricalVars();
}

InitVarDelta::InitVarDelta(Vars::Vars_t v, unsigned int intervention_id, bool r, ITimeSeriesProvider* tp,  IVariableProvider* vp)  
  : Intervention(intervention_id, tp, vp), var(v), reduce(r)
{
	_name = "Init";
	std::string tmp = VarsInfo::labelOf(var).substr(0,1);
	_name += StringToUpper(tmp);
	_name += VarsInfo::labelOf(var).substr(1);
	_name += reduce ? "Reduction" : "Increase";

	param_name = "p_";
	param_name += VarsInfo::labelOf(var);
	param_name += reduce ? "_reduce" : "_increase";

	prob = 0.5;
	params_map[param_name] = "0.5";
	
	elig_var_param_name = "elig_p_" ;
	elig_var_param_name += VarsInfo::labelOf(var); 
	elig_var_param_name += reduce ? "_reduce" : "_increase";
	params_map[elig_var_param_name] = "true";
	elig_var = vp->get("true");

	prepCategoricalVars();
}
void InitVarDelta::prepCategoricalVars() {
	
	is_category_dummy = false;
	other_category_dummies[0] = Vars::_NONE;
	int index = 0;
	if(VarsInfo::infoOf(var).dummy_for != Vars::_NONE) {
		is_category_dummy = true;
		for(unsigned int i = 0; i < Vars::NVars; i++)
		  if(VarsInfo::infoOf((Vars::Vars_t)i).dummy_for == VarsInfo::infoOf(var).dummy_for && (unsigned int) var != i)
				other_category_dummies[index++] = (Vars::Vars_t)i;
		other_category_dummies[index] = Vars::_NONE;
	}	
}
InitVarDelta::~InitVarDelta(void)
{
}



void InitVarDelta::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);

	prob = atof(params_map[param_name].c_str());
	elig_var = vp->get(params_map[elig_var_param_name]);
}

void InitVarDelta::intervene(PersonVector& persons, unsigned int year, Random* random)
{
	std::ostringstream ss;
	ss << "Running Initial Intervention: " << VarsInfo::labelOf(var) << " " << (reduce ? "Reduction" : "Increase" )<< " (" << prob*100 << "%)";
	Logger::log(ss.str(), FINE);
	ss.str("");
	
	Vars::Vars_t lag_var;

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if((person->test(Vars::active)) && !person->test(Vars::l2died) && person->get(Vars::entry) == year) {
		  double individual_prob = prob * elig_var->value(person);
			if((reduce && person->test(var)) || (!reduce && !person->test(var))) {
				if(random->uniformDist(person->getID(), intervention_id, year) + individual_prob > 1.0) {
					person->set(var, !reduce);
					// if turning off a condition, turn off all the lags too
					if(reduce) {
						lag_var = VarsInfo::lagOf(var);
						while(lag_var != Vars::_NONE) {
							person->set(lag_var, false);
							lag_var = VarsInfo::lagOf(lag_var);
						}
					}
					if(is_category_dummy) {
						for(int index = 0; other_category_dummies[index] != Vars::_NONE; index++) {
							person->set(other_category_dummies[index], false);
							// if reducing, adjust the lagged dummies for other categories too
							if(reduce) {
								lag_var = VarsInfo::lagOf(other_category_dummies[index]);
								while(lag_var != Vars::_NONE) {
									person->set(lag_var, false);	
									lag_var = VarsInfo::lagOf(lag_var);
								}
							}
						}
						person->set(VarsInfo::infoOf(var).dummy_for, reduce ? 1 : VarsInfo::infoOf(var).category_index);
						// if reducing, adjust category for all lags too
						if(reduce) {
							lag_var = VarsInfo::lagOf(VarsInfo::infoOf(var).dummy_for);
							while(lag_var != Vars::_NONE) {
								person->set(lag_var, 1);	
								lag_var = VarsInfo::lagOf(lag_var);
							}
						}				
					}
				}
			}
		}
	}
}
