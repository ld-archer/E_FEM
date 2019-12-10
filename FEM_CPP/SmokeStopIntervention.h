#pragma once
#include "Intervention.h"
#include <set>
class SmokeStopIntervention :
	public Intervention
{
public:
  SmokeStopIntervention(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~SmokeStopIntervention(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual inline std::string name() const { return std::string("SmokeStopIntervention");};
	virtual void setScenario(Scenario* scen);
protected:
	bool elig(Person* p) const;

	unsigned int start_yr;
	double threshold;
};
