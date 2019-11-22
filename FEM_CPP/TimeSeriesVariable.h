#pragma once
#include "Variable.h"
#include "TimeSeries.h"

class TimeSeriesVariable :
	public IVariable
{
public:
	TimeSeriesVariable(void) {}
	virtual ~TimeSeriesVariable(void) {}
	virtual double value(const Person* person) const {	return series->Value(person->getYear());	}
	virtual std::string name() const { return var_name; }
	virtual std::string description() const { return  desc; }
	virtual VarTypes::VarTypes_t type() const {return VarTypes::Double; }
	virtual bool is_missing(const Person* person) const {return false;}
	void setSeries(ITimeSeries* s) { series = s;}
protected:
	ITimeSeries* series;
	std::string var_name;
	std::string desc;
};
