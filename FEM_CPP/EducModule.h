#pragma once
#include "Module.h"
#include "TimeSeries.h"

class EducModule :
	public Module
{
public:
	EducModule(IVariableProvider* vp,ITimeSeriesProvider *timeSeriesProvider);
	virtual ~EducModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Educ Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);

protected:
	/* Year step in scenario. Used to calculate the rise in earnings/wealth based on the CPI and NWI */
	unsigned int yr_step;
	
	/** Model for getting more education*/
	IModel* more_educ_model;
	
	/* Model for transitioning from educlvl = 1 (less than high school) */
	IModel* educ_t1_model;
	
	/* Model for transitioning from educlvl = 2 (GED/high school) */
	IModel* educ_t2_model;
	
	/* Model for transitioning from educlvl = 3 (some college) */
	IModel* educ_t3_model;
	
	/* Model for transitioning from educlvl = 4 (AA degree) */
	IModel* educ_t4_model;

};
