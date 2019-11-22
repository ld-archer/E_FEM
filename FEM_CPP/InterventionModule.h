#pragma once
#include "Module.h"
#include "Intervention.h"
#include "InterventionFactory.h"
#include <vector>

class InterventionModule :
	public Module
{
public:
	InterventionModule(InterventionFactory* f);
	virtual ~InterventionModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Interventions Module";}
	virtual void setModelProvider(IModelProvider* mp) {}
	virtual void setScenario(Scenario* scen);
	void reset_intervetions();
	virtual void yearEndHook(Scenario* scenario, Random* random, unsigned int year);

protected:
	std::vector<Intervention*> interventions;
	InterventionFactory* factory;
};
