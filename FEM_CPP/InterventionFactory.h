#pragma once

#include "Intervention.h"
#include "Variable.h"
#include "TimeSeries.h"
#include "Model.h"
#include <map>

class InterventionFactory
{
public:
	InterventionFactory(IVariableProvider* vp, ITimeSeriesProvider* tp);
	~InterventionFactory(void);
	Intervention* getIntervention(std::string name);
	void setModelProvider(IModelProvider* mp);
protected:
	std::map<std::string, Intervention*> interventions;

};
