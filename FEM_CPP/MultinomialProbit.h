#pragma once
#include "Regression.h"
#include <math.h>
#include <vector>

/** This class implements a multinomial probit regression for unordered choices.

    \todo Add a unit test to confirm that this class does what it should.
*/
class MultinomialProbit :
	public Regression
{
public:

	MultinomialProbit(void);
	MultinomialProbit(const MultinomialProbit& source);
	virtual ~MultinomialProbit(void);
	/** The read method for the MultinomialProbit

	    \todo Update this method to handle the Stata interacted terms format
	*/
	virtual void read(std::istream& inf, IVariableProvider* provider);
	virtual void predict(Person* person, const Random* random) const;
	virtual double estimate(const Person* person) const {throw fem_exception("MProbit cannot provide an estimate");}
	virtual void predictWithProb(Person* person, const Random* random, double prob) const {throw fem_exception("MProbit cannot predictWithProb");}
	virtual inline IModel* clone() const { return new MultinomialProbit(*this);}
	virtual inline std::string getType() const { return "mprobit";}
	virtual inline std::string getTypeDesc() const { return "multinomial probit regression";}
	virtual std::string describe() const;
protected:
	std::vector<Regression*> regs;
	std::vector<Vars::Vars_t> dummy_vars;
	// dummy_var_indexes stores the contents of dummy_vars casted as unsigned int so repeated casting isn't necessary 
	std::vector<unsigned int> dummy_var_indexes;	
	std::vector< std::vector<double> > cholesky_cov;
};
