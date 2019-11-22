#pragma once
#include "Module.h"
#include "TimeSeries.h"

class EarningsModule :
	public Module
{
public:
	EarningsModule(IVariableProvider* vp,ITimeSeriesProvider *timeSeriesProvider);
	virtual ~EarningsModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Earnings Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);

protected:
	/** Model for wealth in 1000's */
	IModel* hatota_model;

	/** Model for earnings in 1000's */
	IModel* iearn_model;
	
	/* Exploring ln(iearn) models and their censoring models*/
	IModel* any_iearn_ue_model;
	IModel* any_iearn_nl_model;
	
	IModel* lniearn_ft_model;
	IModel* lniearn_pt_model;
	IModel* lniearn_ue_model;
	IModel* lniearn_nl_model;
	

	/** Model for uncapped earnings */
	IModel* iearnuc_model;

	/** Model for household capital income */
	IModel* hicap_model;

	/** Model for government transfers */
	IModel* igxfr_model;

	/** Time series for National Wage Index */
	ITimeSeries* nwi;
	
	/** Time series for Consumer Price Index */ 
	ITimeSeries* cpi_yearly;

	/** Time series for Interest Rates */ 
	ITimeSeries* interest_rate;

	/** Reference year (models are in this year's dollars) */
	unsigned int ref_year;
};
