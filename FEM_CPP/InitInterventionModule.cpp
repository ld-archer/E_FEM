#include "InitInterventionModule.h"
#include "Logger.h"
#include "utility.h"
InitInterventionModule::InitInterventionModule(InterventionFactory* f) : factory(f)
{
}

InitInterventionModule::~InitInterventionModule(void)
{

}

void InitInterventionModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Interventions Module", FINE);
	for(unsigned int i = 0; i < interventions.size(); i++)
		interventions[i]->intervene(persons, year, random);
	
}

void InitInterventionModule::setScenario(Scenario* scen)  {
	Module::setScenario(scen);
	this->interventions.clear();
	std::vector<std::string> interventions_str;
	str_tokenize(scen->get("init_interventions"), interventions_str);
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
