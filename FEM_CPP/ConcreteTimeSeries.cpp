#include "ConcreteTimeSeries.h"
#include "fem_exception.h"
#include <sstream>

ConcreteTimeSeries::ConcreteTimeSeries(std::string n, std::map<unsigned int, double> values) : data(values) {
	name = n;
}

ConcreteTimeSeries::~ConcreteTimeSeries(void)
{
  data.clear();
}

double ConcreteTimeSeries::Value(unsigned int year) const {
  if(StartYear() <= year && year <= EndYear()) {
    if(data.count(year) > 0) {
      return data.at(year);
    } else {
      std::ostringstream ss;
      ss << getName() << " does not have data for " << year << " even though it is within the start/end range";
      throw fem_exception(ss.str());
    }
  } else {
    std::ostringstream ss;
    ss << getName() << " has a range of (" << StartYear() << "," << EndYear() << "), which does not include " << year;
    throw fem_exception(ss.str());
  }
}

ITimeSeries* ConcreteTimeSeries::CrossSection(unsigned int year_start, unsigned int year_end) const {
  if (year_start < StartYear())
    year_start = StartYear();
  if (year_end > EndYear())
    year_end = EndYear();
  std::map<unsigned int, double>::const_iterator start = data.find(year_start);
  std::map<unsigned int, double>::const_iterator end = data.find(year_end);
  std::map<unsigned int, double> slice(start, end);
  ITimeSeries* new_series = new ConcreteTimeSeries(name, slice);
  return new_series;
}

