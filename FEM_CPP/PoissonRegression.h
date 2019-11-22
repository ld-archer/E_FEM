#pragma once
#include "Regression.h"
#include <math.h>

class PoissonRegression :
	public Regression
{
public:
	PoissonRegression(void);
	PoissonRegression(const PoissonRegression& source);
	virtual ~PoissonRegression(void) 	{	}
	virtual inline IModel* clone() const { return new PoissonRegression(*this);}
	virtual inline std::string getType() const { return "poisson";}
	virtual inline std::string getTypeDesc() const { return "poisson regression";}
protected:
	virtual inline double transform(double x) const {return exp(x);}
};
