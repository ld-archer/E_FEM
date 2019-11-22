#pragma once
#include "Regression.h"

class OrderedProbitRegression :
	public Regression
{
public:
	OrderedProbitRegression(void);
	OrderedProbitRegression(const OrderedProbitRegression& source);
	virtual ~OrderedProbitRegression(void);
    virtual void predict(Person* person, const Random* random) const;
	virtual double estimate(const Person* person) const {throw fem_exception("OProbit cannot provide an estimate");}
	virtual void predictWithProb(Person* person, const Random* random, double prob) const {throw fem_exception("OProbit cannot predictWithProb");}
	virtual std::string describe() const;
	virtual std::string getName() const {return name;}
	virtual void setName(std::string n) {this->name = n;}

	/** The read method for the OrderedProbitRegression.

	    \todo Update this method to handle the Stata interacted terms format
	*/
	virtual void read(std::istream& inf, IVariableProvider* provider);
	virtual IModel* clone() const { return new OrderedProbitRegression(*this);}
	virtual std::string getTypeDesc() const { return "ordered probit regression";}
	virtual std::string getType() const { return "oprobit";}
	virtual unsigned int getNumLevels() const {return ncuts+1; }

protected:
	int ncuts;
    double* cut_points;
    double* cut_probs;
    double* cut_cum_probs;
    Vars::Vars_t* dummy_vars;
};
