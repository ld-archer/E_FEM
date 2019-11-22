#pragma once
#include "Intervention.h"
#include <set>
class WeightLossPill :
	public Intervention
{
public:
  WeightLossPill(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~WeightLossPill(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual inline std::string name() const { return std::string("WeightLossPill");};
	virtual void setScenario(Scenario* scen);
protected:
	bool elig(Person* p) const;

	unsigned int start_yr;
	double reduction;
};
