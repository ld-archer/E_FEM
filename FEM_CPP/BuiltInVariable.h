#pragma once
#include "Variable.h"
#include "Vars.h"
#include "utility.h"

class BuiltInVariable :
	public IVariable
{
public:

	BuiltInVariable(Vars::Vars_t v) : var(v) {}

	virtual ~BuiltInVariable(void) 	{}

	virtual inline std::string name() const { return VarsInfo::labelOf(var);}
	virtual inline std::string description() const {return VarsInfo::infoOf(var).desc;}
	virtual inline double value(const Person* person) const {return person->get(var);}
	virtual inline VarTypes::VarTypes_t type() const {return VarsInfo::typeOf(var); }
	virtual inline bool is_missing(const Person* person) const {return person->is_missing(var);}

protected:
	Vars::Vars_t var;
};
