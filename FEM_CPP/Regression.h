#pragma once
#include "Model.h"

/** The <i>Regression</i> class serves as a base class for models of the form <code>y = f(<b>X'B</b>)</code>.
	For the basic regression model, the transformation <code>f(x)=1</code>. Subclasses implement other 
	transformation types. The values of the regressors <b>X</b> can either be taken from core built-in variables
	such as <code>age</code> or derived variables such as <code>lage65p</code> (an age spline variable). The model specification
	is read from a flat text file with the following format:
	<pre>
	regress
	predicted var name
	var<sub>1</sub> beta<sub>1</sub>
	...  ... 
	var<sub>N</sub> beta<sub>N</sub>
	</pre>
	The first line indicates that this is a simple regression model and therefore this class should be used. The next line indicates
	the name of the predicted variable. The next N lines give regressor coeffecient for the N regressors. 
*/
class Regression :
	public IModel
{
public:
	/** Constructs an empty regression model. */
	Regression(void);
	
	/** Constructs an new regression model based on source model. 
		\param[in]  source  The regression model to copy
	*/
	Regression(const Regression& source);

	/** Contructor from data, sets esigma to zero if no argument given */
	Regression(int nv, Vars::Vars_t pvar, std::string n, const double cfs[],  IVariable* vs[], const double cps[], const double esd = 0.0);

	virtual ~Regression(void);

	/** Predicts the new value of the modeled variable.
		The results are stored back into the \a person. 
		\param[in,out]  person  The person to use to both determine regressor values and store the predicted value into
		\param[in] random Used to draw a normal error with variance given by the error term in the model
	*/
    virtual void predict(Person* person, const Random* random) const;
	
	/** 
	Simulate outcome using the prob argument instead of an internally computed probability. 
	Store outcome in appropriate variable for \a person
	Does NOT compute the model probability for the outcome before simulating.
	\param[in]  person  The person to use to compute the probability
	\param[in] random Used to simulate a random draw from the model
	\param[in] prob The probability to use for simulating the outcome
	*/
	virtual void predictWithProb(Person* person, const Random* random, double prob) const;
	
	/** Estimates the new value of the modeled variable.
		The results are not stored back into the \a person. 
		\param[in]  person  The person to use to both determine regressor values
	*/
	virtual double estimate(const Person* person) const;

	/** Describes the model.
		\return A string with the formatted description
	*/
	virtual std::string describe() const;

	/** The name of the model.
		\return String name of the model
	*/
	virtual std::string getName() const {return name;}

	/** Sets the name of the model.
		\param[in] n The new name
	*/
	virtual void setName(std::string n) {name = n;}

	/** Reads model specification from a flat file.
	    @param[in] inf The file stream to read from. Should be positioned at the second line of the flat file spec since 
					   it is already known that this is a simple regression model
	    @param[in] provider The variable provider to query to obtain a handle to each variable name in the model specification

	    \todo Update this method to handle the Stata interacted terms format
	*/
    virtual void read(std::istream& inf, IVariableProvider* provider);

	/** Creates a copy of the regression model.
		This method is used in the Factory style model creation architecture
		\return A copy of the regression model
	*/
	virtual IModel* clone() const { return new Regression(*this);}

	/** The type of this model.
		This method is used in the Factory style model creation architecture. It is used to match to the first line in the file.
		This name is compatible with the name Stata uses.
		\return The type of this model, "regress"
	*/
	virtual std::string getType() const { return "regress";}
	
	/** A more human readable type of this mode, "regression" */
	virtual std::string getTypeDesc() const { return "regression";}

	/** Calculates a random perturbation to add to each parameter for bootstrapping. NOT YET IMPLEMENTED
		The perturbation is calculated as <code>N(0, se<sub>i</sub><sup>2</sup>)</code>. This method should be called at the beginning
		of each repitiion.
		\param[in] random The random number generator to use to calculate the random normal draws.
	*/
	virtual void perturbParams(Random* random) {}

	/** The variable predicted by this model.
		\return variable predicted by this model
	*/
	virtual Vars::Vars_t getPredictedVar() const {return predicted_var;}

protected:
	
	/** Helper function to load coefficient vectors */
	void load_coefficients(const double cfs[],  IVariable* vs[], const double cps[]);

	/** The transform <code>f(<b>X'B</b>)</code> to apply. <code>f(x)=1</code> for simple regression.
		Subclasses implement other versions of this transformation.
	*/
	virtual double transform(double x) const {return x;}

	/** Calculates <b>X'B</b>. 
		If using parameter bootstrapping, an random term is added to each coeffecients that is calculated at the beginning of each repition 
	*/
	virtual double calc_xb(const Person* person) const;

	/** Index of the predicted variable */
	Vars::Vars_t predicted_var;
	
	/** Array of estimated model coeffecients. */
	double* coeffs;

	/** Array of perturbations to the coeffecients to use with parameter bootstrapping.
		These are set to zero initially, and therefore not used if not using parameter bootstrapping. 
	*/
	double* coeff_perturbs;

	/** Array of integer indexes to access variable values */
	IVariable** vars;

	/** Number of predictive variables */
	int nvars;

	/** Std Deviation of error term
		This is used to scale the random normal draw to add to the predicted value
	*/
	double esigma;

	/** Name of the model */
	std::string name;


};

