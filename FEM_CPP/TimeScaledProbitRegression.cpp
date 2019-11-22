#include "TimeScaledProbitRegression.h"
#include <sstream>
#include <iomanip>
#include "fem_exception.h"
#include "Random.h"
#include <limits>
#include <cstring>
#include <cstdlib>

TimeScaledProbitRegression::TimeScaledProbitRegression(void)
{
	name = "time_scaled_probit";
}

TimeScaledProbitRegression::TimeScaledProbitRegression(const TimeScaledProbitRegression& source) : ProbitRegression(source)
{
	modeled_delta_year = source.modeled_delta_year;
}



void TimeScaledProbitRegression::predict(Person* person, const Random* random) const
{
  double prob = 1.0 - pow(1.0 - transform(calc_xb(person)), yr_step->value(person)/(double)modeled_delta_year);
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);
	if(pvar != Vars::_NONE)
		person->set(pvar, prob);
	predictWithProb(person, random, prob);
}

void TimeScaledProbitRegression::read(std::istream& istrm, IVariableProvider* provider)
{
  std::vector<double> temp_coeffs(50), temp_perturbs(50);
  std::vector<IVariable*> temp_vars(50);
  std::map<std::string, double> sigmap;
  std::string buf;
	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);
	yr_step = provider->get("yr_step");

	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading time scaled probit model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
		throw fem_exception(ss.str().c_str());
	}
	
	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	// Read the number of years that were actually modeled
	istrm >> buf;
	this->modeled_delta_year = atoi(buf.c_str());

	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	try {
	  nvars = readbetas(istrm, temp_coeffs, temp_perturbs, temp_vars, sigmap, provider);
	} catch (fem_exception e) {
		std::ostringstream ss;
		ss << "Error reading model " << getName() << ": " << e.what();
		throw fem_exception(ss.str().c_str());
	}
	
	coeffs = new double[nvars];
	coeff_perturbs = new double[nvars];
	vars = new IVariable*[nvars];


	for(int i = 0; i < nvars; i++)
	{
		coeffs[i] = temp_coeffs[i];
		coeff_perturbs[i] = 0.0;
		vars[i] = temp_vars[i];
	}
}

