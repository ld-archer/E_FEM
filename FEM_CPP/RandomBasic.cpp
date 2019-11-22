#include "RandomBasic.h"
#include "utility.h"
#include <limits>
#include <cstdlib>

double RandomBasic::uniformDist( unsigned int id,  unsigned int process, unsigned int year ) const
{
  return (unsigned int)rand()/(double) RAND_MAX;
}


double RandomBasic::normalDist( unsigned int id,  unsigned int process, unsigned int year, double m, double s ) const
{
	return normal_dist(uniformDist(id, process, year), m, s);
}




