#pragma once
#include "ProbitRegression.h"
#include "utility.h"

class ShiftedProbitRegression :
	public ProbitRegression
{
public:

	ShiftedProbitRegression(void);
	ShiftedProbitRegression(const ShiftedProbitRegression& source);
	virtual ~ShiftedProbitRegression(void) 	{	}
	virtual IModel* clone() const { return new ShiftedProbitRegression(*this);}
	virtual std::string getType() const { return "shifted_probit";}
	virtual std::string getTypeDesc() const { return "shifted probit regression";}
	virtual void read(std::istream& inf, IVariableProvider* provider);
protected:
	virtual double calc_xb(const Person* person) const { return ProbitRegression::calc_xb(person) + getShift(person->getYear()); }
	std::map<unsigned int, double> xb_shifts;
	double getShift(unsigned int year) const;
};
