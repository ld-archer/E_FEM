#pragma once
#include "Regression.h"
#include <math.h>
#include <vector>

/** This class implements a multinomial logit regression for unordered choices.

    \todo Add a unit test to confirm that this class does what it should.
*/
class MultinomialLogit :
	public Regression
{
public:

	MultinomialLogit(void);
	MultinomialLogit(const MultinomialLogit& source);
	virtual ~MultinomialLogit(void);
	/** The read method for the MultinomialLogit

	    \todo Update this method to handle the Stata interacted terms format
	*/
	virtual void read(std::istream& inf, IVariableProvider* provider);
	virtual void predict(Person* person, const Random* random) const;
	virtual double estimate(const Person* person) const {throw fem_exception("MLogit cannot provide an estimate");}
	void predictWithProb(Person* person, const Random* random, double prob) const {throw fem_exception("MLogit cannot predictWithProb");}
	virtual inline IModel* clone() const { return new MultinomialLogit(*this);}
	virtual inline std::string getType() const { return "mlogit";}
	virtual inline std::string getTypeDesc() const { return "multinomial logit regression";}
	virtual std::string describe() const;
protected:
	std::vector<Regression*> regs;
	Vars::Vars_t* dummy_vars;
};
