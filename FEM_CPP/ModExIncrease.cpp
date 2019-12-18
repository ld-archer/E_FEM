// Created by ld-archer on 16/12/2019.
#include "ModExIncrease.h"
#include "Logger.h"
#include "fem_exception.h"
#include <sstream>
#include <math.h>






ModExIncrease::ModExIncrease(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp) :
        Intervention(intervention_id, tp, vp)
{
    params_map["rdd_start_yr"] = "2012";
}

ModExIncrease::~ModExIncrease(void)
{
}



void ModExIncrease::setScenario(Scenario* scen) {
    Intervention::setScenario(scen);

    std::string param_name = "mei_start_yr";
    if(atof(params_map[param_name].c_str()) == 0.0 && params_map[param_name] != "0") {
        // User specified a time series name to use for the factor
        // We arent setup to do this yet, so throw exception
        throw fem_exception("Moderate Exercise Increase intervention needs numbers for parameters (text given for mei_start_yr)!");
    } else {
        // User specified a number to use as a constant value
        start_yr = atoi(params_map[param_name].c_str());
    }
}



void ModExIncrease::intervene(PersonVector& persons, unsigned int year, Random* random)
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
                //  Yes, treat them
                person->set(Vars::mei_treated, true);
                person->set(Vars::mdactx_e, person->get(Vars::mdactx_e) - 2);
            }
        }
    }
}

bool ModExIncrease::elig(Person* p) const {
    // Eligible for treatment if not treated yet, mdactx_e 4 or above (infrequent/never exercise), and age between 50-60
    return !p->test(Vars::mei_treated) && p->get(Vars::mdactx_e) >= 4 && p->get(Vars::age) >= 50 && p->get(Vars::age) < 61;
}
