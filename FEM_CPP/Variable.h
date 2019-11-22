#pragma once
#include <string>
#include "Person.h"
#include "missing_var_exception.h"

class IVariable
{
public:
	virtual ~IVariable(void) {}
	virtual std::string name() const = 0;
	virtual std::string description() const = 0;
	virtual double value(const Person* person=NULL) const  = 0 ;
	virtual VarTypes::VarTypes_t type() const = 0;
	virtual bool is_missing(const Person* person) const = 0;
};

class IVariableProvider
{
public:
	virtual IVariable* addVariable( IVariable* var) = 0;
	virtual ~IVariableProvider(void) {}
	virtual IVariable* get(std::string name) = 0;
	virtual bool exists(std::string name) const = 0;
	virtual void getAll(std::vector<IVariable*> &vec) = 0;
};

	
