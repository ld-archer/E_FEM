#include "OutputTextModule.h"
#include "Logger.h"
#include "utility.h"
#include "Variable.h"
#include <sstream>
#include <fstream>
#include <vector>
#include "fem_exception.h"
OutputTextModule::OutputTextModule(IVariableProvider *vp, std::vector<std::string> var_names) : AbstractOutputModule(vp, var_names)
{

}

OutputTextModule::OutputTextModule(IVariableProvider *vp) : AbstractOutputModule(vp)
{
}

OutputTextModule::~OutputTextModule(void)
{
}



void OutputTextModule::process(PersonVector& persons, unsigned int year, Random* random) {
		
	char delim = '|';
	Logger::log("Running Text Output Module", FINE);
	std::ostringstream ss;
	ss << scenario->OutputDir() << _PATH_DELIM_ << scenario->Name() << _PATH_DELIM_ <<  "detailed_output" << _PATH_DELIM_ <<  "y" << year << "_rep" << random->rep()+1 << ".txt";

	std::ofstream outf(ss.str().c_str());
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(ss.str()));
	

	outf.unsetf(std::ios_base::floatfield);
	outf.precision(14);
	// Write variable names into first row 
	
	std::vector<IVariable*>::iterator vit;

	for(unsigned i = 0; i < vars.size(); i++) 	{
		if(vars[i]->name() != "_cons") {
			outf << vars[i]->name();
			if(i < vars.size() - 1)
					outf << delim;
		}
	}
	outf << std::endl;

	std::vector<Person*>::iterator itr;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
	  if((*itr)->test(Vars::l2died) || !(*itr)->test(Vars::active)) continue;
		for(unsigned int i = 0; i < vars.size(); i++) {
			if(vars[i]->name() != "_cons") {
				if(vars[i]->is_missing(*itr))
					outf << ".";
				else
					outf << vars[i]->value(*itr); 
				if(i < vars.size() - 1)
					outf << delim;
			}
		}
		outf << std::endl;
	}
	outf.close();
	
	ss.str("");
	ss <<  " output file: " << scenario->OutputDir() << _PATH_DELIM_ <<scenario->Name() << _PATH_DELIM_ <<  "detailed_output" << _PATH_DELIM_ <<  "y" << year << "_rep" << random->rep() +1 << ".dta";
	Logger::log(ss.str(), FINE);
}

