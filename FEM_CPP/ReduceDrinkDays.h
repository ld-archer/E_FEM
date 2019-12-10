#pragma once
#include "Intervention.h"
#include <set>
class ReduceDrinkDays :
	public Intervention
{
public:
  ReduceDrinkDays(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~ReduceDrinkDays(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual inline std::string name() const { return std::string("ReduceDrinkDays");};
	virtual void setScenario(Scenario* scen);
protected:
	bool elig(Person* p) const;

	unsigned int start_yr;
};
