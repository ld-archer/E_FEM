#include "ProxyTimeSeries.h"
#include "fem_exception.h"


ProxyTimeSeries::ProxyTimeSeries(void)
{
	series = NULL;
}



double ProxyTimeSeries::Value(unsigned int year) const {
	checkSeries();
	return series->Value(year);
}

unsigned int ProxyTimeSeries::StartYear() const {
	if(series != NULL)
	  return series->StartYear();
	else throw fem_exception(name + " ProxyTimeSeries::StartYear has no underlying series");
}

unsigned int ProxyTimeSeries::EndYear() const {
	if(series != NULL)
	  return series->EndYear();
	else throw fem_exception(name + " ProxyTimeSeries::EndYear has no underlying series");
}

ITimeSeries* ProxyTimeSeries::CrossSection(unsigned int year_start, unsigned int year_end) const {
	checkSeries();
	return series->CrossSection(year_start, year_end);
}

void ProxyTimeSeries::checkSeries() const {
	if(series == NULL) {
		std::ostringstream ss;
		ss << "Proxy time series [" << name << "] has no underlying implementation.";
		throw fem_exception(ss.str());
	}
}
