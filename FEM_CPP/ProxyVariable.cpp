#include "ProxyVariable.h"
#include "fem_exception.h"


ProxyVariable::ProxyVariable(void)
{
	var = NULL;
}

ProxyVariable::~ProxyVariable(void)
{
}


double ProxyVariable::value(const Person* person) const {
	if(var == NULL) {
		std::ostringstream ss;
		ss << "Cannot obtain value of proxy variable [" << var_name << "]. No underlying implementation set.";
		throw fem_exception(ss.str());
	}
	return var->value(person);
}
