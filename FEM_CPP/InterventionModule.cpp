#include "InterventionModule.h"
#include "Logger.h"
#include "utility.h"
InterventionModule::InterventionModule(InterventionFactory* f) : factory(f)
{
}

InterventionModule::~InterventionModule(void)
{

}

void InterventionModule::reset_intervetions() {
	for(unsigned int i = 0; i < interventions.size(); i++)
		interventions[i]->reset();
}


/** \todo If someone accidentally puts the name of an initial intervention in the regular interventions column, throw an error or something.

\todo If the parameters for an intervention are left blank, throw an error.
*/
void InterventionModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Interventions Module", FINE);

	// Clear treatment indicators
	for(std::vector<Person*>::iterator itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && !person->test(Vars::l2died)) {
			person->set(Vars::treat_now, false);
			person->set(Vars::treat_effective, false);
		}
	}

	// Run the pre Intervention hooks
	for(unsigned int i = 0; i < interventions.size(); i++)
		interventions[i]->preIntervetion(persons, year, random);

	// Apply the interventions
	for(unsigned int i = 0; i < interventions.size(); i++)
		interventions[i]->intervene(persons, year, random);

	// Run the post intervention hooks
	for(unsigned int i = 0; i < interventions.size(); i++)
		interventions[i]->postIntervetion(persons, year, random);
	
}

void InterventionModule::setScenario(Scenario* scen)  {
	Module::setScenario(scen);
	this->interventions.clear();
	std::vector<std::string> interventions_str;
	str_tokenize(scen->get("interventions"), interventions_str);
	for(unsigned int i = 0; i < interventions_str.size(); i++) {
		if(interventions_str[i].length() > 0) {
			Intervention* inter = factory->getIntervention(interventions_str[i]);
			if(inter != NULL) {
				inter->setScenario(scen);
				this->interventions.push_back(inter);
			} else
				Logger::log(std::string("No intervention named [") + interventions_str[i] + std::string("] found."), WARNING);
		}
	}		
}

void InterventionModule::yearEndHook(Scenario* scenario, Random* random, unsigned int year) {
  std::vector<Intervention*>::iterator i;
  for(i=interventions.begin(); i != interventions.end(); i++)
    (*i)->yearEndHook(scenario, random, year);
}
