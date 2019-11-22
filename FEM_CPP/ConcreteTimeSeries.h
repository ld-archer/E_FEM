#pragma once
#include "TimeSeries.h"
#include <string>
#include <map>

class ConcreteTimeSeries :
	public ITimeSeries
{
public:
  ConcreteTimeSeries(std::string n, std::map<unsigned int, double> values);
	virtual ~ConcreteTimeSeries();
	virtual double Value(unsigned int year) const;
	virtual ITimeSeries* CrossSection(unsigned int year_start, unsigned int year_end) const;
	virtual unsigned int StartYear() const {return data.begin()->first;}
	virtual unsigned int EndYear() const {return data.rbegin()->first;}    
	virtual std::string getName() const {return name;}
	virtual void setName(std::string n) {name = n;}
	virtual std::string getDescription() const {return desc;}
	virtual void setDescription(std::string d) {desc = d;}

protected:
	std::map<unsigned int, double> data;
       std::string name;
       std::string desc;
};
