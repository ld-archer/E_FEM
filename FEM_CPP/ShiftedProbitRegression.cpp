#include "ShiftedProbitRegression.h"
#include <sstream>
#include <iomanip>
#include "fem_exception.h"
#include "Random.h"
#include <limits>
#include <cstring>

ShiftedProbitRegression::ShiftedProbitRegression(void)
{
	name = "shifted_probit";
}

ShiftedProbitRegression::ShiftedProbitRegression(const ShiftedProbitRegression& source) : ProbitRegression(source)
{
	this->xb_shifts = source.xb_shifts;
}

double ShiftedProbitRegression::getShift(unsigned int year) const {
  if(xb_shifts.count(year) > 0)
    return xb_shifts.at(year);
  else {
    std::ostringstream ss;
    ss << "ShiftedProbitRegression " << getName() << " does not have shift data for " << year;
    throw fem_exception(ss.str());
  }
}


void ShiftedProbitRegression::read(std::istream& istrm, IVariableProvider* provider)
{
	double temp_coeffs[1000];
	IVariable* temp_vars[1000];
	std::string buf;
	char bufline[5000];
	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);

	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading shifted probit model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
		throw fem_exception(ss.str().c_str());
	}

	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
	
	bool reading_shifts = false;
	try {
		/* Read in coeffecients */
		while(!istrm.eof())
		{
			istrm.getline(bufline, 5000);
			if(strlen(bufline) > 0 && !(bufline[0]=='o' && bufline[1]=='.'))  {
				std::istringstream iss(bufline);
				char firstchar;
				iss.read(&firstchar, 1);
				iss.putback(firstchar);
				if(firstchar == '|') {
					reading_shifts = true;
					// eat a line;
				}
				if(!reading_shifts) {
					iss >>buf >> temp_coeffs[nvars];
					temp_vars[nvars] = provider->get(buf);
					nvars++;

				} else if(firstchar != '|') {
					unsigned int year;
					double shift;
					iss >> year >> shift;
					xb_shifts[year] = shift;
				}
				if(iss.fail()) {
					// Something bad happened trying to read the data. 
					// Most likely, it tried to read the coeff but it wasnt a number
					// Throw an exception
					std::ostringstream ss;
					ss << "There was problem reading the line \"" << bufline << "\". Please check the model defination file";
					throw fem_exception(ss.str().c_str());
				}
			}
		}
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
