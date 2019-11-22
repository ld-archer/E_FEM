#pragma once
#include "Regression.h"
#include "utility.h"

class ProbitRegression :
	public Regression
{
public:

	ProbitRegression(void);
	ProbitRegression(const ProbitRegression& source);
	virtual ~ProbitRegression(void) 	{	}
  virtual void predict(Person* person, const Random* random) const;
	virtual IModel* clone() const { return new ProbitRegression(*this);}
	virtual std::string getType() const { return "probit";}
	virtual std::string getTypeDesc() const { return "probit regression";}
		
	/** 
	Compute outcome probability and store it in appropriate variable for \a person
	Does NOT simulate outcome.
	\param[in]  person  The person to use to compute the probability
	\return The computed probability value that was stored
	*/
	virtual double storeProb(Person* person) const;

	/** 
	Simulate outcome using the prob argument as the probability of mortality. 
	Store outcome in appropriate variable for \a person
	Does NOT compute the model probability for the outcome before simulating.
	\param[in]  person  The person to use to compute the probability
	\param[in] random Used to simulate a random draw from the model
	\param[in] prob The probability to use for simulating the outcome
	*/
	virtual void predictWithProb(Person* person, const Random* random, double prob) const;
protected:
	virtual double transform(double x) const {return cum_normal(x);}
};
