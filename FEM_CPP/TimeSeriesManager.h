#pragma once
#include "TimeSeries.h"
#include "EquationNode.h"
#include <vector>
#include "ProxyTimeSeries.h"
#include <map>

class TimeSeriesManager :
	public ITimeSeriesProvider
{
public:
	TimeSeriesManager(void);
	virtual ~TimeSeriesManager(void);
	virtual ITimeSeries* get(std::string name);
	ITimeSeries* addTimeSeries(ITimeSeries* series);
	ITimeSeries* addTimeSeries(std::string timeseries_name, const char* file);
	void setBuilder(NodeBuilder* builder);
	inline NodeBuilder* getBuilder() {return builder;}
	void readTimeSeriesDefinitions(const char* dir, const char* ext = "*.txt");
	void readTimeSeriesDefinitions(const char* dir, std::vector<ITimeSeries*>& add_series_vec, const char* ext = "*.txt");
	virtual void getAll(std::vector<ITimeSeries*> &vec);
	inline bool hasSeries(std::string name) {return proxy_series_map.count(name) > 0;}

protected:
	std::map<std::string, ITimeSeries*> series_map;
	std::map<std::string, ProxyTimeSeries*> proxy_series_map;
	NodeBuilder* builder;
};
