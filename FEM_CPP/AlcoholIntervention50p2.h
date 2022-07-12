#pragma once
#include "Intervention.h"
#include <set>
class AlcoholIntervention50p2 :
        public Intervention
{
public:
    AlcoholIntervention50p2(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
    virtual ~AlcoholIntervention50p2(void);
    virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
    virtual inline std::string name() const { return std::string("AlcoholIntervention50p2");};
    virtual void setScenario(Scenario* scen);
protected:
    bool elig(Person* p) const;
    unsigned int start_yr;
};
