// Created by ld-archer on 16/12/2019.
#pragma once
#include "Intervention.h"
#include <set>
class ModExIncrease :
        public Intervention
{
public:
    ModExIncrease(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
    virtual ~ModExIncrease(void);
    virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
    virtual inline std::string name() const { return std::string("ModExIncrease");};
    virtual void setScenario(Scenario* scen);
protected:
    bool elig(Person* p) const;

    unsigned int start_yr;
};
