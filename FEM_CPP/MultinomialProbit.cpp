#include "MultinomialProbit.h"
#include <sstream>
#include <limits>
#include <cstring>
#include "Logger.h"
#include "Vars.h"

MultinomialProbit::MultinomialProbit() {
};

MultinomialProbit::MultinomialProbit(const MultinomialProbit& source) : Regression(source) {
  regs.clear();
  for(std::vector<Regression*>::const_iterator i = source.regs.begin();
      i != source.regs.end();
      i++)
    regs.push_back(*i);

  dummy_vars.resize(regs.size());
  dummy_var_indexes.resize(regs.size());
  for(unsigned int i=0; i < regs.size(); i++) {
    dummy_vars[i] = source.dummy_vars[i];
    dummy_var_indexes[i] = (unsigned int)dummy_vars[i];
  }
}

MultinomialProbit::~MultinomialProbit(void) {
  regs.clear();
}

void MultinomialProbit::read(std::istream& istrm, IVariableProvider* provider) {
  double temp_coeffs[1000];
  double temp_perts[1000];
  IVariable* temp_vars[1000];
  std::string buf;
  char bufline[5000];
  std::string firstvar("");
  cholesky_cov.resize(0);

  istrm >> buf;
  predicted_var = VarsInfo::indexOf(buf);
  
  // Check if the variable read in exists
  if (predicted_var == Vars::_NONE) {
    std::ostringstream ss;
    ss << "Error reading model " << getName() << ": Predicted variable [" << buf << "] does not exists!";
    Logger::log(ss.str(), ERROR);
  }
  
  // Eat any newline characters
  istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
  
  try {
    /* Read in coeffecients */
    while(!istrm.eof()) {
			// Read a line
			istrm.getline(bufline, 5000);
			// Check that a full line was read, and that it is not a comment line 
			if(strlen(bufline) > 0 && bufline[0] != '|')  {
				  // It is a regular variable coeffecient line.
				  std::istringstream iss(bufline);
				  iss >>buf >> temp_coeffs[nvars];
				  temp_perts[nvars] = 0.0;
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
		  		// special handling for when first category is the omitted (base/reference) category
		  		if(firstvar == "" && buf.size() > 1 && buf.substr(0,2) == "o.") {
			  		firstvar = buf.substr(2);
			  		nvars = 0;
			  	}
			  	// the input line starts a new block of coefficients
			 	 else if(buf == firstvar.c_str() || buf == std::string("o."+firstvar).c_str()) {
			 	   Regression* r = new Regression(nvars, Vars::_NONE, "child of " + name, temp_coeffs, temp_vars, temp_perts);
			 	   regs.push_back(r);
			 	   temp_coeffs[0] = temp_coeffs[nvars];
			 	   nvars = 0;
			 	 }
			 	 // the input line defines the first variable in each block of coefficients
			 	 else if(firstvar == "") 
			 	 	 firstvar = buf;
			 	 if(temp_coeffs[nvars] != 0) {
			 	   temp_vars[nvars] = provider->get(buf);
			 	   nvars++;
			 	 }
			} else if (strcmp(bufline, "| Cholesky Factor of Covariance") == 0) { 
				// This should be the last block of the file and the next 
				// regs.size()+1 lines should be the lower triangular elements
				// from the Cholesky decomposition of the covariance matrix. 
				// There are regs.size()+1 lines because the last set of regression 
				// parameters has been read from the file but has not been pushed 
				// into regs yet.
				unsigned int cov_dim = regs.size()+1;
				cholesky_cov.resize(cov_dim);
				for(unsigned int i=0; i < cov_dim; i++) {
					//read line
					istrm.getline(bufline, 5000);
			 		std::istringstream iss(bufline);
					//convert i+1 tokens to elements of cholesky factorization
					cholesky_cov[i].resize(i+1);
					for(unsigned int j=0; j <= i; j++) {
			 			iss >> cholesky_cov[i][j];		
	  	 			if(iss.fail()) {
	    				// Something bad happened trying to read the data. 
	    				// Most likely, it tried to read the coeff but it wasnt a number
	    				// Throw an exception
	    				std::ostringstream ss;
	    				ss << "There was problem reading row " << i+1 << " column " << j+1 << "(\"" << bufline << "\") in the covariance parameters. Please check the model definition file";
	    				throw fem_exception(ss.str().c_str());
	  				}
	  			}
					/** \todo verify that there are no additional tokens on this line */
				}
				/** \todo verify that there are no additional lines of input */
			}
    }
    Regression* r = new Regression(nvars, Vars::_NONE, "child of " + name, temp_coeffs, temp_vars, temp_perts);
    regs.push_back(r);

		if(cholesky_cov.size() == 0) {
			 // Input file did not have covariance parameters, so assume identity matrix
			 std::ostringstream ss;
    	 ss << "Model " << getName() << " input file did not have covariance parameters. Assuming identity matrix.";
  	   Logger::log(ss.str(), INFO);
			 unsigned int cov_dim = regs.size();
				cholesky_cov.resize(cov_dim);
				for(unsigned int i=0; i < cov_dim; i++) {
					cholesky_cov[i].resize(i+1);
					for(unsigned int j=0; j < i; j++) {
			 			cholesky_cov[i][j] = 0.0;		
	  			}
	  			cholesky_cov[i][i] = 1.0;
				}
		}

    dummy_vars.resize(regs.size());
    dummy_var_indexes.resize(regs.size());
    
    for(unsigned int i = 0; i < regs.size(); i++) {
      
	  	dummy_vars[i] = Vars::_NONE;
	    /* Find the dummy variable for this cut. Pretty ineffecient for now*/
	    for(unsigned int j = 0; j < Vars::NVars; j++) {
				if(VarsInfo::infoOf((Vars::Vars_t)j).dummy_for == predicted_var 
		   		&& (unsigned int) VarsInfo::infoOf((Vars::Vars_t)j).category_index == i + 1) {
		  		dummy_vars[i] = (Vars::Vars_t)j;
	  			dummy_var_indexes[i] = (unsigned int)dummy_vars[i];
				}
	    }
	    if(dummy_vars[i] == Vars::_NONE) {
	    	std::ostringstream ss;
	    	ss << "could not find the required dummy variable for multinomial probit " << getName() << " category " << i+1;
	    	throw fem_exception(ss.str().c_str());    
	    }  
    }
  } catch (fem_exception e) {
    std::ostringstream ss;
    ss << "Error reading model " << getName() << ": " << e.what();
    throw fem_exception(ss.str().c_str());
  }
}

