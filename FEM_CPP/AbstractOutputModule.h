#pragma once
#include "Module.h"
#include "Variable.h"
#include <vector>

/** This class handles the output of person-level data.

\bug Variables creates in a settings directory vars.txt but NOT in the global vars.txt do not get output with detailed output. The variables are still used properly in the CPP code, though.
*/
class AbstractOutputModule :
	public Module
{
public:
	AbstractOutputModule(IVariableProvider *vp);
	AbstractOutputModule(IVariableProvider *vp, std::vector<std::string> var_names);
	virtual ~AbstractOutputModule(void);
protected:
	IVariableProvider* var_provider;
	std::vector<IVariable*> vars;
};
