#pragma once
#include "AbstractOutputModule.h"
#include "Variable.h"
#include <vector>
class OutputTextModule : public AbstractOutputModule
{
public:
	OutputTextModule(IVariableProvider *vp);
	OutputTextModule(IVariableProvider *vp, std::vector<std::string> var_names);
	virtual ~OutputTextModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Output Text Module";}

};
