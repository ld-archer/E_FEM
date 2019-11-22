#pragma once

#include <map>
#include <string>
#include "Random.h"

class RandomProvider {


public:
	virtual ~RandomProvider() {}
	virtual Random* getRandom(unsigned int rep) = 0;
	virtual std::string schemeName() const = 0;
	virtual unsigned int maxReps() const = 0;

};
