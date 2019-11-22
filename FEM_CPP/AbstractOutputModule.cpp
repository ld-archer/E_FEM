#include "AbstractOutputModule.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>



AbstractOutputModule::AbstractOutputModule(IVariableProvider *vp, std::vector<std::string> var_names)
{
	std::vector<std::string> bad_vars;
	var_provider = vp;
	std::vector<std::string>::iterator it;
	for(it = var_names.begin(); it != var_names.end(); it++) {
		try {
			vars.push_back(vp->get(*it));
		} catch (const fem_exception & e) {
			bad_vars.push_back(*it);
		}
	}
	if(bad_vars.size()) {
		std::ostringstream ss;
		ss  << " Invalid output variables:";
		for(it = bad_vars.begin(); it != bad_vars.end(); it++)
			ss << " " << (*it);
		Logger::log(ss.str(), WARNING);
	}
}

AbstractOutputModule::AbstractOutputModule(IVariableProvider *vp)
{
	var_provider = vp;
	vp->getAll(vars);
}

AbstractOutputModule::~AbstractOutputModule(void)
{
}

