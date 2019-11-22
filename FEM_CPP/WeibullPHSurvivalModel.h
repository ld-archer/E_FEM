#pragma once
#include "SurvivalModel.h"

/** <i>WeibullPHSurvivalModel</i> implements the Weibull proportional hazard survival model.
	The survival function is <code>S(t) = exp{-exp{x beta} t<sup>p</sup>}</code>.
*/
class WeibullPHSurvivalModel :
	public SurvivalModel
{
public:
	/** Constructs an empty WeibullPHSurvivalModel. */
	WeibullPHSurvivalModel(void);
	
	/** Constructs a new WeibullPHSurvivalModel based on source model. 
		\param[in]  source  The WeibullPHSurvivalModel to copy
	*/
	WeibullPHSurvivalModel(const WeibullPHSurvivalModel& source);
	
	virtual ~WeibullPHSurvivalModel(void);
	
	virtual IModel* clone() const { return new WeibullPHSurvivalModel(*this);}

	/** The type of this model.
		This method is used in the Factory style model creation architecture. It is used to match to the first line in the file.
		This name is compatible with the name Stata uses.
		\return The type of this model, "regress"
	*/
	virtual std::string getType() const { return "WeibullPHSurvival";}
	
	/** A more human readable type of this mode, "WeibullPHSurvivalModel" */
	virtual std::string getTypeDesc() const { return "Weibull Prop. Hazard Survival Model";};

protected:
	/** Parameter of the Weibull survival function */
	double p;
	
	/** Survival function. 
		\param[in]  person  The person used to determine the value of any regressor values
		\param[in]	t The value of \a time_var at which to compute the survival probability
		\return the probability of person living beyond the current value of \a time_var 
	*/
	virtual double psurv(const Person* person, double t) const;
	
	/** Returns a list of parameter values that are specific to the survival function */
	virtual std::string desc_survfunc(void) const;
		
  virtual void read_survparams(std::istream& inf);
		
};

