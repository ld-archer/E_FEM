#include "GHREG.h"
#include "utility.h"
#include "Random.h"
#include <sstream>
#include <limits>
#include "fem_exception.h"
#include <cstring>

GHREG::GHREG(void)
{
}

GHREG::~GHREG(void)
{
}




GHREG::GHREG(const GHREG& source) : Regression(source)
{
	theta = source.theta;
	omega = source.omega;
	ssr = source.ssr;
	sqrt_ssr = source.sqrt_ssr;
	hb = source.hb;
	dhb = source.dhb;

}


void GHREG::predict(Person* person, const Random* random) const
{
	double x = transform(calc_xb(person) + random->normalDist(person->getID(), predicted_var, person->getYear(), 0, 1)*sqrt_ssr);
	predictWithProb(person, random, x);
}



std::string GHREG::describe() const
{
	std::string desc = Regression::describe();
	std::stringstream strm;
	strm << desc;
	if(predicted_var != Vars::_NONE) { // Model is loaded?
		strm << "\ttheta = " << theta << std::endl;
		strm << "\tomega = " << omega << std::endl;
		strm << "\tssr = " << ssr << std::endl;
	}
	return strm.str();
} 


double GHREG::transform(double g) const {
	double x =  theta*dhb*g+hb;
	double sinh = 0.5*(exp(x)-exp(-x));
	
	// computations
	return (sinh-theta*omega)/theta;
}


void GHREG::read(std::istream& istrm, IVariableProvider* provider)
{
	std::string buf;
	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);

	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading GHREG model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
		throw fem_exception(ss.str().c_str());
	}

	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	std::vector<double> temp_coeffs(50), temp_perturbs(50);
	std::map<std::string, double> params;
	std::vector<IVariable*> temp_vars(50);
	try {
	  nvars = readbetas(istrm, temp_coeffs, temp_perturbs, temp_vars, params, provider);
	} catch (const fem_exception & e) {
		std::ostringstream ss;
		ss << "Error reading model " << getName() << ": " << e.what();
		throw fem_exception(ss.str().c_str());
	}
	
	coeffs = new double[nvars];
	coeff_perturbs = new double[nvars];
	vars = new IVariable*[nvars];

	theta = params["theta"];
	omega = params["omega"];
	ssr = params["ssr"];

	for(int i = 0; i < nvars; i++)
	{
		coeffs[i] = temp_coeffs[i];
		coeff_perturbs[i] = 0.0;
		vars[i] = temp_vars[i];
	}
	
	// Prep these variables
	sqrt_ssr = sqrt(ssr);
	hb = arcsinh(theta*omega);
	dhb = pow(1.0+pow(theta*omega, 2.0),(-0.5));
}
