#include "Regression.h"
#include <sstream>
#include <limits>
#include "fem_exception.h"
#include "utility.h"
#include <vector>

Regression::Regression(void)
{
	vars = NULL;
	coeffs = NULL;
	coeff_perturbs = NULL;
	predicted_var = Vars::_NONE;
	nvars = 0;
	esigma = 0;
	name = "regress";
}

void Regression::load_coefficients(const double cfs[], IVariable* vs[], const double cps[]) {
  coeffs = new double[nvars];
  vars = new IVariable*[nvars];
  coeff_perturbs = new double[nvars];

  for(int i = 0; i < nvars; i++) {
    coeffs[i] = cfs[i];
    coeff_perturbs[i] = cps[i];
    vars[i] = vs[i];
  }
}

Regression::Regression(int nv, Vars::Vars_t pvar, std::string n, const double cfs[], IVariable* vs[], const double cps[], const double esd) : predicted_var(pvar), nvars(nv), esigma(esd), name(n) {
  load_coefficients(cfs, vs, cps);
}

Regression::Regression(const Regression& source)
{
	nvars = source.nvars;
	predicted_var = source.predicted_var;
	name = source.name;
	if(nvars > 0 && predicted_var != Vars::_NONE) {
		coeffs = new double[nvars];
		vars = new IVariable*[nvars];
		for(int i = 0; i < nvars; i++) {
			coeffs[i] = source.coeffs[i];
			coeff_perturbs[i] = source.coeff_perturbs[i];
			vars[i] = source.vars[i];
			esigma = source.esigma;
		}
	} else {
		vars = NULL;
		coeffs = NULL;
		coeff_perturbs = NULL;
		esigma = 0;
	}
	
}

Regression::~Regression(void)
{
	if (vars != NULL)
		delete [] vars;

	if(coeffs != NULL)
		delete [] coeffs;

	if(coeff_perturbs != NULL)
		delete [] coeff_perturbs;
}

void Regression::predict(Person* person, const Random* random) const
{
	// Calc the xb
  double total_xb = estimate(person);
	double draw = 0;
	if(esigma > 0) {
		// Draw from the std normal
		 draw = random->normalDist(person->getID(), predicted_var, person->getYear(), 0 , 1);
	}
	// The predicted value is then xb + sqrt(var)*draw
	predictWithProb(person, random, total_xb + esigma*draw);
}

void Regression::predictWithProb(Person* person, const Random* random, double prob) const {
  person->set(predicted_var, prob);
}

double Regression::estimate(const Person* person) const
{
	return transform(calc_xb(person));
}

std::string Regression::describe() const
{
	std::stringstream strm;
	if(predicted_var == Vars::_NONE) // Model is loaded?
	  strm << "Regression has no predicted variable" << std::endl;
	else
	{
	  strm << getTypeDesc() << " for " << VarsInfo::labelOf(predicted_var) << std::endl;
	}
	strm << "Coeffecients:" << std::endl;
	for(int i = 0; i < nvars; i++)
	  strm << "\t" << vars[i]->name() << " = " << coeffs[i] << std::endl;
	if(esigma > 0)
	  strm << "Variance on Error Term:" << esigma*esigma << std::endl;

	return strm.str();
} 

void Regression::read(std::istream& istrm, IVariableProvider* provider)
{
  std::vector<double> temp_coeffs(50);
  std::vector<double> temp_perturbs(50); // Ignored, but required for standardization
  std::vector<IVariable*> temp_vars(50);
  std::map<std::string, double> sigmap;
  
	std::string buf;

	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);

	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
		throw fem_exception(ss.str().c_str());
	}

	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	try {
	  /* Read in coeffecients */
	  nvars = readbetas(istrm, temp_coeffs, temp_perturbs, temp_vars, sigmap, provider);
	} catch (fem_exception e) {
		std::ostringstream ss;
		ss << "Error reading model " << getName() << ": " << e.what();
		throw fem_exception(ss.str().c_str());
	}

	// found some undefined variables or other junk when reading estimates
	if(sigmap.size() > 1) {
		std::ostringstream ss;
		std::string notvars;
		std::string baddef;
		ss << "Error reading model " << getName() << ":";
		for(std::map<std::string,double>::iterator it=sigmap.begin(); it!=sigmap.end(); ++it) {
    	if(!provider->exists(it->first))
				notvars += " " + it->first;
			else
				baddef += " " + it->first;
		}
		if(notvars.size() > 0)
			ss << " [invalid variables>" << notvars;
		if(baddef.size() > 0)
			ss << " [bad coef. definition>" << baddef;
			
		throw fem_exception(ss.str().c_str());
	}

	coeffs = new double[nvars];
	coeff_perturbs = new double[nvars];
	vars = new IVariable*[nvars];
	if(sigmap.count("esigma") > 0) esigma = sigmap["esigma"];

	for(int i = 0; i < nvars; i++)
	{
		coeffs[i] = temp_coeffs[i];
		coeff_perturbs[i] = 0.0;
		vars[i] = temp_vars[i];
	}
}


double Regression::calc_xb(const Person* person) const
{
	double total_xb = 0;
	for(int i = 0; i < nvars; i++)
		total_xb +=vars[i]->value(person)*(coeffs[i]+coeff_perturbs[i]);
	return total_xb;
}
