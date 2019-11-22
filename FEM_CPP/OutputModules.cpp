#include "OutputModules.h"
#include "OutputStataModule.h"
#include "OutputTextModule.h"
#include "Logger.h"
#include "utility.h"
#include "Variable.h"
#include "fem_exception.h"
#include <vector>
#include <sstream>
OutputModules::OutputModules(IVariableProvider *vp, std::string output_types_str, std::string output_var_names)
{


	std::vector<std::string> var_names;
	std::vector<std::string> output_types;
	str_tokenize(output_var_names, var_names, " ");
	str_tokenize(output_types_str, output_types, " ");
	
	try {
		if(var_names.size() > 0 && var_names[0] == "_all") {
			for(std::vector<std::string>::iterator itr = output_types.begin(); itr != output_types.end(); itr++) {
				if((*itr) == "stata")
					outputs.push_back(new OutputStataModule(vp));
				else if ((*itr) == "text")
					outputs.push_back(new OutputTextModule(vp));
			}
		}
		else {
			for(std::vector<std::string>::iterator itr = output_types.begin(); itr != output_types.end(); itr++) {
				if((*itr) == "stata")
					outputs.push_back(new OutputStataModule(vp, var_names));
				else if ((*itr) == "text")
					outputs.push_back(new OutputTextModule(vp, var_names));
			}
		}
	} catch (const fem_exception & e) {
		Logger::log("Problem preparing output module:", WARNING);
		Logger::log(e.what(), WARNING);
	}
}


OutputModules::~OutputModules(void)
{
	for(std::vector<AbstractOutputModule*>::iterator itr = outputs.begin(); itr != outputs.end(); itr++)
		delete (*itr);
}



void OutputModules::process(PersonVector& persons, unsigned int year, Random* random) {
		
	for(std::vector<AbstractOutputModule*>::iterator itr = outputs.begin(); itr != outputs.end(); itr++)
		(*itr)->process(persons, year, random);
}


std::string OutputModules::description() const {
		
	std::ostringstream ss;
	for(std::vector<AbstractOutputModule*>::const_iterator itr = outputs.begin(); itr != outputs.end(); itr++) {
		ss << (*itr)->description();
		if(itr != outputs.end()-1)
			ss << ", ";
	}
	return ss.str();
}

void OutputModules::setScenario(Scenario* scen) {
	for(std::vector<AbstractOutputModule*>::iterator itr = outputs.begin(); itr != outputs.end(); itr++)
		(*itr)->setScenario(scen);
}

