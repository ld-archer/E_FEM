#pragma once
#include "AbstractOutputModule.h"
#include "Variable.h"
#include <vector>
class OutputModules : public Module
{
public:
	OutputModules(IVariableProvider *vp, std::string output_types, std::string output_var_names);
	virtual ~OutputModules(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const;
	virtual void setScenario(Scenario* scen);
private:
	std::vector<AbstractOutputModule*> outputs;
};
