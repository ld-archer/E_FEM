#include <cfloat>
#pragma once


#ifdef __FEM_WIN__
#define _PATH_DELIM_ "\\"
#endif 

#ifdef __FEM_UNIX__
#define _PATH_DELIM_ "/"
#endif 


#include <math.h>
#include <string>
#include <vector>
#include "Variable.h"

inline double cum_normal(const double x)
{
  const double b1 =  0.319381530;
  const double b2 = -0.356563782;
  const double b3 =  1.781477937;
  const double b4 = -1.821255978;
  const double b5 =  1.330274429;
  const double p  =  0.2316419;
  const double c  =  0.39894228;

  if(x >= 0.0) {
      double t = 1.0 / ( 1.0 + p * x );
      return (1.0 - c * exp( -x * x / 2.0 ) * t *
      ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
  }
  else {
      double t = 1.0 / ( 1.0 - p * x );
      return ( c * exp( -x * x / 2.0 ) * t *
      ( t *( t * ( t * ( t * b5 + b4 ) + b3 ) + b2 ) + b1 ));
    }
}

void str_tokenize(const std::string& str,  std::vector<std::string>& tokens,  const std::string& delimiters = " ");
void str_tokenize_keep_delim(const std::string& str,  std::vector<std::string>& tokens,  const std::string& delimiters = " ");
void str_tokenize_keep_delim(const std::string& str, std::vector<std::string>& tokens, std::vector<std::string>& delims);
void trim(std::string& str);
int getdir (std::string dir, std::vector<std::string> &files, std::string ext = "*");
void make_dir(const std::string& dir);
void copy_file(const std::string& dest, const std::string& src);
bool dir_exists(const std::string& dir);




/* Function that calculates the inverse
hyperbolic sin transform of a continuous variable */
inline double arcsinh(double x) {
	return log(x+sqrt(x*x+1.0));
}

/* Function that calculates the inverse of the 
generalized inverse
hyperbolic sin transform of a continuous variable
see 
MacKinnon and Magee (1990): "Transforming the Dependent
Variable in a Regression Model", IER 31:2, pp. 315-339
http://www.jstor.org/stable/2526842
*/
inline double invgh(double g, double theta=1, double omega=0) {
	// preliminary calculations

	double hb = arcsinh(theta*omega);
	double dhb = pow(1.0+pow(theta*omega, 2.0),(-0.5));
	double x =  theta*dhb*g+hb;
	double sinh = 0.5*(exp(x)-exp(-x));
	
	// computations
	return (sinh-theta*omega)/theta;
}

inline void mkspline(double x, int nknots, double* knots, double* out) {
	double cx = 0;
	for(int i = 0; i < nknots; i++) {
		if(x >= knots[i]) {
			out[i] = knots[i] - cx;
			cx = knots[i];
		} else {
			out[i] = x - cx;
			cx = x;
		}
	}
	out[nknots] = x - cx;
}

typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long long  uint64;

// Specialization for 2-byte types.
inline void bswap2(char* dest, char const* src)
{
    // Use bit manipulations instead of accessing individual bytes from memory, much faster.
    uint16* p_dest = reinterpret_cast< uint16* >(dest);
    uint16 const* const p_src = reinterpret_cast< uint16 const* >(src);
    *p_dest = (*p_src >> 8) | (*p_src << 8);
}

// Specialization for 4-byte types.
inline void bswap4(char* dest, char const* src)
{
    // Use bit manipulations instead of accessing individual bytes from memory, much faster.
    uint32* p_dest = reinterpret_cast< uint32* >(dest);
    uint32 const* const p_src = reinterpret_cast< uint32 const* >(src);
    *p_dest = (*p_src >> 24) | ((*p_src & 0x00ff0000) >> 8) | ((*p_src & 0x0000ff00) << 8) | (*p_src << 24);
}



// Specialization for 8-byte types.
inline void bswap8(char* dest, char const* src)
{
    // Use bit manipulations instead of accessing individual bytes from memory, much faster.
    uint64* p_dest = reinterpret_cast< uint64* >(dest);
    uint64 const* const p_src = reinterpret_cast< uint64 const* >(src);
    *p_dest =   (*p_src>>56) | 
				((*p_src<<40) & 0x00FF000000000000) |
				((*p_src<<24) & 0x0000FF0000000000) |
				((*p_src<<8)  & 0x000000FF00000000) |
				((*p_src>>8)  & 0x00000000FF000000) |
				((*p_src>>24) & 0x0000000000FF0000) |
				((*p_src>>40) & 0x000000000000FF00) |
				(*p_src<<56);

}


double normal_dist( double u, double m, double s );


inline short readStataShort(const char *buf, bool ds_lohi, bool my_lohi) {
	char buf2[2];
	if(ds_lohi != my_lohi)
		bswap2(buf2, buf);
	return *((short*)buf);
}



inline int readStataInt(char* buf, bool ds_lohi, bool my_lohi) {
	char buf2[4];
	if(ds_lohi != my_lohi)
		bswap4(buf2, buf);
	return *((int*)buf);
}


inline float readStataFloat(char* buf, bool ds_lohi, bool my_lohi) {
	char buf2[4];
	if(ds_lohi != my_lohi)
		bswap4(buf2, buf);
	return *((float*)buf);
}

inline double readStataDouble(char* buf, bool ds_lohi, bool my_lohi) {
	char buf2[8];
	if(ds_lohi != my_lohi)
		bswap8(buf2, buf);
	return *((double*)buf);
}

int readbetas(std::istream &istrm, std::vector<double>& temp_coeffs, std::vector<double>& temp_perturbs, std::vector<IVariable*>& temp_vars, std::map<std::string, double>& specials, IVariableProvider* vp);

std::string& StringToUpper(std::string& str);
std::string& StringToLower(std::string& str);


#define STATA_BYTE_MISSING		(0x65)
#define STATA_INT_MISSING		(0x7fe5)
#define STATA_LONG_MISSING		(0x7fffffe5)
#define STATA_FLOAT_MISSING		pow(2.0, 127.0)
#define STATA_DOUBLE_MISSING	pow(2.0, 1023.0)
