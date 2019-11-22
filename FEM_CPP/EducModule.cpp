#include "EducModule.h"
#include "Logger.h"
#include "utility.h"
#include <sstream>
#include "fem_exception.h"

EducModule::EducModule(IVariableProvider* vp, ITimeSeriesProvider *timeSeriesProvider)
{
	
	variable_provider = vp;
	
}

EducModule::~EducModule(void)
{
}


void EducModule::setScenario(Scenario* scen) {
	Module::setScenario(scen);
	yr_step = scen->YrStep();
}



void EducModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Educ Module", FINE);
	enabled = (variable_provider->get("psid_data")->value() == 1);
  if(enabled) {
  	std::vector<Person*>::iterator itr;
  	for(itr = persons.begin(); itr != persons.end(); ++itr) {
			Person* person = *itr;
			person->set(Vars::running_educ, 1);
				
			more_educ_model->predict(person, random);	

			/* Predict new education level for those getting more */			
			if(person->test(Vars::more_educ)) {
				if(person->get(Vars::l2educlvl) == 1){
					/* two levels 1,2 */
					educ_t1_model->predict(person, random);
					person->set(Vars::educlvl,person->get(Vars::educ_t1) + 1);
				}
				
				
				/* three levels 1,2,3 */
				
				if(person->get(Vars::l2educlvl) == 2){
					/* two levels 1,2 */
					educ_t2_model->predict(person, random);
					person->set(Vars::educlvl,person->get(Vars::educ_t2) + 2);
				}
				
				/* three levels 1,2,3 */
				if(person->get(Vars::l2educlvl) == 3){
					/* two levels 1,2 */
					educ_t3_model->predict(person, random);
					person->set(Vars::educlvl,person->get(Vars::educ_t3) + 3);					
				}
				
				/* two levels 1,2 */
				if(person->get(Vars::l2educlvl) == 4){
					/* two levels 1,2 */
					educ_t4_model->predict(person, random);
					person->set(Vars::educlvl,person->get(Vars::educ_t4) + 4);
				}
				
				if(person->get(Vars::l2educlvl) == 5){
					person->set(Vars::educlvl, 6);
				}
			}	
  	}
  }
}


void EducModule::setModelProvider(IModelProvider* mp) {
	std::ostringstream ss;
		
	try {
		more_educ_model = mp->get("more_educ");
	} catch (fem_exception e) {
		ss << this->description() << " needs more_educ model";
	}
	try {
		educ_t1_model = mp->get("educ_t1");
	} catch (fem_exception e) {
		ss << this->description() << " needs educ_t1 model";
	}
	try {
		educ_t2_model = mp->get("educ_t2");
	} catch (fem_exception e) {
		ss << this->description() << " needs educ_t2 model";
	}	
	try {
		educ_t3_model = mp->get("educ_t3");
	} catch (fem_exception e) {
		ss << this->description() << " needs educ_t3 model";
	}
	try {
		educ_t4_model = mp->get("educ_t4");
	} catch (fem_exception e) {
		ss << this->description() << " needs educ_t4 model";
	}
	
	if(ss.str().length() > 0)
		throw fem_exception(ss.str().c_str());
}
