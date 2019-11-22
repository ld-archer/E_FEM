#pragma once

#include "RandomBlowfish.h"
#include "RandomProvider.h"
#include <vector>

class RandomBlowfishProvider : public RandomProvider
{
public:
	RandomBlowfishProvider() {}
	virtual ~RandomBlowfishProvider(void);

	void readKeyFile(const char* file);

	virtual Random* getRandom(unsigned int rep);
	virtual std::string schemeName() const {return "blowfish";}
	virtual unsigned int maxReps() const {return random_blowfishes.size();}

protected:
	std::vector<unsigned int> keys;
	std::vector<RandomBlowfish*> random_blowfishes;
};
