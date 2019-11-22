#pragma once
#include "Model.h"
#include "VarMap.h"

/** The <i>TableModel</i> class provides the interface of the
<i>IModel</i> class, but simply looks up values in a table and
returns them in order to simulate, predict, or estimate.
*/

class TableModel :
	public IModel
{
	public:
	/** Constructs an empty TableModel. */
	TableModel(void);
		
	/** Constructs a new TableModel based on source model. 
		\param[in]  source  The TableModel to copy
	*/
	TableModel(const TableModel& source);

	virtual ~TableModel(void);

	/** Look up the tabled value for the modeled variable.
		The results are stored back into the \a person. 
		\param[in,out]  person  The person to use to both determine table lookup values and store the predicted value into
		\param[in] random Unused argument for compatibility with stochastic models
	*/
  virtual void predict(Person* person, const Random* random) const;
	
	/** 
	This function is present only for compatibility with stochastic models.
	An exception will be thrown if this function is called.
	*/
	virtual void predictWithProb(Person* person, const Random* random, double prob) const;
	
	/** Look up value of the modeled variable in table.
		The results are not stored back into the \a person. 
		\param[in]  person  The person to use to determine table lookup values
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

	/** Reads table from a flat file.
	    @param[in] inf The file stream to read from. Should be positioned at the second line of the flat file spec since 
					   it is already known that this is a TableModel
	    @param[in] provider The variable provider to query to obtain a handle to each variable name in the table
	*/
  virtual void read(std::istream& inf, IVariableProvider* provider);

	/** Creates a copy of the TableModel.
		This method is used in the Factory style model creation architecture
		\return A copy of the TableModel
	*/
	virtual IModel* clone() const { return new TableModel(*this);}

	/** The type of this model.
		This method is used in the Factory style model creation architecture. It is used to match to the first line in the file.
		This name is compatible with the name Stata uses.
		\return The type of this model, "table"
	*/
	virtual std::string getType() const { return "table";}
	
	/** A more human readable type of this model, "TableModel" */
	virtual std::string getTypeDesc() const { return "Table Model";}

	/** This function is present only for compatibility with
	models estimated from some sample.  Table values are treated
	as deterministic.
	*/
	virtual void perturbParams(Random* random) {}

	/** The variable predicted by this model.
		\return variable predicted by this model
	*/
	virtual Vars::Vars_t getPredictedVar() const {return predicted_var;}
		
protected:
	/** Index of the predicted variable */
	Vars::Vars_t predicted_var;
	
	/** Name of the model */
	std::string name;
		
	/** structure that stores the table data */
	VarMap<double> table; 
};

