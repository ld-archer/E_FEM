#include "GlobalPostInitializationModule.h"
#include "Logger.h"
#include "SummaryModule.h"
#include "utility.h"
#include <math.h>
#include <sstream>
#include "fem_exception.h"

GlobalPostInitializationModule::GlobalPostInitializationModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider)
{
	medicare_elig_var = vp->get("medicare_eligibility");
	nwi = timeSeriesProvider->get("nwi");
	cpi_yearly = timeSeriesProvider->get("cpi.yearly");

}

GlobalPostInitializationModule::~GlobalPostInitializationModule(void)
{
}



void GlobalPostInitializationModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);
	if(scen->get("psid_data")=="1")
		ref_year = 2009;
	else 
		ref_year = 2010;
}

void GlobalPostInitializationModule::process(PersonVector& persons, unsigned int year, Random* random) {
		
	Logger::log("Running Global Post-Initialization Module", FINE);
	/*
	int simu_type = scenario->SimuType();
	*/

	// Scaling in CPI and NWI
	double delta_cpi = 1.0;
	for(unsigned int i = ref_year; i <= year; i++)
	  delta_cpi *= (1 + cpi_yearly->Value(i));
	/*
		const double delta_nwi = nwi->Value(year)/nwi->Value(ref_year);
	*/

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* p = *itr;
		// Only initialize just added persons
		if(p->get(Vars::entry) == year)  {
			/* Set the medicare part B enrollment for the initial host dataset */
			if(medicare_elig_var->value(p) == 1.0) {
				/* Only do this for people eligable for medicare, but also that are not dead because those that are dead will be missing some key variables */
				if(!p->test(Vars::died))
					init_medicare_partb_enroll->predict(p, random);
				else
					p->set(Vars::mcare_ptb_enroll, false);

				/* Set that this person is enrolled in Medicare */
				p->set(Vars::mcare_pta_enroll, true);
				p->set(Vars::medicare_elig, true);
			} else {
				/* Set that this person is not enrolled in Medicare */
			  p->set(Vars::mcare_pta_enroll, false);
			  p->set(Vars::mcare_ptb_enroll, false);
			}
			
			// If a person is claiming DI, assume they were also claiming it the previous year
			p->set(Vars::l2diclaim, p->test(Vars::diclaim));

		}
	}
}



void GlobalPostInitializationModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
	
	std::string model_name;

	/* Load Medicare Part B initial take up model */
	model_name = "mcareb_takeup_init";
	try{
		init_medicare_partb_enroll = mp->get(model_name);
	} catch (const fem_exception & e) {
		ss << "Global Post-Initialization Module could not find the following needed models: " << model_name;
	}

	if(ss.str().length() > 0)
	  throw fem_exception(ss.str().c_str());
}
