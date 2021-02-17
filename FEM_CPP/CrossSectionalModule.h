#pragma once
#include "Module.h"
#include "Model.h"
#include "SSCalculator.h"
#include <vector>
#include <map>

class CrossSectionalModule :
	public Module
{
public:
	CrossSectionalModule(IVariableProvider* vp, ITimeSeriesProvider* tp);
	virtual ~CrossSectionalModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Cross Sectional Module";}
	virtual void setModelProvider(IModelProvider* modp);
	virtual void setScenario(Scenario* scen);
	
protected:
	
	IModelProvider* mp;
	std::vector<Vars::Vars_t> vars_to_model;
	std::map<Vars::Vars_t, IModel*> models;

	IVariable* qaly_nhm_var;
	
	/** Calculator for SS benefits */
	SSCalculator sscalc;
};
