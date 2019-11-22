#pragma once
#include "Module.h"
#include "Intervention.h"
#include "InterventionFactory.h"
#include <vector>

class InitInterventionModule :
	public Module
{
public:
	InitInterventionModule(InterventionFactory* f);
	virtual ~InitInterventionModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "InitInterventions Module";}
	virtual void setModelProvider(IModelProvider* mp) {}
	virtual void setScenario(Scenario* scen);

protected:
	std::vector<Intervention*> interventions;
	InterventionFactory* factory;
};
