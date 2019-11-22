/** \file Initializtion module for variables that are not specific to the host data set
This runs BEFORE the initialization modules for each host data set.
It assumes that variables specific to the host data set have not
been initialized.  It can NOT use models that are specific to the 
host data set.
*/

#pragma once
#include "Module.h"
#include "TimeSeries.h"

class GlobalPreInitializationModule :
	public Module
{
public:
	/** Creates the Initialization Module.
		\param[in]  vp  The runtime variable provider used to obtain the medicare eligibility variable
		\param[in]  timeSeriesProvider The time series provider used to obtain any time series needed by the Module
	*/
	GlobalPreInitializationModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider);
	virtual ~GlobalPreInitializationModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Global Initialization Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);
protected:
	/** Model for initializing AFib */
	IModel* afibe_prev_model;

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
