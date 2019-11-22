#pragma once
#include "Regression.h"
#include <math.h>

class LogitRegression :
	public Regression
{
public:

	LogitRegression(void);
	LogitRegression(const LogitRegression& source);
	virtual ~LogitRegression(void) 	{	}
    virtual void predict(Person* person, const Random* random) const;
    virtual void predictWithProb(Person* person, const Random* random, double prob) const;
	virtual inline IModel* clone() const { return new LogitRegression(*this);}
	virtual inline std::string getType() const { return "logit";}
	virtual inline std::string getTypeDesc() const { return "logit regression";}
protected:
	virtual double transform(double x) const {return 1.0/(1+exp(-x));}
};
