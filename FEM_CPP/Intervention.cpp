#include "Intervention.h"
#include <iomanip>

Intervention::Intervention(unsigned int id, ITimeSeriesProvider* timep, IVariableProvider* varp) : intervention_id(id), tp(timep), vp(varp) { }

void Intervention::describe(std::ostream& strm) const
{
	strm << "Intervention: " << std::setw(20) << name() << std::endl;
	if(params_map.size() > 0)
	{
		strm << "Parameters:" << std::endl;
		std::map<std::string, std::string>::const_iterator itr;
		for(itr = params_map.begin(); itr != params_map.end(); ++itr)
			strm << std::setw(10) << itr->first << " = " << std::ios_base::left << std::setw(20) << itr->second << std::endl;
	}
}


void Intervention::setScenario(Scenario* scen)
{
	std::map<std::string, std::string>::const_iterator itr;
	for(itr = params_map.begin(); itr != params_map.end(); ++itr) {
		std::string val = scen->get(itr->first);
		if(val.length() > 0)
			params_map[itr->first] = val;
	}
}

void Intervention::yearEndHook(Scenario* scenario, Random* random, unsigned int year) {
  last_elig = std::set<Person*>(curr_elig);
  curr_elig.clear();
  last_treated = std::set<Person*>(curr_treated);
  curr_treated.clear();
}

void Intervention::mark_eligible(Person* p) {
  curr_elig.insert(p);
  ever_elig.insert(p);
}

void Intervention::mark_treated(Person* p) {
  curr_treated.insert(p);
  ever_treated.insert(p);
}

void Intervention::reset() {
  curr_treated.clear();
  last_treated.clear();
  ever_treated.clear();

  curr_elig.clear();
  last_elig.clear();
  ever_elig.clear();
}
