#pragma once
#include "Variable.h"
#include <sstream>

class ProxyVariable :
	public IVariable
{
public:
	ProxyVariable(void);
	ProxyVariable(std::string n, std::string d = "") 
		: var(NULL), var_name(n), desc(d) {}
	virtual ~ProxyVariable(void);
	virtual double value(const Person* person) const;
	virtual inline std::string name() const { return var_name; }
	virtual inline std::string description() const { return  desc; }
	virtual inline VarTypes::VarTypes_t type() const {return var->type(); }
	virtual inline bool is_missing(const Person* person) const {return var == NULL ? true : var->is_missing(person);}
	void setVar(IVariable* v) { var = v;}
protected:
	IVariable* var;
	std::string var_name;
	std::string desc;
};
