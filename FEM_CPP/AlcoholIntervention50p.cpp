#include "AlcoholIntervention50p.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>
#include <random>






AlcoholIntervention50p::AlcoholIntervention50p(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
        Intervention(intervention_id, tp, vp)
{
    params_map["ai50p_start_yr"] = "2012";
}

AlcoholIntervention50p::~AlcoholIntervention50p(void)
{
}



void AlcoholIntervention50p::setScenario(Scenario* scen) {
    Intervention::setScenario(scen);

    std::string param_name = "ai50p_start_yr";
    if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
        // User specified a time series name to use for the factor
        // We arent setup to do this yet, so throw exception
        throw fem_exception("Alcohol intervention needs numbers for parameters (text given for ai50p_start_yr)!");
    } else {
        // User specified a number to use as a constant value
        start_yr = atoi(params_map[param_name].c_str());
    }
}



void AlcoholIntervention50p::intervene(PersonVector& persons, unsigned int year, Random* random)
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
            //Are they eligible?
            if(elig(person)) {
                // Yes, treat them
                /*// Moderate
                // If male, and consumption between 1-22 units (moderate alcohol consumption)
                if(person->test(Vars::male) && person->get(Vars::alcbase) > 0 && person->get(Vars::alcbase) <= 22) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 0.1);
                }
                // If female, and consumption between 1-15 units (moderate alcohol consumption)
                if(!person->test(Vars::male) && person->get(Vars::alcbase) > 0 && person->get(Vars::alcbase) <= 15) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 0.1);
                }
                // Increasing-risk
                // If male, and consumption between 23-50 units (increasing-risk alcohol consumption)
                if(person->test(Vars::male) && person->get(Vars::alcbase) > 22 && person->get(Vars::alcbase) <= 50) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 0.9);
                }
                // If female, and consumption between 16-35 units (increasing-risk alcohol consumption)
                if(!person->test(Vars::male) && person->get(Vars::alcbase) > 15 && person->get(Vars::alcbase) <= 35) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 0.9);
                }
                // High-risk
                // If male, and consumption above 50 units (high-risk alcohol consumption)
                if(person->test(Vars::male) && person->get(Vars::alcbase) > 50) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 4.2);
                }
                // If female, and consumption above 35 units (high-risk alcohol consumption)
                if(!person->test(Vars::male) && person->get(Vars::alcbase) > 35) {
                    person->set(Vars::alcbase, person->get(Vars::alcbase) - 4.2);
                }*/

                // Changing to a percentage reduction in consumption
                // Moderate (1.5% reduction)
                if(person->test(Vars::moderate)) {
                    //person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.985);
                    person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.5);
                }
                // Increasing Risk (3.9% reduction)
                if(person->test(Vars::increasingRisk)) {
                    //person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.961);
                    person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.5);
                }
                // High Risk (5.6% reduction)
                if(person->test(Vars::highRisk)) {
                    //person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.944);
                    person->set(Vars::alcbase, person->get(Vars::alcbase) * 0.5);
                }

                // ACCOUNTING
                // update alcstat & alcstat4
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

bool AlcoholIntervention50p::elig(Person* p) const {
    // Eligible for treatment if respondent consumed alcohol in week before last survey (i.e. alcbase > 0)
    return (p->get(Vars::alcbase) > 0.0);
}

