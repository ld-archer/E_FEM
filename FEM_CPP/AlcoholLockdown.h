#pragma once
#include "Intervention.h"
#include <set>
class AlcoholLockdown :
        public Intervention
{
public:
    AlcoholLockdown(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
    virtual ~AlcoholLockdown(void);
    virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
    virtual inline std::string name() const { return std::string("AlcoholLockdown");};
    virtual void setScenario(Scenario* scen);
protected:
    bool elig(Person* p) const;
    unsigned int start_yr;
};
