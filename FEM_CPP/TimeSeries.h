#pragma once
#include <string>
#include <vector>
class ITimeSeries
{
public:
	virtual ~ITimeSeries(void) {}
    virtual double Value(unsigned int year) const = 0;
    virtual unsigned int StartYear() const = 0;
    virtual unsigned int EndYear() const = 0;
    virtual ITimeSeries* CrossSection(unsigned int year_start, unsigned int year_end) const = 0;
    virtual std::string getName() const = 0;
    virtual void setName(std::string name)= 0;
    virtual std::string getDescription() const = 0;
    virtual void setDescription(std::string desc)= 0;

	static ITimeSeries* Read(std::string timeseries_name, const char* filename);
};



class ITimeSeriesProvider
{
public:
	virtual ~ITimeSeriesProvider(void) {}
	virtual ITimeSeries* get(std::string name) = 0;
	virtual void getAll(std::vector<ITimeSeries*> &vec) = 0;
	virtual bool hasSeries(std::string name) = 0;
};


