#pragma once
#include "Module.h"
#include "TimeSeries.h"

class HRSInitializationModule :
	public Module
{
public:
	/** Creates the Initialization Module.
		\param[in]  vp  The runtime variable provider used to obtain the medicare eligibility variable
		\param[in]  timeSeriesProvider The time series provider used to obtain any time series needed by the Module
	*/
	HRSInitializationModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider);
	virtual ~HRSInitializationModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "HRS Initialization Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);
protected:
	/** Model for predictin capital income */
	IModel* hicap_model;
	/** Model for predicting nonzero capital income */
	IModel* hicap_nonzero_model;
	
	/* Model for predicting nonzero property taxes */
	IModel* proptax_nonzero_model;
	
	/* Model for predicting nonzero igxfr */
	IModel* igxfr_nonzero_model;
	IModel* igxfr_model;
	
	/** Model for pain status */
	IModel* painstat_model;
	
	/** Time series for Consumer Price Index */ 
	ITimeSeries* cpi_yearly;
	
	/** Time series for National Wage Index */
	ITimeSeries* nwi;
	
	/** Year the scenario starts */
	unsigned int ref_year;

};
