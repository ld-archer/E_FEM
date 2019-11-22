#include "CrossSectionalModule.h"
#include "Logger.h"
#include <sstream>
#include <algorithm>
#include <fstream>
#include <math.h>
#include "utility.h"
#include "fem_exception.h"

CrossSectionalModule::CrossSectionalModule(IVariableProvider* vp, ITimeSeriesProvider* tp) : sscalc(tp)
{
	mp = NULL;
	qaly_nhm_var = vp->get("qaly_nhmliv_reduction");
	
	variable_provider = vp;
}

CrossSectionalModule::~CrossSectionalModule(void)
{

}


void CrossSectionalModule::setScenario(Scenario* scen) {

	Module::setScenario(scen);
	models.clear();
	vars_to_model.clear();
	if(scen->contains("xsectional")) {
		std::vector<std::string> var_names(10);
		str_tokenize(scen->get("xsectional"), var_names);
		for(unsigned int i = 0; i < var_names.size(); i++) 
			if(VarsInfo::indexOf(var_names[i]) != Vars::_NONE)
				this->vars_to_model.push_back(VarsInfo::indexOf(var_names[i]));
	}
	setModelProvider(mp);

}

void CrossSectionalModule::process(PersonVector& persons, unsigned int year, Random* random)
{
	Logger::log("Running Cross Sectional Module", FINE);
	std::vector<Person*>::iterator itr;

	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;

		// Is the person alive?
		if(person->test(Vars::active) && !person->test(Vars::died)) {

			// Update PIA -- (Comment 7/30/2014) Is this necessary?  PIA is part of the benefit calculation elsewhere.
			if(variable_provider->get("hrs_data")->value() == 1) {
				const double rpia_tmp = sscalc.SsPIA(person->get(Vars::raime), person->get(Vars::rq), person->get(Vars::rbyr)+62);
				person->set(Vars::rpia, rpia_tmp);
			}

			std::vector<Vars::Vars_t>::iterator it;
			for(it = vars_to_model.begin(); it != vars_to_model.end(); ++it) {
				Vars::Vars_t v = *it;
				double qaly = 0.0;
				switch(v) {
				case Vars::qaly:
				  qaly = models[v]->estimate(person);
				  if(person->test(Vars::nhmliv)) qaly *= qaly_nhm_var->value(person);
				  person->set(Vars::qaly, qaly);
				  break;
				default:
				  // Apply the model always if no special case
				  models[v]->predict(person, random);
				  break;
				}
			}
		}
		
		// Update marital status after mortality for PSID simulation
		if(variable_provider->get("psid_data")->value() == 1) {
			if(person->getSpouse() != NULL) {
			
				// Set to widowed/single and uncouple if alive and spouse is dead
				if(!person->test(Vars::died) && person->getSpouse()->test(Vars::died)) {
					person->set(Vars::widowed, true);
					person->set(Vars::widowev, true);
					person->set(Vars::married, false);
					person->set(Vars::cohab, false);
					person->set(Vars::single, true);
					person->set(Vars::mstat_new, 1);
					person->setSpouse(NULL);
				}
				
				// start claiming if widowed and age eligible
				if(person->test(Vars::widowed) && person->get(Vars::l2age) >= 58.0)
					{
							// Setting SS claiming for widows who are eligible for benefits (newly widowed age 60+ or widowed and just reached age 60)
							person->set(Vars::sswclaim, true);
					}
					
				// If the person is dead (but not spouse) set the married/cohab to false and uncouple
				if((person->test(Vars::died) && !person->getSpouse()->test(Vars::died))) {
					person->set(Vars::married, false);
					person->set(Vars::cohab, false);
					person->set(Vars::single, true);
					person->set(Vars::mstat_new, 1);
					person->setSpouse(NULL);
				}
			}
		} else {  // Update marital status after mortality for HRS simulation
			if(person->getSpouse() != NULL) {
				// Set to widowed if alive and spouse is dead, or if already set as widowed
				person->set(Vars::widowed, (!person->test(Vars::died) && person->getSpouse()->test(Vars::died)) || person->test(Vars::widowed)); 

				// If either the spouse or the person is dead (but not both!) set the married to false
				if((person->get(Vars::died)  + person->getSpouse()->get(Vars::died)) == 1)
					person->set(Vars::married, false);
			} else {
				// If there is no spouse at all then definately not married
				person->set(Vars::married, false);
			}
		}
		
		// Setting SS claiming for widows who are eligible for benefits (newly widowed age 60+ or widowed and just reached age 60)
		if(person->test(Vars::widowed) && person->get(Vars::l2age) >= 58.0)
		{
			person->set(Vars::sswclaim, true);
		}

				
		// Accounting for additional children in PSID simulation
    if(variable_provider->get("psid_data")->value() == 1) {
			if(!person->test(Vars::male) && person->get(Vars::l2age) < 43) {
				person->set(Vars::numbiokids,person->get(Vars::l2numbiokids) + person->get(Vars::births) - 1);
			}
			if (person->test(Vars::male) && person->get(Vars::l2age) < 54) {
				person->set(Vars::numbiokids,person->get(Vars::l2numbiokids) + person->get(Vars::paternity) - 1);
			}
			if (person->get(Vars::numbiokids) != person->get(Vars::l2numbiokids)) {
				person->set(Vars::yrsnclastkid,1);
			}
			else {
				person->set(Vars::yrsnclastkid,person->get(Vars::yrsnclastkid)+2);
			}
		}
			
		
		// reset chfe if hearte was turned off
		if(!person->test(Vars::hearte))
			person->set(Vars::chfe, false);
				
		//	  Assign heartae based on hearta 
		if(variable_provider->get("hrs_data")->value() == 1) {
			if (person->test(Vars::hearta)==0)
			person->set(Vars::heartae,person->get(Vars::l2heartae));
			else (person->set(Vars::heartae,1));		
		}
	
	// Accounting for SSDI benefits in FAM
    if(variable_provider->get("psid_data")->value() == 1) {
    	if (!person->test(Vars::diclaim) ) {
    		person->set(Vars::ssdiamt, 0);
			}	
		}	
				
		// Accounting for SSI benefits in FAM
    if(variable_provider->get("psid_data")->value() == 1) {
    	if (!person->test(Vars::ssiclaim) ) {
    		person->set(Vars::ssiamt, 0);
			}	
		}				

	// Accounting for SS OASI benefits in FAM
    if(variable_provider->get("psid_data")->value() == 1) {
    	if (!person->test(Vars::oasiclaim) ) {
    		person->set(Vars::ssoasiamt, 0);
			}	
		}	
					
	}
}


void CrossSectionalModule::setModelProvider(IModelProvider* modp) {
	std::ostringstream ss;

	mp = modp;
	if(mp == NULL)
		return;


	try {
		sscalc.setModelProvider(mp);
	} catch (fem_exception e) {
		ss << e.what();
	}
		
	std::vector<Vars::Vars_t>::iterator it;
	for(it = vars_to_model.begin(); it != vars_to_model.end() && ss.str().length() == 0; ++it) {	
		try {
			models[*it] = mp->get(VarsInfo::labelOf(*it));
		} catch (fem_exception e) {
			ss << this->description() << " needs model " << VarsInfo::labelOf(*it);
		}
	}
	if(ss.str().length() > 0)
		throw fem_exception(ss.str().c_str());
}
