#pragma once
#include "Intervention.h"
#include "OrderedProbitRegression.h"
#include "TimeSeries.h"
#include "Variable.h"

/** This intervention adjusts the level of an ordered outcome through a multiplier.
This assumes that the ordered outcome is a ratio scale variable (e.g., a count) 
with values 0,1,2,...,K and these values are coded in FEM as 1,2,3,...,K+1. The 
probability of intervening is determined by the value of the eligibility variable 
specified in the scenario settings.  The multiplier used for intervention, also 
specified in the scenario settings, can be a constant value or the name of a time 
series or variable in the providers passed to the constructor.
*/
class OrderedVarMultIntervention:
	public Intervention
{
public:
  OrderedVarMultIntervention(std::string name, Vars::Vars_t var, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
  OrderedVarMultIntervention(Vars::Vars_t var, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~OrderedVarMultIntervention(void);
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
	// model used to transtion var
	OrderedProbitRegression* var_model;
	// maximum possible value for var
	unsigned int var_max;
	// indicator variables for the levels of var
  std::vector<Vars::Vars_t> dummy_vars;

};
