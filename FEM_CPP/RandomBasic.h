#pragma once

#include "Random.h"

class RandomBasic : public Random
{
public:
	RandomBasic(unsigned int r) : Random(r)  {}
	virtual ~RandomBasic() {} 
	
	virtual double normalDist( unsigned int id,  unsigned int process, unsigned int year, double m, double s ) const;
	virtual double uniformDist( unsigned int id,  unsigned int random_process, unsigned int year ) const;
	virtual unsigned int randomIndex(unsigned int id, Random_t rand) const {return 0;}
	
	
};
