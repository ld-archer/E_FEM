/** \file Initializtion module for variables that are not specific to the host data set
This runs AFTER the initialization modules for each host data set.
It can use models that are specific to the host data set.
*/

#pragma once
#include "Module.h"
#include "TimeSeries.h"

class GlobalPostInitializationModule :
	public Module
{
public:
	/** Creates the Initialization Module.
		\param[in]  vp  The runtime variable provider used to obtain the medicare eligibility variable
		\param[in]  timeSeriesProvider The time series provider used to obtain any time series needed by the Module
	*/
	GlobalPostInitializationModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider);
	virtual ~GlobalPostInitializationModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Global Initialization Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);
protected:
	/** Model for determining if a person eligable for medicare will have Medicare Part B */
	IModel* init_medicare_partb_enroll;

	/** Variable for calculating if the person is eligible for Medicare */
	IVariable* medicare_elig_var;

	/** Time series for National Wage Index */
	ITimeSeries* nwi;

	/** Time series for Consumer Price Index */ 
	ITimeSeries* cpi_yearly;
	
	/** Time series for normal retirment age */
	ITimeSeries* nra;

	/** Year the scenario starts */
	unsigned int ref_year;
};
