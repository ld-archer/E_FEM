#include "Scenario.h"

#include <sstream>

#include <iomanip>

#include "fem_exception.h"

Scenario::Scenario(Scenario& source)
{
	scenario_name = source.scenario_name;
    output_dir = source.output_dir;
    simutype = source.simutype;
    base_cohort_name = source.base_cohort_name;
    new_cohort_model = source.new_cohort_model;
    startyr = source.startyr;
	stpyr = source.stpyr;
    endyr = source.endyr;
    yrstep = source.yrstep;
    nreps = source.nreps;
	for(unsigned int i = 0; i < source.init_interventions_str.size(); i++)
		init_interventions_str.push_back(source.init_interventions_str[i]);
	for(unsigned int i = 0; i < source.interventions_str.size(); i++)
		interventions_str.push_back(source.interventions_str[i]);
	
	use_obese_baseline = source.use_obese_baseline;
	obese_baseline = source.obese_baseline;

}

std::string Scenario::describe() {
	std::map<std::string, std::string>::iterator itr;
	std::stringstream strm;
	strm << "Detailed Information for the " << Name() << " scenario: " << std::endl;
	for(itr = params.begin(); itr != params.end(); itr++) {
		strm << std::setw(20) << itr->first << " = " << std::setw(20) << itr->second << std::endl;
	}
	return strm.str();
}

Scenario::~Scenario(void)
{
}


std::string Scenario::get(const std::string& name) {
	if(params.count(name) == 0){
		std::ostringstream ss;
		ss << "No data for parameter [" << name << "]";
		throw fem_exception(ss.str());
	}
	return params[name];
}

