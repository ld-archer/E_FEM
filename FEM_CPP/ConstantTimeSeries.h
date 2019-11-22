#pragma once
#include "TimeSeries.h"
#include <string>
#include <limits>

class ConstantTimeSeries :
	public ITimeSeries
{
public:
 ConstantTimeSeries(std::string n, double v, unsigned int stdate=0, unsigned int edate=std::numeric_limits<unsigned int>::max()) 
	  : startdate(stdate), enddate(edate), val(v), name(n) {}
	virtual ~ConstantTimeSeries() {}
	inline virtual double Value(unsigned int year) const {return val;}
	virtual ITimeSeries* CrossSection(unsigned int year_start, unsigned int year_end) const { return new ConstantTimeSeries(name, val, year_start, year_end); }
	virtual unsigned int StartYear() const {return startdate;}
	virtual unsigned int EndYear() const {return enddate;}    
	virtual std::string getName() const {return name;}
	virtual void setName(std::string n) {name = n;}
	virtual std::string getDescription() const {return desc;}
	virtual void setDescription(std::string d) {desc = d;}

protected:
	unsigned int startdate;
       unsigned int enddate;
       double val;
       std::string name;
       std::string desc;
};
