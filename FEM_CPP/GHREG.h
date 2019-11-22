#pragma once
#include "Regression.h"


/** Implements a generalized inverse hyperbolic sine transform model.
	This model is suited to modeling distributions with a long left tail and some negative values. For example, it used to model wealth and earnings. 
	It is of the form \f$y = \theta^{-1}\sinh[\theta h'(\theta\omega)g + h(\theta\omega)] - \theta\omega\f$ where \f$h(x) = \sinh^{-1}(x)\f$
	and \f$g(x) = x\beta + \sigma\eta\f$. \f$\theta\f$ and \f$\omega\f$ are shape parameters. The model is estimated used maximum likelihood.
*/
class GHREG :
	public Regression
{
public:
	/** Constructs a new empty model */
	GHREG(void);

	virtual ~GHREG(void);

	/** Copy Constructor */
	GHREG(const GHREG& source);

	virtual void predict(Person* person, const Random* random) const;
	virtual IModel* clone() const { return new GHREG(*this);}
	virtual std::string describe() const;
	virtual std::string getType() const { return "ghreg";}
	virtual std::string getTypeDesc() const { return "ghreg";}

	/** Read method for the GHREG model.

	    \todo Update this method to handle the Stata interacted terms format
	*/
	virtual void read(std::istream& inf, IVariableProvider* provider);
	
protected:
	virtual double transform(double g) const;
	double theta, omega, ssr, sqrt_ssr, hb, dhb;
	
};
