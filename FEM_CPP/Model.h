#pragma once

#include <iostream>
#include <istream>
#include "Person.h"
#include "Variable.h"
#include "Random.h"

/** Interface for all predictive models
	A predictive model determines the value of a global or person specific variable based on the variables of that person
	or other global variables. Subclasses implement specific model types, such as regression, probit, and ordered probit models.
	An instance of a model must have a unique name, and this name is used by other modules to obtain a handle to the model.
	Model instances can either be parameterized through external text files loaded at runtime, while more complex models can
	be instantiated and setup during compile time. For models loaded at runtime through external text files, the definition of 
	the model is contained within a plain text file named <code><i>model_name</i>.est</code>. Each model type might require 
	a different format to this text file, however the general format is:
	<pre>
	model_type
	predicted variable name
	var<sub>1</sub> beta<sub>1</sub>
	...  ... 
	var<sub>N</sub> beta<sub>N</sub>
	</pre>
	For models that are created during runtime for external files, the model type specified in the external file is used
	to look up the protoype model object, which is then cloned and used to read the rest of the model specification in the
	external file.
	
	The primary access point for a model is the predict() method, which applies the model to a specific person and stores the result into
	the predicted variable for that person. For some models, such as probits, a Random number generator is required to make a decision 
	on the value of the dependent variable. The estimate() method is also useful for obtaining the predicted value, without storing the result
	into the person object.
*/
class IModel
{
public:
	virtual ~IModel(void) {}

	/** Predicts the value of the modeled variable and stores it 
		The results are stored back into the \a person. 
		\param[in,out]  person  The person to use to both determine regressor values and store the predicted value into
		\param[in] random The random number source to use if this model requires random numbers 
	*/		
    virtual void predict(Person* person, const Random* random) const = 0;

	/** 
	Simulate outcome using the prob argument as the probability. 
	Store outcome in appropriate variable for \a person
	Does NOT compute the model probability for the outcome before simulating.
	\param[in]  person  The person to use to compute the probability
	\param[in] random Used to simulate a random draw from the model
	\param[in] prob The probability to use for simulating the outcome
	*/
	virtual void predictWithProb(Person* person, const Random* random, double prob) const = 0;

	/** Returns the new value of the modeled variable, without storing it
		The results are not stored back into the \a person. 
		\param[in]  person  The person to use to determine regressor values
	*/
	virtual double estimate(const Person* person) const = 0;

	/** Description for the model
		\return model description
	*/
	virtual std::string describe() const = 0;

	/** Model name
		\return model name 
	*/
	virtual std::string getName() const = 0;

	/** Set the name of the model 
		\param[in] name The new name
	*/
    virtual void setName(std::string name) = 0;

	/** Read the model specification from a file
		Each model type has its own specific format for the file structure and parameters that need to be specified. 
		\param[in] inf The file stream to read
		\param[in] provider The variable provider to use to obtain handles to variables specified in the model
	*/
    virtual void read(std::istream& inf, IVariableProvider* provider) = 0;


	/** Creates a clone of the model
		For models that are created during runtime for external files, the model type specified in the external file is used
		to look up the protoype model object, which is then cloned and used to read the rest of the model specification in the
		external file.
		\return The cloned object
	*/
    virtual IModel* clone() const = 0;

	/** The type of the model
		For models that are created during runtime for external files, the model type specified in the external file is used
		to look up the protoype model object, which is then cloned and used to read the rest of the model specification in the
		external file.
		\return model type
	*/
	virtual std::string getType() const = 0;

	/** The description for the type of model
		\return description of model type
	*/
	virtual std::string getTypeDesc() const = 0;

	/** Perturbs the paramters of the model based on their standard errors
		This method is used for parameter bootstrapping, in which for each repition of the simulation, a new set of parameters are 
		drawn for the model based on the estimated mean covariance matrix for the estimated model
		\param[in] random the random number provider 
	*/
	virtual void perturbParams(Random* random) = 0;

	/** The variable predicted by the model
		\return the predicted variable
	*/
	virtual Vars::Vars_t getPredictedVar() const = 0;
};


/** Interface for accessing stored models
	A Model Provider provides an access point for obtaining a handle for a loaded model with a given name.
*/
class IModelProvider
{
public:
	virtual ~IModelProvider(void) {}

	/** Get the model with the specified name
		\param[in] name the name of the model
		\return handle to the model
	*/
	virtual IModel* get(std::string name) = 0;

	/** Fill a vector with all of the active models 
		\param[out] vec the vector to fill
	*/
	virtual void getAll(std::vector<IModel*> &vec) = 0;
};


