#pragma once
#include "Module.h"
#include <map>
class LagModule :
	public Module
{
public:
	LagModule(void);
	virtual ~LagModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Lag Module";}
	virtual void setModelProvider(IModelProvider* mp) {}
};
