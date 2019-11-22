#include "Random.h"
#include "utility.h"

std::vector<double> Random::mvnormDist( unsigned int id, const std::vector<unsigned int>& process, unsigned int year, const std::vector<double>& m, const std::vector< std::vector<double> >& C) const {
	unsigned int size = m.size();
	
	// check sizes
	if(process.size() != size || C.size() != size)
		throw fem_exception("Dimension mismatch in multivariate normal random generator");
	
	std::vector<double> draw(size);
	std::vector<double> z(size);	
		
	for(unsigned int i=0; i < size; i++) {
		z[i] = normalDist(id, process[i], year, 0, 1);
	}
		
	for(unsigned int i=0; i < size; i++) {
		draw[i] = m[i];
		// check that row i of C has length i+1
		if(C[i].size() != i+1)
			throw fem_exception("Error in multivariate normal random generator: covariance parameters are not lower triangular");

		for(unsigned int j=0; j <= i; j++) {
			draw[i] += C[i][j]*z[j];
		}
	}
		
	return(draw);
}
