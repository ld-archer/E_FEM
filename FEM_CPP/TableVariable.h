#pragma once
#include "Variable.h"
#include "Table.h"

class TableVariable :
	public IVariable
{
public:
	TableVariable(void) {}
	virtual ~TableVariable(void) {}
	virtual double value(const Person* person) const {	return table->Value(*person);	}
	virtual std::string name() const { return var_name; }
	virtual std::string description() const { return  desc; }
	virtual VarTypes::VarTypes_t type() const {return VarTypes::Double; }
	virtual bool is_missing(const Person* person) const {return false;}
	void setTable(ITable* t) { table = t;}
protected:
	ITable* table;
	std::string var_name;
	std::string desc;
};
