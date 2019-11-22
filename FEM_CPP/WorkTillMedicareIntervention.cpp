#include "WorkTillMedicareIntervention.h"
#include "Logger.h"
WorkTillMedicareIntervention::WorkTillMedicareIntervention(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp)  :
  Intervention(intervention_id, tp, vp)
{
	medicare_elig_var = vp->get("medicare_eligibility");
}

WorkTillMedicareIntervention::~WorkTillMedicareIntervention(void)
{
}



void WorkTillMedicareIntervention::setScenario(Scenario* scen) {
	Intervention::setScenario(scen);
	
}

void WorkTillMedicareIntervention::intervene(PersonVector& persons, unsigned int year, Random* random)
{

	/* TO DO: Add any logging information */
	Logger::log("Running Work Until Medicare Intervention", FINE);

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && medicare_elig_var->value(person) == 0.0 && person->test(Vars::l2work) && person->get(Vars::age) >= 65)
			person->set(Vars::work, true);
	}
}
