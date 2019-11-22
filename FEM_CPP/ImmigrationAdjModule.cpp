#include "ImmigrationAdjModule.h"
#include <math.h>
#include "Logger.h"
#include <sstream>
#include <string>
#include "fem_exception.h"
#include <cstring>
#include "utility.h"
#include "VarMap.h"

ImmigrationAdjModule::ImmigrationAdjModule(IVariableProvider* vp, ITableProvider* tabp) 
{
	tableProvider = tabp;
	variable_provider=vp;
	netMigration = tableProvider->get("immigration");
}

ImmigrationAdjModule::~ImmigrationAdjModule(void)
{
	clear();
}

void ImmigrationAdjModule::clear() {
	netMigration = NULL;
}

void ImmigrationAdjModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Immigration Adjustment Module", FINE);
	std::vector<Person*>::iterator itr;
			
	double age;
	
	// use dummy to shift person to lag and interim years without direct modification of person
	// dummy helps avoid accidental changes to person that don't get undone
	Person dummy; 
	
	VarMap<double> wt1(variable_provider, netMigration->getIndexTemplate().getNames());
		
	/* Calculate weights. Use lag age + 1 to account for population shifts in the inbetween year */
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
	  dummy = **itr; 
	  // back up age and year to the inbetween year
	  dummy.set(Vars::age, (int)(dummy.get(Vars::l2age)) + 1);
	  dummy.set(Vars::year, dummy.get(Vars::year) - 1);
	  
	  if(dummy.test(Vars::active) && !dummy.test(Vars::l2died) && netMigration->isIndex(dummy)) {
			if(dummy.get(Vars::weight) < 0.0) 
				throw fem_exception("Person has negative weight before immigration adjustment (interim year)");
			else {
				double sumwt = wt1.isIndexKey(dummy) ? wt1.get(dummy) : 0.0;
				wt1.set(dummy, sumwt + dummy.get(Vars::weight));
			}
		}					
	}


	/* Adjust weights */
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		dummy = *person;

		if(dummy.test(Vars::active) && !dummy.test(Vars::l2died)) {
		  // back 2 years
		  dummy.set(Vars::age, (int)dummy.get(Vars::l2age));
		  dummy.set(Vars::year, dummy.get(Vars::year) - yr_step);
			if(netMigration->isIndex(dummy)) {
			  // back 1 year
				dummy.set(Vars::age, (int)dummy.get(Vars::l2age) + 1);
				dummy.set(Vars::year, dummy.get(Vars::year) + 1);
				if(netMigration->isIndex(dummy)) {
					double weight = dummy.get(Vars::weight);

					if(weight > 0.0) {
						double netmig, palive, cellwt;
						netmig = netMigration->Value(dummy);
						cellwt = wt1.get(dummy);
						
						if(netmig < 0 && -netmig > cellwt) {
							std::ostringstream ss;
							ss << "Negative weight due to migration (interim year). Setting weight to zero. Check your migration assumptions. Cell weight before migration=" << cellwt;
							Logger::log(ss.str(), INFO);
							ss.str("");
							person->set(Vars::weight, 0.0);
						}
						else {		

							//if positive net migration, reduce by proportion who died during the first year
							palive = netmig > 0 ? pow(1.0-dummy.get(Vars::pdied),1.0/2.0) : 1.0;
						
							person->set(Vars::weight, weight + weight*netmig*palive*(1.0/cellwt));
						}
					}
				}
			}
		}
	}

	VarMap<double> wt2(variable_provider, netMigration->getIndexTemplate().getNames());

	/* Recalculate weights */
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
	  dummy = **itr;
	  // round age
		dummy.set(Vars::age, (int)dummy.get(Vars::age));
		if(dummy.test(Vars::active) && !dummy.test(Vars::l2died) && netMigration->isIndex(dummy)) {
	  	if(dummy.get(Vars::weight) < 0.0) 
				throw fem_exception("Person has negative weight before immigration adjustment");
			else {
				double sumwt = wt2.isIndexKey(dummy) ? wt2.get(dummy) : 0.0;
				wt2.set(dummy, sumwt + dummy.get(Vars::weight));
			}
		}
	}

	/* Adjust weights */
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		dummy = *person;
		age = dummy.get(Vars::age);

		if(dummy.test(Vars::active) && !dummy.test(Vars::l2died)) {
			// back 2 years
			dummy.set(Vars::age, (int)age - yr_step);
			dummy.set(Vars::year, dummy.get(Vars::year) - yr_step);
			if(netMigration->isIndex(dummy)) {
				// now
				dummy.set(Vars::age, (int)age);
				dummy.set(Vars::year, dummy.get(Vars::year) + yr_step);
				if(netMigration->isIndex(dummy)) {
					double weight = dummy.get(Vars::weight);
						
					if(weight > 0.0) {
						double netmig, cellwt;
						netmig = netMigration->Value(dummy);
						cellwt = wt2.get(dummy);
						
						if(netmig < 0 && -netmig > cellwt) {
							std::ostringstream ss;
							ss << "Negative weight due to migration. Setting weight to zero. Check your migration assumptions. Cell weight before migration=" << cellwt;
							Logger::log(ss.str(), INFO);
							person->set(Vars::weight, 0.0);
						}
						else {
							person->set(Vars::weight, weight + weight*netmig*(1.0/cellwt));
						}
					}
				}
			}
		}
	}
}

void ImmigrationAdjModule::setScenario(Scenario* scen) {
	scenario = scen;
	
	yr_step = scen->YrStep();
}


