#include "Settings.h"
#include "utility.h"
#include <fstream>
#include <vector>
#include "fem_exception.h"
#include <cstring>
#include <stdexcept>

Settings::Settings(void)
{
}

Settings::~Settings(void)
{
}

std::string Settings::get(std::string name) {
	try {
		return params.at(name);
	}
	catch (const std::out_of_range& oor) {
		throw fem_exception("Settings parameter does not exist: " + name);
	}
}

void Settings::dumpSettings(std::ostream& strm) {
	strm << "Settings: ";
	std::map<std::string, std::string>::iterator mit;
	for(mit = params.begin(); mit != params.end(); mit++)
		strm << " " << mit->first << " = " << mit->second << std::endl;
}

void Settings::readSettings(const char* file) {

	std::vector<std::string> tokens;
	std::ifstream istrm(file);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	std::string line;
	char buf[5000];
	while(!istrm.eof()) {
		istrm.getline(buf, 5000);
		if(strlen(buf) > 0 && buf[0] != '|')  {
			tokens.clear();
			// Trim off any potential extra whitespaces or carriage returns
			std::string str(buf);
			trim(str);

			// Split the line into var = value pairs
			str_tokenize(str, tokens, std::string("="));
			if(tokens.size() == 2) {
				// If it looks like a correct line, then read it in and save it
				std::string name = tokens[0];
				std::string val = tokens[1];
				
				// Clear off any extra whitespaces
				trim(name);
				trim(val);

				// Save the pair
				params[name] = val;
			}
		}

			
	}
}




