#include "TimeSeriesManager.h"
#include "utility.h"
#include <fstream>
#include "fem_exception.h"
TimeSeriesManager::TimeSeriesManager(void)
{
	builder = NULL;
}

TimeSeriesManager::~TimeSeriesManager(void)
{
	for(std::map<std::string, ITimeSeries*>::iterator itr = series_map.begin(); itr != series_map.end(); ++itr)
		delete (*itr).second;

	for(std::map<std::string, ProxyTimeSeries*>::iterator itr = proxy_series_map.begin(); itr != proxy_series_map.end(); ++itr)
		delete (*itr).second;
}


ITimeSeries* TimeSeriesManager::get(std::string name) {
  if(proxy_series_map.count(name) > 0)
    return proxy_series_map[name];
  else
    throw missing_var_exception("TimeSeriesManager does not have entry named " + name, name);
}

ITimeSeries* TimeSeriesManager::addTimeSeries(ITimeSeries* series){
	// If a time series with this name already exists, then delete the existing version
	if(series_map.count(series->getName()))
		delete series_map[series->getName()];
	series_map[series->getName()] = series;
	
	// If there is not yet a proxy time series with this name, then create it
	// and add a lookup node for this time series to the node builder
	if(proxy_series_map.count(series->getName()) == 0) {
		ProxyTimeSeries* p = new ProxyTimeSeries(series->getName(), series->getDescription());
		proxy_series_map[series->getName()] = p;
		if(builder != NULL)
			builder->addLookup(new LookupNode(new TimeSeriesLookup(p)));
	}

	// Have the proxy for this time series point to this new time series
	proxy_series_map[series->getName()]->setSeries(series);
	
	return proxy_series_map[series->getName()];
}

void TimeSeriesManager::setBuilder(NodeBuilder* b) {
	builder = b;
	if(builder != NULL) {
		std::map<std::string, ProxyTimeSeries*>::iterator itr;
		for(itr = proxy_series_map.begin(); itr != proxy_series_map.end(); ++itr)
			if(!builder->containsLookup((*itr).first))
				builder->addLookup(new LookupNode(new TimeSeriesLookup((*itr).second)));
	}
}


ITimeSeries* TimeSeriesManager::addTimeSeries(std::string timeseries_name, const char* file) {
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
	  throw fem_exception("Could not open file " + std::string(file));
	ITimeSeries* ts = ITimeSeries::Read(timeseries_name, file);
	addTimeSeries(ts);
	inf.close();
	return ts;
}



void TimeSeriesManager::readTimeSeriesDefinitions(const char* dir, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		addTimeSeries(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str());
}

void TimeSeriesManager::readTimeSeriesDefinitions(const char* dir, std::vector<ITimeSeries*>& add_series_vec, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		add_series_vec.push_back(addTimeSeries(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str()));
}

void TimeSeriesManager::getAll(std::vector<ITimeSeries*> &vec) {
	std::map<std::string, ProxyTimeSeries*>::iterator itr;
	for(itr = proxy_series_map.begin(); itr != proxy_series_map.end(); ++itr)
		vec.push_back((*itr).second);
}
