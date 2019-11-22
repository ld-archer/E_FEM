#pragma once

#include "RandomBasic.h"
#include "RandomProvider.h"
#include <vector>

class RandomBasicProvider : public RandomProvider
{
public:
	RandomBasicProvider() {random = NULL;}
	virtual ~RandomBasicProvider(void) {}

	virtual Random* getRandom(unsigned int rep);
	virtual std::string schemeName() const {return "basic";}
	virtual unsigned int maxReps() const {return 99999;}

protected:
	RandomBasic* random;
};
