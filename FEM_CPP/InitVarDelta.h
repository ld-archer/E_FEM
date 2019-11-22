#pragma once
#include "Intervention.h"
/** This class produces a change in the prevalence of variables for the newly entered individuals.

\bug The eligibility variable cannot be a constant value, it assumes it must be a variable
*/
class InitVarDelta:
	public Intervention
{
public:
  InitVarDelta(std::string name, Vars::Vars_t var, unsigned int intervention_id, bool reduce, ITimeSeriesProvider* tp,  IVariableProvider* vp);
  InitVarDelta(Vars::Vars_t var, unsigned int intervention_id, bool reduce, ITimeSeriesProvider* tp,  IVariableProvider* vp);
	virtual ~InitVarDelta(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random) ;
	virtual void setScenario(Scenario* scen);

	virtual inline std::string name() const { return _name;}	

protected:

	void prepCategoricalVars();

	std::string _name;
	std::string param_name;
	std::string elig_var_param_name;
	Vars::Vars_t var;
	IVariable* elig_var;
	double prob;
	bool reduce;

	// To deal with categorical variable dummies
	bool is_category_dummy;
	Vars::Vars_t other_category_dummies[20];

};
