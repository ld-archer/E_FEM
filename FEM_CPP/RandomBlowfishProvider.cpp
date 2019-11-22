#include "RandomBlowfishProvider.h"
#include <sstream>
#include <fstream>
#include "fem_exception.h"



RandomBlowfishProvider::~RandomBlowfishProvider(void) {
	for(unsigned int i = 0; i < random_blowfishes.size(); i++)
		delete random_blowfishes[i];
}

void RandomBlowfishProvider::readKeyFile(const char* file) {
	
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	unsigned int r = 0;
	while(!inf.eof()) {
		unsigned int key;
		inf >> key;
		random_blowfishes.push_back(new RandomBlowfish(key, r));
		keys.push_back(key);
		r++;
	}
}

Random* RandomBlowfishProvider::getRandom(unsigned int rep) {
	if(rep >= this->maxReps()) {
		std::ostringstream ss;
		ss << "Requested Random numbers for rep " << rep+1 << ", but only " << maxReps() << " available!";
		throw fem_exception(ss.str());
	}
	return random_blowfishes[rep];
}

