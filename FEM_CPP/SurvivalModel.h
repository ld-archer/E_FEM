#pragma once
#include "Model.h"

/** The <i>SurvivalModel</i> class serves as a base class for survival models.
	The general survival model simulates whether an outcome happens between two time steps using a survival function. 
	Subclasses implement specific forms of the survival function, such as Weibull, Gompertz, etc.  The survival
	function will typically depend on regressors <b>X</b> that can either be taken from core built-in variables
	such as <code>age</code> or derived variables such as <code>lage65p</code> (an age spline variable). The model 
	specification is read from a flat text with a format that depends on the parameters of the specific survival model.
	The general format is as follows:
	<pre>
	*SurvivalModel
	outcome var name
	var<sub>1</sub> beta<sub>1</sub>
	...  ... 
	var<sub>N</sub> beta<sub>p</sub>
	_cons beta<sub>0</sub>
	[... SURVIVAL PARAMETERS ...]
	| survival settings
	time_variable [VAR]
	origin [NUM]
	time_step [NUM]
	</pre>
	The first line indicates the specific type of survival model. The * should be replaced with the specific type of model,
	e.g., "WeibullPH". The next line indicates the name of the predicted outcome variable. The next p lines give regressor
	coeffecients for the p regressors, if any. The last line of the regression coeffcients must be the constant term 
	(_cons), even if its value is zero.  The [... SURVIVAL PARAMETERS ...] lines will be specific to the type of survival
	model chosen.  The "| survival settings" line precedes general settings for the survival model.  time_variable is 
	the name of the variable used as input to the survival function.  time_variable should be the <b>lagged</b> version of the 
	time variable used for estimation because there is no guarantee that the current value of the time variable has been updated
	since the previous time step.  origin is the beginning value for time_variable.  time_step is the length of each time step 
	in the simulation.
	
	NOTE: The general model assumes that everyone survives until the origin of time_variable.  Survival probabilities before 
	the origin will are treated as certain, i.e., S(t) = 1 if t < 0, inside of the calc_prob() function which is used in 
	predict() and estimate().  The implementation of the survival function itself (psurv()) in any child class of 
	SurvivalModel can take negative time as input, but should throw an exception when this occurs or return 1.0.  
*/
class SurvivalModel :
	public IModel
{
public:
	/** Constructs an empty SurvivalModel. */
	SurvivalModel(void);
		
	/** Constructs a new SurvivalModel based on source model. 
		\param[in]  source  The SurvivalModel to copy
	*/
	SurvivalModel(const SurvivalModel& source);

	virtual ~SurvivalModel(void);

	/** Simulates the new value of the modeled variable.
		The results are stored back into the \a person. 
		\param[in,out]  person  The person to use to both determine regressor values and store the predicted value into
		\param[in] random Used to draw a normal error with variance given by the error term in the model
	*/
  virtual void predict(Person* person, const Random* random) const;
	
	/** 
	Compute outcome probability and store it in appropriate variable for \a person
	Does NOT simulate outcome.
	\param[in]  person  The person to use to compute the probability
	\return The computed probability value that was stored
	*/
	virtual double storeProb(Person* person) const;

	/** 
	Simulate outcome using the prob argument as the probability of the outcome. 
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
					   it is already known that this is a SurvivalModel
	    @param[in] provider The variable provider to query to obtain a handle to each variable name in the model specification

	    \todo Update this method to handle the Stata interacted terms format
	*/
  virtual void read(std::istream& inf, IVariableProvider* provider);

	/** Creates a copy of the SurvivalModel.
		This method is used in the Factory style model creation architecture
		\return A copy of the SurvivalModel
	*/
	virtual IModel* clone() const = 0;

	/** The type of this model.
		This method is used in the Factory style model creation architecture. It is used to match to the first line in the file.
		This name is compatible with the name Stata uses.
		\return The type of this model, "regress"
	*/
	virtual std::string getType() const { return "Survival";}
	
	/** A more human readable type of this mode, "SurvivalModel" */
	virtual std::string getTypeDesc() const = 0;

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
		
	/** Sets the length of a time step in the simulation 
		\param[in] tstep length of time step
	*/
	virtual void set_time_step(IVariable* tstep) {time_step = tstep;}

protected:
	/** Index of the time variable used in the survival funtion. */
	Vars::Vars_t time_var;
		
	/** Value of time_var for which a person becomes "at risk" */
	double time_var_origin;
		
	/** Survival function. 
		\param[in]  person  The person used to determine the value of any regressor values
		\param[in]	t The value of \a time_var at which to compute the survival probability
		\return the probability of person living beyond the current value of \a time_var 
	*/
	virtual double psurv(const Person* person, double t) const = 0;
	
	/** Helper function to load coefficient vectors */
	void load_coefficients(const double cfs[],  IVariable* vs[], const double cps[]);

	/** Calculates <b>X'B</b>. 
		If using parameter bootstrapping, an random term is added to each coeffecients that is calculated at the beginning of each repition 
	*/
	virtual double calc_xb(const Person* person) const;

	/** Index of the predicted variable */
	Vars::Vars_t predicted_var;
	
	/** Array of estimated model coeffecients. */
	double* coeffs;

	/** Array of integer indexes to access variable values */
	IVariable** vars;

	/** Number of predictive variables */
	int nvars;

	/** Name of the model */
	std::string name;

	/** Helper function to compute probability of an event occurring between the current and previous time steps */
	virtual double calc_prob(const Person* person) const;
	
	/** Returns a list of parameter values that are specific to the survival function */
	virtual std::string desc_survfunc() const = 0;
		
	/** Array of perturbations to the coeffecients to use with parameter bootstrapping.
		These are set to zero initially, and therefore not used if not using parameter bootstrapping. 
	*/
	double* coeff_perturbs;
	
	/** 
	Helper function to read in survival function parameters from input file within the read(...) function.  
	Implementation is specific to each type of survival model.
	*/
	virtual void read_survparams(std::istream& inf) = 0;
		
	/** Length of each time step in the simulation */
	IVariable* time_step;
};

