#include "RandomBasicProvider.h"

Random* RandomBasicProvider::getRandom(unsigned int rep) {
	if(random != NULL) 
		delete random;
	random = new RandomBasic(rep);
	return random;
}
