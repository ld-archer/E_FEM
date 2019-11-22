#include "LagModule.h"
#include "Logger.h"

LagModule::LagModule()
{
}

LagModule::~LagModule(void)
{
}




void LagModule::process(PersonVector& persons, unsigned int year, Random* random) {
	Logger::log("Running Lags Module", FINE);
	
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
	  Person* p = *itr;
	  if(p->test(Vars::active)) {
	    for (Vars::Vars_t v = static_cast<Vars::Vars_t>(0); v < Vars::NVars; v++) {
	      if(VarsInfo::lagOf(v) != Vars::_NONE) {
		if(p->is_missing(v))
		  p->set_missing(VarsInfo::lagOf(v));
		else
		  p->set(VarsInfo::lagOf(v), p->get(v));
	      }
	    }
	  }
	}
}
