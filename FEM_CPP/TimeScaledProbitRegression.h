#pragma once
#include "ProbitRegression.h"
#include "utility.h"

class TimeScaledProbitRegression :
	public ProbitRegression
{
public:

	TimeScaledProbitRegression(void);
	TimeScaledProbitRegression(const TimeScaledProbitRegression& source);
	virtual ~TimeScaledProbitRegression(void) 	{	}
	virtual inline IModel* clone() const { return new TimeScaledProbitRegression(*this);}
	virtual inline std::string getType() const { return "time_scaled_probit";}
	virtual inline std::string getTypeDesc() const { return "time rescaled probit regression";}

	/** Reads the model. Just like a normal probit specification, except the line after the dependent variable contains the modeled number of years in the transition */
	virtual void read(std::istream& inf, IVariableProvider* provider);

	/** Calculates the probability of the event by calculating P = 1 - (1 - CDF(xb))^(yr_step/modeled years), then applies the random draw */
	virtual void predict(Person* person, const Random* random) const;
protected:
	
	/** The modeled number of years for the transition model. */
	int modeled_delta_year;
	IVariable* yr_step;
};
