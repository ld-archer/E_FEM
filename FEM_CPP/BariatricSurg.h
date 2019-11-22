#pragma once
#include "Intervention.h"
#include "GlobalVariable.h"
#include <map>
class BariatricSurg :
	public Intervention
{
public:
  BariatricSurg(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~BariatricSurg(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);

	/** Saves the new BMI after Bariatric Surgery and all other interventions have been applied. 
		\param[in,out] persons The persons
		\param[in] year The year the intervention is being applied
		\param[in] random The Random number provider 
	*/
	virtual void postIntervetion(PersonVector& persons, unsigned int year, Random* random);


	virtual inline std::string name() const { return std::string("BariatricSurg");};
	virtual void setScenario(Scenario* scen);
	virtual void setModelProvider(IModelProvider* mp);
	virtual void reset();
protected:
	bool elig(Person* p) const;
	
	std::map<unsigned int, double> pre_treat_logbmi;
	std::map<unsigned int, unsigned int> treat_year;
	

	unsigned int lapband_start_yr;
	int lapband_full_yr;
	double lapband_full_rate;
	int lapband_type;
	double lapband_10yr_reduction;

	GlobalVariable* bs_elig_bmi1;
	GlobalVariable* bs_elig_bmi2;
	IVariable* yr_step;

	double log_bs_elig_bmi1;
	double log_bs_elig_bmi2;


	IModel* logbmi_model;
};
