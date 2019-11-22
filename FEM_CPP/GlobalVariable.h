#pragma once
#include "Variable.h"

class GlobalVariable :
	public IVariable
{
public:
	GlobalVariable(std::string name, double v, std::string d = "") 
		: val(v), var_name(name), desc(d) {}
  virtual ~GlobalVariable(void) { };
	virtual inline double value(const Person* person=NULL) const {return val;}
	virtual inline std::string name() const { return var_name; }
	virtual inline std::string description() const { return  desc; }
	virtual inline VarTypes::VarTypes_t type() const {return VarTypes::Double; }
	virtual inline bool is_missing(const Person* person=NULL) const {return false;}
	void inline setVal(double v) { val = v;}
protected:
	double val;
	std::string var_name;
	std::string desc;
};
