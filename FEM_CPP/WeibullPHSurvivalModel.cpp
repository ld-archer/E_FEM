#include "WeibullPHSurvivalModel.h"
#include <sstream>
#include <limits>
#include "fem_exception.h"
#include <cmath>
#include <cstring>

WeibullPHSurvivalModel::WeibullPHSurvivalModel(void) : SurvivalModel()
{
	name = "WeibullPHSurvival";
	p = 0;
}

WeibullPHSurvivalModel::WeibullPHSurvivalModel(const WeibullPHSurvivalModel& source) : SurvivalModel(source)
{
	name = "WeibullPHSurvival";
	p = source.p;
}

WeibullPHSurvivalModel::~WeibullPHSurvivalModel(void)
{

}

double WeibullPHSurvivalModel::psurv(const Person* person, double t) const
{
	if(t < 0.0) {
		std::ostringstream ss;
		ss << "Cannot compute survival function for negative times in " << getName() << " model";
		throw fem_exception(ss.str().c_str());
	}
	
	double xb = calc_xb(person);
	double lambda = std::exp(xb);
	return(std::exp(-lambda*std::pow(t,p)));
}


std::string WeibullPHSurvivalModel::desc_survfunc() const
{
	std::stringstream strm;
	strm << "\tS(t) = exp{-exp{x beta} t^p}" << std::endl;
	strm << "\tp = " << p << std::endl;
	return strm.str();
}

void WeibullPHSurvivalModel::read_survparams(std::istream& istrm)
{
	double ln_p;
	std::string buf;
	char bufline[5000];
	
	istrm.getline(bufline, 5000);
	if(strlen(bufline) > strlen("ln_p") && strncmp(bufline, "ln_p", strlen("ln_p")) == 0) {
		std::istringstream iss(bufline);
		iss >> buf >> ln_p;
		p = std::exp(ln_p);
	} else
		throw fem_exception("could not find ln_p parameter value where expected");
	
	return;
}
