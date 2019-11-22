#include "SurvivalModel.h"
#include <sstream>
#include <limits>
#include "fem_exception.h"
#include <cstring>
#include "utility.h"

SurvivalModel::SurvivalModel(void)
{
	vars = NULL;
	coeffs = NULL;
	coeff_perturbs = NULL;
	predicted_var = Vars::_NONE;
	nvars = 0;
	name = "survival";
	time_step = NULL;
}

void SurvivalModel::load_coefficients(const double cfs[], IVariable* vs[], const double cps[]) {
  coeffs = new double[nvars];
  vars = new IVariable*[nvars];
  coeff_perturbs = new double[nvars];

  for(int i = 0; i < nvars; i++) {
    coeffs[i] = cfs[i];
    coeff_perturbs[i] = cps[i];
    vars[i] = vs[i];
  }
}

SurvivalModel::SurvivalModel(const SurvivalModel& source)
{
	nvars = source.nvars;
	predicted_var = source.predicted_var;
	time_var = source.time_var;
	name = source.name;
	if(nvars > 0 && predicted_var != Vars::_NONE) {
		coeffs = new double[nvars];
		vars = new IVariable*[nvars];
		for(int i = 0; i < nvars; i++) {
			coeffs[i] = source.coeffs[i];
			coeff_perturbs[i] = source.coeff_perturbs[i];
			vars[i] = source.vars[i];
		}
	} else {
		vars = NULL;
		coeffs = NULL;
		coeff_perturbs = NULL;
	}	
	time_step = source.time_step;
}

SurvivalModel::~SurvivalModel(void)
{
	if (vars != NULL)
		delete [] vars;

	if(coeffs != NULL)
		delete [] coeffs;

	if(coeff_perturbs != NULL)
		delete [] coeff_perturbs;
}


double SurvivalModel::calc_prob(const Person* person) const
{
  if(time_step->value(person) <= 0.0) {
    std::ostringstream ss;
    ss << "time step is non-positive in survival model for " << getName();
    throw fem_exception(ss.str().c_str());
  }
	
  double t_now = person->get(time_var) - time_var_origin + time_step->value(person);
  double t_prev = person->get(time_var) - time_var_origin;
  
  double psurvnow = t_now < 0.0 ? 1.0 : psurv(person, t_now);
  double psurvprev = t_prev < 0.0 ? 1.0 : psurv(person, t_prev);
  
  return(1 - psurvnow/psurvprev);
}

void SurvivalModel::predict(Person* person, const Random* random) const
{
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);
	double prob = calc_prob(person);
	
	if(pvar != Vars::_NONE)
		prob = storeProb(person);

	predictWithProb(person, random, prob);	
}

double SurvivalModel::storeProb(Person* person) const {
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);

	if(pvar != Vars::_NONE) {
		double prob = calc_prob(person);
		person->set(pvar, prob);
		return prob;
	} else
		throw fem_exception("Cannot store probability of " + VarsInfo::labelOf(predicted_var));
}

void SurvivalModel::predictWithProb(Person* person, const Random* random, double prob) const
{
	if(prob < 0.0 || prob > 1.0)
		throw fem_exception("Probability for simulating " + VarsInfo::labelOf(predicted_var) + " is not in [0,1]");
	
	bool roll = random->uniformDist(person->getID(), predicted_var, person->getYear()) + prob > 1;
	person->set(predicted_var, roll ? 1.0 : 0.0);
}

double SurvivalModel::estimate(const Person* person) const
{
	double prob = calc_prob(person);
	
	if(prob < 0.0 || prob > 1.0)
		throw fem_exception("Probability for estimating " + VarsInfo::labelOf(predicted_var) + " is not in [0,1]");
	
	return(prob >= 0.5);
}

std::string SurvivalModel::describe() const
{
	std::stringstream strm;
	if(predicted_var == Vars::_NONE) // Model is loaded?
	  strm << "SurvivalModel has no predicted variable" << std::endl;
	else
	{
	  strm << getTypeDesc() << " for " << VarsInfo::labelOf(predicted_var) << std::endl;
	}
	strm << "Coeffecients:" << std::endl;
	for(int i = 0; i < nvars; i++)
	  strm << "\t" << vars[i]->name() << " = " << coeffs[i] << std::endl;
	strm << "Survival function:" << std::endl;
	strm << desc_survfunc();
	strm << "Survival settings:" << std::endl;
	strm << "\tTime variable " << VarsInfo::labelOf(time_var) << std::endl;
	strm << "\tTime variable origin " << time_var_origin << std::endl;
	strm << "\tTime step length " << time_step->value() << std::endl;

	return strm.str();
} 

void SurvivalModel::read(std::istream& istrm, IVariableProvider* provider)
{
	double temp_coeffs[1000];
	IVariable* temp_vars[1000];
	std::string buf;
	char bufline[5000];
	bool done_reg = false; // flag is true once the regression parameter values ("betas") have all been read

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
	/* Read in coeffecients and survival parameters */
		while(!istrm.eof() && done_reg == false)
		{
			// Read a line
			istrm.getline(bufline, 5000);
			// Check that a full line was read, and that it is not a comment line 
			if(strlen(bufline) > 0 && bufline[0] != '|' && !(bufline[0]=='o' && bufline[1]=='.'))  {
				// It is a regular variable coeffecient line.
				std::istringstream iss(bufline);
				iss >>buf >> temp_coeffs[nvars];
				if(iss.fail()) {
				  std::string tstring = std::string(bufline);
				  if(tstring.find("(dropped)")==std::string::npos) {
					// Something bad happened trying to read the data. 
					// Most likely, it tried to read the coeff but it wasnt a number
					// Throw an exception
					std::ostringstream ss;
					ss << "There was problem reading the line \"" << bufline << "\". Please check the model definition file";
					throw fem_exception(ss.str().c_str());
				  }
				  else continue;
				}
				temp_vars[nvars] = provider->get(buf);
				nvars++;
				if(buf == "_cons") done_reg = true;
			}
		}
		// at this point the regression parameters (if any) should have been read completely
		// the next step is to read any survival function parameters
		read_survparams(istrm);
		
		// after the survival function parameters, read survival settings
		// first, check that we are at the beginning of the survival settings block
		istrm.getline(bufline, 5000);
		if(strcmp(bufline, "| survival settings") != 0)
			throw fem_exception("could not find survival settings block where expected");
		istrm.getline(bufline, 5000);
		if(strlen(bufline) > strlen("time_variable") && strncmp(bufline, "time_variable", strlen("time_variable")) == 0) {
		  std::vector<std::string> intemp;
			str_tokenize(std::string(bufline), intemp, " ");
			time_var = VarsInfo::indexOf(intemp[1]);
		}
		else
			throw fem_exception("could not find time variable name where expected");
		istrm.getline(bufline, 5000);
		if(strlen(bufline) > strlen("origin") && strncmp(bufline, "origin", strlen("origin")) == 0) {
			std::istringstream iss(bufline);
			iss >> buf >> time_var_origin;
		}
		else
			throw fem_exception("could not find time origin value where expected");			
		
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


double SurvivalModel::calc_xb(const Person* person) const
{
	double total_xb = 0;
	for(int i = 0; i < nvars; i++)
		total_xb +=vars[i]->value(person)*(coeffs[i]+coeff_perturbs[i]);
	return total_xb;
}
