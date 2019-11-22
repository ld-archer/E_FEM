#pragma once
#include "TimeSeries.h"
#include "Person.h"
#include "Model.h"

class SSCalculator
{
public:
	SSCalculator(ITimeSeriesProvider *timeSeriesProvider);
	virtual ~SSCalculator(void);
	double SSBenefit(Person* person, const int cyr, const int rclyr);
	// double SsPIA(double raime, double rq, int rbyr, bool alive, int dthyr);


	/** Calculates the PIA
		\param[in] raime The person's AIME
		\param[in] rq Quarters of coverage
		\param[in] elig_yr Eligibility Year,  the year in which a worker attains age 62, becomes disabled before age 62, or dies before attaining age 62, or based on the widow reindexing
		\return The calculated PIA
	*/
	double SsPIA(double raime, double rq, int elig_yr);

	void test();
	void setModelProvider(IModelProvider* mp);

	double RetBenefit(const Person* person, const int cyr, const int rclyr);
private:



	ITimeSeries* nra;
	ITimeSeries* cola;
	ITimeSeries* nwi;
	ITimeSeries* drc;
	ITimeSeries* eadisreg1;
	ITimeSeries* eadisreg2;

	IModel* isret_wd_model;
};
