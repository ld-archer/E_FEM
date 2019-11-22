#include "OrderedProbitRegression.h"
#include "utility.h"
#include "Random.h"
#include <sstream>
#include <limits>
#include <iomanip>
#include "fem_exception.h"
#include <cstring>

OrderedProbitRegression::OrderedProbitRegression(void)
{
	ncuts = 0;
	cut_points = NULL;
	cut_probs = NULL;
	cut_cum_probs = NULL;
	dummy_vars = NULL;
	name = "oprobit";
}

OrderedProbitRegression::OrderedProbitRegression(const OrderedProbitRegression& source) : Regression(source)
{
	ncuts = source.ncuts;
	if(ncuts != 0) {
		cut_points = new double[ncuts];
		cut_probs = new double[ncuts + 1];
		cut_cum_probs = new double[ncuts + 1];
		dummy_vars = new Vars::Vars_t[ncuts + 1];

		for(int i = 0; i < ncuts+1; i++) {
			if(i < ncuts) {
				cut_points[i] = source.cut_points[i];
			}
			cut_probs[i] = source.cut_probs[i];
			cut_cum_probs[i] = source.cut_cum_probs[i];
			dummy_vars[i] = source.dummy_vars[i];
		}
	} else {
		cut_points = NULL;
		cut_probs = NULL;
		cut_cum_probs = NULL;
		dummy_vars = NULL;
	}
}

OrderedProbitRegression::~OrderedProbitRegression(void)
{
	if (cut_points != NULL)		delete [] cut_points;
	if (cut_probs != NULL)		delete [] cut_probs;
	if (cut_cum_probs != NULL)	delete [] cut_cum_probs;
	if (dummy_vars != NULL)		delete [] dummy_vars;
}


void OrderedProbitRegression::predict(Person* person, const Random* random) const
{
	double xb = calc_xb(person);
	cut_probs[0] = cum_normal(cut_points[0] - xb);
	cut_cum_probs[0] = cut_probs[0];
	for (int i = 1; i < ncuts; i++) {
		cut_probs[i] = cum_normal(cut_points[i] - xb) - cum_normal(cut_points[i - 1] - xb);
		cut_cum_probs[i] = cut_cum_probs[i - 1] + cut_probs[i];
	}
	cut_probs[ncuts] = 1 - cum_normal(cut_points[ncuts - 1] - xb);
	cut_cum_probs[ncuts] = 1;

	double prob = random->uniformDist(person->getID(), predicted_var, person->getYear());


	int ordinal = 1;
	if (prob < cut_cum_probs[0]) {
		ordinal = 1;
	}

	for (int i = 1; i <= ncuts; i++) {
		if (prob < cut_cum_probs[i] && prob >= cut_cum_probs[i - 1]) {
			ordinal = i + 1;
		}
	}

	person->set(predicted_var, ordinal);
	for (int i = 0; i <= ncuts; i++) {
		if (dummy_vars[i] != Vars::_NONE)
			person->set(dummy_vars[i], ordinal == i + 1 ? 1.0 : 0.0);
		if(dummy_vars[i] != Vars::_NONE && VarsInfo::probOf(dummy_vars[i]) != Vars::_NONE)
			person->set(VarsInfo::probOf(dummy_vars[i]), cut_probs[i]);
	}
}

std::string OrderedProbitRegression::describe() const
{

	std::stringstream strm;
	if(predicted_var == Vars::_NONE) // Model is loaded?
		strm << "Ordered Probit Regression data is not loaded!" << std::endl;
	else
	{
		strm << getTypeDesc() << " for " << VarsInfo::labelOf(predicted_var) << std::endl;
		strm << "Coeffecients:" << std::endl;
		for(int i = 0; i < nvars; i++)
			strm << "\t" << vars[i]->name() << " = " << coeffs[i] << std::endl;
		strm << "Cut Points and Dummy Variables :\n";
		for(int i = 0; i <= ncuts; i++) {
			std::string label = dummy_vars[i] != Vars::_NONE ? VarsInfo::labelOf(dummy_vars[i]) : "";
			if(i == 0)
				strm << "\t(-inf, " << cut_points[0] << "]\t" << label << "\n";
			else if (i < ncuts)
				strm << "\t(" << cut_points[i-1] << ", " << cut_points[i] << "]\t" << label <<  "\n";
			else
				strm << "\t(" << cut_points[i-1] << ", +inf]\t" << label << "\n";
		}
	}
	return strm.str();
} 

void OrderedProbitRegression::read(std::istream& istrm, IVariableProvider* provider)
{
	ncuts = 0;

	if (cut_points != NULL)		delete [] cut_points;
	if (cut_probs != NULL)		delete [] cut_probs;
	if (cut_cum_probs != NULL)	delete [] cut_cum_probs;
	if (dummy_vars != NULL)		delete [] dummy_vars;

	cut_points = NULL;
	cut_probs = NULL;
	cut_cum_probs = NULL;
	dummy_vars = NULL;


	double temp_cut_points[1000];
	
	double temp_coeffs[1000];
	IVariable* temp_vars[1000];
	std::string buf;
	char bufline[5000];
	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);
	
	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading ordered probit model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
		throw fem_exception(ss.str().c_str());
	}

	// Eat any newline characters
	istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	/* Read in coeffecients */
	while(!istrm.eof())
	{
		// Read a line
		istrm.getline(bufline, 5000);

		// Check that the line is valid and not a comment
		if(strlen(bufline) > 0 && bufline[0] != '|' && !(bufline[0]=='o' && bufline[1]=='.'))  {
			// Create a stream to parse the line
			std::istringstream iss(bufline);

			// Read in the first word
			iss >> buf;

			// If its something like *cut* 
			int cut_index = buf.find("cut");
			if(cut_index > -1) {
				iss >>  temp_cut_points[ncuts];
				ncuts++;
			} else {
				// Its just a variable coeff pair
				iss >> temp_coeffs[nvars];
				try {
					temp_vars[nvars] = provider->get(buf);
				} 	 catch (fem_exception e) {
					std::ostringstream ss;
					ss << "Error reading model " << getName() << ": " << e.what();
					throw fem_exception(ss.str().c_str());
				}
				nvars++;
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

	
	coeffs = new double[nvars];
	coeff_perturbs = new double[nvars];
	vars = new IVariable*[nvars];

	for(int i = 0; i < nvars; i++) {
		coeffs[i] = temp_coeffs[i];
		coeff_perturbs[i] = 0.0;
		vars[i] = temp_vars[i];
	}

	if(ncuts != 0) {
		cut_points = new double[ncuts];
		cut_probs = new double[ncuts + 1];
		cut_cum_probs = new double[ncuts + 1];
		dummy_vars = new Vars::Vars_t[ncuts + 1];

		for(int i = 0; i < ncuts+1; i++) {
			if(i < ncuts) {
				cut_points[i] = temp_cut_points[i];
			}

			dummy_vars[i] = Vars::_NONE;
			/* Find the dummy variable for this cut. Pretty ineffecient for now*/
			for(unsigned int j = 0; j < Vars::NVars; j++) {
				if(VarsInfo::infoOf((Vars::Vars_t)j).dummy_for == predicted_var 
					&& VarsInfo::infoOf((Vars::Vars_t)j).category_index == i + 1) {
					dummy_vars[i] = (Vars::Vars_t)j;
				}
			}
		
		}
	} 



}

