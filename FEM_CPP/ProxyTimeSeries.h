#pragma once
#include "TimeSeries.h"
#include <sstream>

class ProxyTimeSeries :
	public ITimeSeries
{
public:
	ProxyTimeSeries(void);
	ProxyTimeSeries(std::string n, std::string d = "") 
		: series(NULL), name(n), desc(d) {}
	virtual ~ProxyTimeSeries(void) {}
	virtual double Value(unsigned int year) const;
	virtual unsigned int StartYear() const;
	virtual unsigned int EndYear() const;
	virtual ITimeSeries* CrossSection(unsigned int year_start, unsigned int year_end) const;
	virtual std::string getName() const { return name;}
	virtual void setName(std::string n) {name = n;}
	virtual std::string getDescription() const {return desc;}
	virtual void setDescription(std::string d) {desc = d;}
	void setSeries(ITimeSeries* s) {series = s;}

protected:

	void checkSeries() const;
	ITimeSeries* series;
	std::string name;
	std::string desc;
};
