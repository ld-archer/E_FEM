#include "AlcoholLockdown.h"
#include "Logger.h"
#include "Random.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>
#include <random>






AlcoholLockdown::AlcoholLockdown(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
        Intervention(intervention_id, tp, vp)
{
    params_map["al_start_yr"] = "2020";
}

AlcoholLockdown::~AlcoholLockdown(void)
{
}



void AlcoholLockdown::setScenario(Scenario* scen) {
    Intervention::setScenario(scen);

    std::string param_name = "al_start_yr";
    if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
        // User specified a time series name to use for the factor
        // We arent setup to do this yet, so throw exception
        throw fem_exception("Alcohol lockdown intervention needs numbers for parameters (text given for al_start_yr)!");
    } else {
        // User specified a number to use as a constant value
        start_yr = atoi(params_map[param_name].c_str());
    }
}



void AlcoholLockdown::intervene(PersonVector& persons, unsigned int year, Random* random)
{
    std::ostringstream ss;
    ss << "Running Intervention: " << name() << std::endl;
    ss << "\t" << "start year = " << start_yr << std::endl;
    Logger::log(ss.str(), FINE);
    ss.str("");
    if(year <= start_yr)
        return;
    std::vector<Person*>::iterator itr;
    for(itr = persons.begin(); itr != persons.end(); ++itr) {
        Person* person = *itr;
        if(person->test(Vars::active) && !person->test(Vars::l2died)) {
            //Are they eligible? (yes everyone is at this stage)
            if(elig(person)) {

                // Take a random subsection of 50% of people to change their consumption habits (20% down, 30% up)
                bool draw = random->uniformDist(person->getID(), this->intervention_id, year) > 0.5;

                if(draw) {
                    // First set treated
                    person->set(Vars::alc_ldown_treated, true);

                    // TODO: Find the paper/gov link where the 20% decrease and 30% increase are quoted
                    // First attempt at this intervention will run as follows (based on values from somewhere, find these):
                    // 20% of people (40% of sample) will decrease their consumption by somewhere between 10-100% (increments of 10%?)
                    // 30% of people (60%) will increase their consumption by somewhere between 10-10%
                    bool down = random->uniformDist(person->getID(), this->intervention_id, year) > 0.6;

                    // set another variable based on up or down movement
                    /*if(down) {
                        //person->set(Vars::alc_ldown_down, true);
                        //person->set(Vars::alc_ldown_up, false);
                    } else {
                        //person->set(Vars::alc_ldown_up, true);
                        //person->set(Vars::alc_ldown_down, false);
                    }*/

                    // if down is true and alcbase above 0, then persons consumption will shift down
                    if(down && person->get(Vars::alcbase) != 0.0) {
                        // get another random uniform draw and multiply by current consumption (reduce by x%)
                        double change_factor = random->uniformDist(person->getID(), this->intervention_id, year); // between 0 & 1
                        person->set(Vars::alcbase, person->get(Vars::alcbase) * change_factor);
                    }

                    // if down is not true and not abstainer then increase (handle abstainers here differently)
                    if(!down && person->get(Vars::alcbase) != 0.0) {
                        // get another random uniform draw +1 and multiply by current consumption (increase by x%)
                        double change_factor = random->uniformDist(person->getID(), this->intervention_id, year) + 1; // between 1 & 2
                        person->set(Vars::alcbase, person->get(Vars::alcbase) * change_factor);
                    }

                    // if down is not true and person is abstainer, draw from normal dist with u set to mean consumption value for gender and age group (taken from HSE data for 2019)
                    if(!down && person->get(Vars::alcbase) == 0.0) {
                        // female 55-64 (including 50-64 as no data before 55)
                        if(!person->test(Vars::male) && person->get(Vars::age) > 49 && person->get(Vars::age) < 65) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year, 10.0, 2.0);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }
                        // female 65-74
                        if(!person->test(Vars::male) && person->get(Vars::age) > 64 && person->get(Vars::age) < 75) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year, 9.3, 2.0);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }
                        // female 75+
                        if(!person->test(Vars::male) && person->get(Vars::age) > 74) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year, 5.7, 1.5);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }

                        // male 50-64
                        if(person->test(Vars::male) && person->get(Vars::age) > 49 && person->get(Vars::age) < 65) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year, 19.5, 3.0);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }
                        // male 65-74
                        if(person->test(Vars::male) && person->get(Vars::age) > 64 && person->get(Vars::age) < 75) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year, 20.9, 3.0);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }
                        // male 75+
                        if(person->test(Vars::male) && person->get(Vars::age) > 74) {
                            double new_alcbase = random->normalDist(person->getID(), this->intervention_id, year,11.7, 2.0);
                            person->set(Vars::alcbase, new_alcbase); // set new alcbase to draw from normal distribution, params above
                        }
                    }

                    // NOW ACCOUNTING (Change consumption group? Consumption below zero? Fix here)
                    // ACCOUNTING
                    // consumption below zero?
                    if(person->get(Vars::alcbase) < 0) {
                        person->set(Vars::alcbase, 0.0);
                    }
                    // update alcstat & alcstat4
                    // Abstainer
                    if(person->get(Vars::alcbase) == 0) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 0);
                        person->set(Vars::alcstat4, 1);
                        // set dummys
                        person->set(Vars::abstainer, 0);
                        person->set(Vars::moderate, 0);
                        person->set(Vars::increasingRisk, 0);
                        person->set(Vars::highRisk, 0);
                    }
                    // Moderate
                    if(person->test(Vars::male) && person->get(Vars::alcbase) > 0 && person->get(Vars::alcbase) <= 22) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 1);
                        person->set(Vars::alcstat4, 2);
                        // set dummys
                        person->set(Vars::moderate, 1);
                        person->set(Vars::increasingRisk, 0);
                        person->set(Vars::highRisk, 0);
                    }
                    if(!person->test(Vars::male) && person->get(Vars::alcbase) > 0 && person->get(Vars::alcbase) <= 15) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 1);
                        person->set(Vars::alcstat4, 2);
                        // set dummys
                        person->set(Vars::moderate, 1);
                        person->set(Vars::increasingRisk, 0);
                        person->set(Vars::highRisk, 0);
                    }
                    // Increasing-risk
                    if(person->test(Vars::male) && person->get(Vars::alcbase) > 22 && person->get(Vars::alcbase) <= 50) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 2);
                        person->set(Vars::alcstat4, 3);
                        // set dummys
                        person->set(Vars::moderate, 0);
                        person->set(Vars::increasingRisk, 1);
                        person->set(Vars::highRisk, 0);
                    }
                    // If female, and consumption between 16-35 units (increasing-risk alcohol consumption)
                    if(!person->test(Vars::male) && person->get(Vars::alcbase) > 15 && person->get(Vars::alcbase) <= 35) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 2);
                        person->set(Vars::alcstat4, 3);
                        // set dummys
                        person->set(Vars::moderate, 0);
                        person->set(Vars::increasingRisk, 1);
                        person->set(Vars::highRisk, 0);
                    }
                    // High-risk
                    if(person->test(Vars::male) && person->get(Vars::alcbase) > 50) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 3);
                        person->set(Vars::alcstat4, 4);
                        // set dummys
                        person->set(Vars::moderate, 0);
                        person->set(Vars::increasingRisk, 0);
                        person->set(Vars::highRisk, 1);
                    }
                    if(!person->test(Vars::male) && person->get(Vars::alcbase) > 35) {
                        // set alcstat vars
                        person->set(Vars::alcstat, 3);
                        person->set(Vars::alcstat4, 4);
                        // set dummys
                        person->set(Vars::moderate, 0);
                        person->set(Vars::increasingRisk, 0);
                        person->set(Vars::highRisk, 1);
                    }
                }
            }
        }
    }
}

bool AlcoholLockdown::elig(Person* p) const {
    // everyone is eligible here, the random sampling will take place in the intervene function because we need
    // access to the `year` variable that isn't available in elig (for uniformDist)
    return true;
}

