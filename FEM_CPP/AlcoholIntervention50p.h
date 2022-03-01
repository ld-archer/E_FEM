#pragma once
#include "Intervention.h"
#include <set>
class AlcoholIntervention50p :
        public Intervention
{
public:
    AlcoholIntervention50p(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
    virtual ~AlcoholIntervention50p(void);
    virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
    virtual inline std::string name() const { return std::string("AlcoholIntervention50p");};
    virtual void setScenario(Scenario* scen);
protected:
    bool elig(Person* p) const;
    unsigned int start_yr;
};
