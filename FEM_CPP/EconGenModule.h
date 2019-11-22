#pragma once
#include "Module.h"
#include "TimeSeries.h"
#include <map>
class EconGenModule :
	public Module
{
public:
  EconGenModule(ITimeSeriesProvider* timeSeriesProvider);
	virtual ~EconGenModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Econ Gen Module";}
	virtual void setModelProvider(IModelProvider* modp);
protected:
	double updateAIME(double aime, double ry_earn, double age, bool male, unsigned int yr) const;
	double DbBenefit(double ry_earn, double tenure, double edu, double age, int era, int nra, unsigned int yr, bool sex) const;
	ITimeSeries* nwi;
//	ITimeSeries* nra;
	std::map<int, std::map<int, std::map<int, double> > > db_type;

	IModelProvider* mp;
	/// Model for predicting property taxes
	IModel* proptax_model;

};
