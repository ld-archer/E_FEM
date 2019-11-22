#pragma once
#include "PersonVector.h"
#include "Person.h"
#include "Scenario.h"
#include "Model.h"
#include "TimeSeries.h"
#include "Table.h"
#include "Variable.h"
#include <string>

class SummaryModule;

class Module
{
public:
	virtual ~Module(void) {}
	virtual void process(PersonVector& persons, unsigned int year, Random* random) = 0;
	virtual void setScenario(Scenario* scen) {scenario = scen;}
	virtual std::string description() const = 0;
	virtual void setModelProvider(IModelProvider* mp) { }
	void setSummaryModule(SummaryModule* sm) {summary_module=sm;}
	virtual void yearStartHook(Scenario* scen, Random* random, unsigned int year) {}
	virtual void yearEndHook(Scenario* scen, Random* random, unsigned int year) {}

protected:
	Scenario* scenario;
	IVariableProvider* variable_provider;
	ITimeSeriesProvider* timeSeriesProvider;
	ITableProvider* tableProvider;

	/** A pointer to a Summary Module, used to retrieve desired aggregate statistics */
	SummaryModule* summary_module;

	/** A boolean to control whether or not the module is run */
	bool enabled;
};
