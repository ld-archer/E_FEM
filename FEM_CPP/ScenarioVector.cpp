#include "ScenarioVector.h"
#include "utility.h"
#include <map>
#include <fstream>
#include <sstream>
#include "fem_exception.h"
#include <iostream>
#include <cstdlib>
#include <cstring>

ScenarioVector::ScenarioVector(void)
{
}

ScenarioVector::~ScenarioVector(void)
{
	for(unsigned int i = 0; i < size(); i++)
		delete (*this)[i];
}



void ScenarioVector::clear(void)
{
	for(unsigned int i = 0; i < size(); i++)
		delete (*this)[i];
	std::vector<Scenario*>::clear();
}


void ScenarioVector::readDelimited(const char* file, char delim)
{
	std::ifstream istrm(file);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));

	std::string delim_str(1, delim);
	const int BUFSIZE = 5000;
	char buf[BUFSIZE];

	// Read the first line, with column headers
	istrm.getline(buf, BUFSIZE);

	// Trim off any potential extra whitespaces or carriage returns that may have been thrown in by Excel
	std::string str(buf);
	trim(str);

	// Tokenize the string based on the delim, and place the resulting strings in the col_names vector
	std::vector<std::string> col_names;
	str_tokenize(str, col_names, delim_str);

	// Change all column names to lower case
	for(unsigned int i = 0; i < col_names.size(); i++)	{
		StringToLower(col_names[i]);
	}


	std::vector<std::string> tokens;        
    while (!istrm.eof()) {
			// Read a scenario line
			istrm.getline(buf, BUFSIZE);
			
			if(strlen(buf) > 0) {
				Scenario* s = new Scenario();
				tokens.clear();

				// Trim off any potential extra whitespaces or carriage returns that may have been thrown in by Excel
				str = std::string(buf);
				trim(str);

				// Tokenize to extract the values
				str_tokenize(str, tokens, delim_str);

				// The number of values should be the same as number of column headers. If not, something is wrong
				if(tokens.size() != col_names.size()) {
					std::ostringstream ss;
					ss << "In Scenarios file [" << file << "], error while parsing " << size() + 1 << " scenario: there are "
					   << col_names.size() << " scenario parameters, but " << tokens.size() << " were specified";
					throw fem_exception(ss.str());
				}

				for(unsigned int i = 0; i < col_names.size(); i++)	{
					std::string name = col_names[i];

					// Some scenarios vaiables we want to treat specially
					if(name == "scenario_name") {
						s->Name(tokens[i]);
					} else if(name == "output_dir") {
						s->OutputDir(tokens[i]);
					} else if(name == "simutype") {
						s->SimuType(atoi(tokens[i].c_str()));
					} else if(name == "base_cohort_name") {
						s->BaseCohortName(tokens[i]);
					} else if(name == "new_cohort_model") {
						s->NewCohortModel(tokens[i]);
					} else if(name == "startyr") {
					  s->StartYr(strtoul(tokens[i].c_str(), NULL, 10));
					} else if(name == "stpyr") {
						s->StopYr(strtoul(tokens[i].c_str(), NULL, 10));
					} else if(name == "endyr") {
						s->EndYr(strtoul(tokens[i].c_str(), NULL, 10));
					} else if(name == "nreps") {
						s->NReps(strtoul(tokens[i].c_str(), NULL, 10));
					} else if(name == "detailed_output") {
						s->DoDetailedOutput(tokens[i] == "1" || StringToLower(tokens[i]) == "true");
					} else if(name == "init_interventions") {
						
					} else if(name == "interventions") {
						
					} else if(name == "use_obese_baseline") {
						
					} else if(name == "obese_baseline") {
						
					} else if(name == "yr_step") {
					  s->YrStep(strtoul(tokens[i].c_str(), NULL, 10));
					}
					
					// Save the name value pair
					s->set(name, tokens[i]);
				}
				// Save the scenario
				push_back(s);
			}
	}
}

