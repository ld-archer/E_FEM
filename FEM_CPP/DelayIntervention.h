#pragma once
#include "Intervention.h"
#include "TimeSeries.h"

class DelayIntervention:
	public Intervention
{
public:
  DelayIntervention(std::string name, Vars::Vars_t c, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
  DelayIntervention(Vars::Vars_t v, unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~DelayIntervention(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random) ;
	virtual void setScenario(Scenario* scen);

	virtual inline std::string name() const { return _name;}	
	virtual void reset();
protected:


	std::string _name;
	std::string param_name;
	Vars::Vars_t var;
	unsigned int const_delay_yrs;
	ITimeSeries* ts_delay_yrs;
	bool use_ts;
	static const int MAX_DELAY = 20;
	std::vector<Person*> delay_persons[MAX_DELAY];
	unsigned int curr_delay;
	unsigned int yr_step;
	std::string elig_var_param_name;
	IVariable* elig_var;
};
