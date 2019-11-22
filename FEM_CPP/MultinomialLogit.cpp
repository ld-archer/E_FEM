#include "MultinomialLogit.h"
#include <sstream>
#include <limits>
#include <cstring>
#include "Logger.h"
#include "Vars.h"

MultinomialLogit::MultinomialLogit() {
  dummy_vars = NULL;
};

MultinomialLogit::MultinomialLogit(const MultinomialLogit& source) : Regression(source) {
  regs.clear();
  for(std::vector<Regression*>::const_iterator i = source.regs.begin();
      i != source.regs.end();
      i++)
    regs.push_back(*i);

  dummy_vars = new Vars::Vars_t[regs.size()];
  for(unsigned int i=0; i < regs.size(); i++)
    dummy_vars[i] = source.dummy_vars[i];
}

MultinomialLogit::~MultinomialLogit(void) {
  regs.clear();
}

void MultinomialLogit::read(std::istream& istrm, IVariableProvider* provider) {
  double temp_coeffs[1000];
  double temp_perts[1000];
  IVariable* temp_vars[1000];
  std::string buf;
  char bufline[5000];
  std::string firstvar("");

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
    while(!istrm.eof())
      {
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
	      ss << "There was problem reading the line \"" << bufline << "\". Please check the model defination file";
	      throw fem_exception(ss.str().c_str());
	    }
	    else continue;
	  }
	  // special handling for when first category is omitted (base/reference) category
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
	} else if (strcmp(bufline, "| Root Mean Square Error") == 0) { 
	  // The next line should be the rmse. It is of the form
	  // _rmse	#####
	  istrm.getline(bufline, 5000);
	  std::istringstream iss(bufline);
	  iss >>buf >> esigma;		
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
    Regression* r = new Regression(nvars, Vars::_NONE, "child of " + name, temp_coeffs, temp_vars, temp_perts);
    regs.push_back(r);

    dummy_vars = new Vars::Vars_t[regs.size()];
    
    for(unsigned int i = 0; i < regs.size(); i++) {
      
      dummy_vars[i] = Vars::_NONE;
      /* Find the dummy variable for this cut. Pretty ineffecient for now*/
      for(unsigned int j = 0; j < Vars::NVars; j++) {
	if(VarsInfo::infoOf((Vars::Vars_t)j).dummy_for == predicted_var 
	   && (unsigned int) VarsInfo::infoOf((Vars::Vars_t)j).category_index == i + 1) {
	  dummy_vars[i] = (Vars::Vars_t)j;
	}
      }
      
    }

  } catch (const fem_exception & e) {
    std::ostringstream ss;
    ss << "Error reading model " << getName() << ": " << e.what();
    throw fem_exception(ss.str().c_str());
  }
  
}

std::string MultinomialLogit::describe() const {
  std::stringstream strm;
  strm << "Multinomial Logit for " << VarsInfo::labelOf(predicted_var) << std::endl;
  
  for(unsigned int i=0; i < regs.size(); i++) {
    strm << "Coefficients for case " << i+1 << std::endl;
    strm << regs[i]->describe() << std::endl;
  }
  return strm.str();
}

void MultinomialLogit::predict(Person* person, const Random* random) const {
  double draw = random->uniformDist(person->getID(), predicted_var, person->getYear());

  double xbs[regs.size()], totxb=0.0, response=0.0;
  int which = -1;
  for(unsigned int i=0; i < regs.size(); i++) {
    xbs[i] = exp(regs[i]->estimate(person));
    totxb += xbs[i];
  }

  
  for(unsigned int i=0; i < regs.size(); i++) {
    xbs[i] = xbs[i]/totxb;
    response += xbs[i];
    if(response > draw) {
      which = (int) i+1;
      break;
    }
  }

  if(which <= 0)
    throw fem_exception("Multinomial Logit had no positive responses");

  person->set(predicted_var, which);

  unsigned int category = (unsigned int)person->get(predicted_var);
  for (unsigned int i = 0; i < regs.size(); i++) {
    if (dummy_vars[i] != Vars::_NONE)
      person->set(dummy_vars[i], category == i + 1 ? 1.0 : 0.0);
  }
}
