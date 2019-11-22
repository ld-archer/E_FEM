#pragma once
#include "Intervention.h"

#include <list>
#include <set>
class CureIntervention :
	public Intervention
{
public:
  CureIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~CureIntervention(void);
	
	/** Apply the intervention to persons for the year 
		\param[in,out] persons The persons to apply the intervention to
		\param[in] year The year the intervention is being applied
		\param[in] random The Random number provider 
	*/
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual void setScenario(Scenario* scen);
	virtual inline std::string name() const { return _name; }
	virtual void reset();

protected:


	/** Name of the intervention. Usually CureVariable (CureCancre for example) */
	std::string _name;

	/** Parameter name. Usually cure_rate_variable (cure_rate_cancre for example) */
	std::string param_name;

	/** Parameter name for whether or not the cure is permanent */
	std::string param_cure_perm;
		
	/** Parameter name for variable that determines who is eligible to be cured */
	std::string cure_elig_var_param_name;

	/** Variable to apply the cure to */
	Vars::Vars_t var;

	/** The constant cure rate */
	double const_cure_rate;

	/** Whether or not the cure is permanent */
	bool perm_cure;

	/** The time series with the cure rate for each year */
	ITimeSeries* ts_cure_rate;

	/** Indicator for using the time series versus the constant value */
	bool use_ts;
	
	/** Variable that determines eligibility to receive a cure */
	IVariable* cure_elig_var;
};
