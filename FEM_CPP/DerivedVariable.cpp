#include "DerivedVariable.h"
#include <sstream>


double DerivedVariable::value(const Person* person) const {
	try {
		return node->value(person); 
	} catch (const missing_var_exception & mve) {
		std::ostringstream ss;
		ss << "Derived variable could not be evaluated: missing value for variable, ";
		ss << mve.getVarname() <<  ", in the equation, " <<  this->equation() <<  std::endl;
		ss << "\t" << mve.what();
		throw missing_var_exception(ss.str(), this->name());
	}
}
