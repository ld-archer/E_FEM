#pragma once
#include "Intervention.h"
#include "TimeSeries.h"
#include "Variable.h"

/** This intervention adjusts the probability of an outcome through a multiplier.
The probability of intervening is determined by the value of the eligibility 
variable specified in the scenario settings.  The multiplier used for intervention,
specified in the scenario settings, can be a constant value or the name of a time 
series or variable in the providers passed to the constructor.
*/
class VarProbIntervention:
	public Intervention
{
public:
  VarProbIntervention(std::string name, Vars::Vars_t var, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
  VarProbIntervention(Vars::Vars_t var, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~VarProbIntervention(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random) ;
	virtual void setScenario(Scenario* scen);

	virtual inline std::string name() const { return _name;}	

protected:


	std::string _name;
	std::string param_name;
	Vars::Vars_t var;
	IVariable* const_mult;
	ITimeSeries* ts_mult;
	bool use_ts;
	std::string elig_var_param_name;
	IVariable* elig_var;
};
