#pragma once
#include "Intervention.h"
#include <set>
class ReduceBMI :
	public Intervention
{
public:
  ReduceBMI(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~ReduceBMI(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual inline std::string name() const { return std::string("ReduceBMI");};
	virtual void setScenario(Scenario* scen);
protected:
	bool elig(Person* p) const;
	unsigned int start_yr;
};
