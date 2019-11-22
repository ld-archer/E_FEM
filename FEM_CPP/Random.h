#pragma once

#include "Person.h"
#include <map>
#include <string>
#include <vector>

class Random {


public:
	Random(unsigned int r) : _rep(r) {}
	virtual ~Random() {}
	
	enum Random_t {
		Var,
		Intervention,
		Model,
		NRANDOMS
	};

	virtual double uniformDist( unsigned int id,  unsigned int process, unsigned int year ) const = 0;
	virtual double normalDist( unsigned int id,  unsigned int process, unsigned int year, double m, double s ) const = 0;

	/** Generates a random vector draw from the multivariate normal distribution
		\param[in] id passed as <I>id</I> argument to <B>normalDist</B> when generating component draws
		\param[in] process each vector element is passed as <I>process</I> argument to <B>normalDist</B> when generating the corresponding component draw.  Must be same length as <I>m</I>.
		\param[in] year passed as <I>year</I> argument to <B>normalDist</B> when generating component draws
		\param[in] m mean vector for multivariate normal distribution, the length of the random vector draw will be the same length as <I>m</I>
		\param[in] C Cholesky decomposition of covariance matrix (Covariance = <I>C</I> x <I>C</I><sup>T</sup>), lower triangular, stored as vector of vectors containing nonzero elements <I>C</I>[0][0], <I>C</I>[1][0], <I>C</I>[1][1], <I>C</I>[2][0], <I>C</I>[2][1], <I>C</I>[2][2], etc.
		\return vector of same length as <I>m</I> that contains the multivariate random draw	
	*/
	virtual std::vector<double> mvnormDist( const unsigned int id, const std::vector<unsigned int>& process, unsigned int year, const std::vector<double>& m, const std::vector< std::vector<double> >& C) const;

	virtual unsigned int randomIndex(unsigned int id, Random_t rand) const = 0; 
	virtual unsigned int rep() const {return _rep;}

protected:
	unsigned int _rep;
};
