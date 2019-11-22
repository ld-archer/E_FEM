#include "TimeSeries.h"
#include "ConcreteTimeSeries.h"
#include <fstream>
#include <vector>
#include <sstream>
#include "fem_exception.h"
#include "utility.h"
#include <cstring>
#include <map>

ITimeSeries* ITimeSeries::Read(std::string timeseries_name, const char* filename) {
	std::ifstream inf(filename);
	if( inf.bad() || inf.fail())
	  throw fem_exception("Could not open file " + std::string(filename));

	const unsigned BUF_SIZE = 5000;
	char linebuf[BUF_SIZE];
	std::string desc = "";
	std::map<unsigned int, double> values;
	unsigned int cyear;
	double cvalue;
	try {
		while(!inf.eof()) {

			// Read a line
			inf.getline(linebuf, BUF_SIZE);
			
			// For stupid historic reasons, the comment lines begin with a * instead of a |
			if(linebuf[0] == '*') {
				// Comment line. If we dont have a description yet, use this comment as the description
				if(desc == "") {
					desc = linebuf;
					trim(desc);
					desc = desc.substr(2);
				}
			} else if (strlen(linebuf) > 0) {
				// Create a stream to parse the time series values
				std::istringstream iss(linebuf);
				iss >> cyear >> cvalue;
				if(iss.fail()) {
					// Something bad happened trying to read the data. 
					// Most likely, it read something that was not a number
					// Throw an exception
					std::ostringstream ss;
					ss << "There was problem reading the line \"" << linebuf << "\". Please check the time series defination file";
					throw fem_exception(ss.str().c_str());
				} else values[cyear] = cvalue;
				
			}
		}
	} catch (const fem_exception & e) {
		std::ostringstream ss;
		ss << "Error reading time series " << timeseries_name << ": " << e.what();
		throw fem_exception(ss.str().c_str());
	}
	inf.close();
	ITimeSeries* ts = new ConcreteTimeSeries(timeseries_name, values);
	ts->setDescription(desc);
	return ts;

}
