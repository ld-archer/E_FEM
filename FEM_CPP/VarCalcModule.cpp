#include "VarCalcModule.h"
#include "Logger.h"

VarCalcModule::VarCalcModule(void)
{
}

VarCalcModule::~VarCalcModule(void)
{
}

void VarCalcModule::process(PersonVector& persons, unsigned int year, Random* random) {
	
	Logger::log("Running Variable Calculations Module", FINE);
	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && !person->test(Vars::l2died)) {
			/* Increment the year by the year step */
			person->set(Vars::year, person->get(Vars::year)+scenario->YrStep());

			/* Calculate the new age */
			person->set(Vars::age, person->get(Vars::year) - person->get(Vars::rbyr) + (7.0 - person->get(Vars::rbmonth))/12);
		}
	}
}