std::string MultinomialProbit::describe() const {
  std::stringstream strm;
  strm << "Multinomial Probit for " << VarsInfo::labelOf(predicted_var) << std::endl;
  
  for(unsigned int i=0; i < regs.size(); i++) {
    strm << "Coefficients for case " << i+1 << std::endl;
    strm << regs[i]->describe() << std::endl;
  }
  strm << "Cholesky decomposition of covariance matrix " << std::endl;
  for(unsigned int i=0; i < regs.size(); i++) {
  	for(unsigned int j=0; j <= i; j++) 
    	strm << cholesky_cov[i][j] << " ";
    strm << std::endl;
  }
  return strm.str();
}

void MultinomialProbit::predict(Person* person, const Random* random) const {  
  std::vector<double> xbs(regs.size());
  int which = -1;
  double maxdraw = -std::numeric_limits<double>::max();
	
  for(unsigned int i=0; i < regs.size(); i++)
    xbs[i] = regs[i]->estimate(person);

  std::vector<double> draw = random->mvnormDist(person->getID(), dummy_var_indexes, person->getYear(), xbs, cholesky_cov);
 
  // largest draw determines outcome category
  for(unsigned int i=0; i < regs.size(); i++) {
    if(draw[i] > maxdraw) {
      which = i+1;
      maxdraw = draw[i];
    }
  }

  if(which <= 0)
    throw fem_exception("Multinomial Probit had no positive responses");

  person->set(predicted_var, which);

  unsigned int category = (unsigned int)person->get(predicted_var);
  for (unsigned int i = 0; i < regs.size(); i++) {
    if (dummy_vars[i] != Vars::_NONE)
      person->set(dummy_vars[i], category == i + 1 ? 1.0 : 0.0);
  }
}
