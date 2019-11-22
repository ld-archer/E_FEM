#include "VariableManager.h"
#include "utility.h"
#include "Logger.h"
#include "EquationParser.h"
#include "EquationNode.h"
#include "DerivedVariable.h"
#include "BuiltInVariable.h"
#include "fem_exception.h"
#include "file_not_found_exception.h"
#include <fstream>
#include <cstring>

VariableManager::VariableManager(void)
{
	builder = NULL;
	for(unsigned int i = 0; i < Vars::NVars; i++)
		addVariable(new BuiltInVariable((Vars::Vars_t)i));
}

VariableManager::~VariableManager(void)
{
	for(std::map<std::string, IVariable*>::iterator itr = var_map.begin(); itr != var_map.end(); ++itr)
		delete (*itr).second;


	for(std::map<std::string, ProxyVariable*>::iterator itr = proxy_var_map.begin(); itr != proxy_var_map.end(); ++itr)
		delete (*itr).second;
}


IVariable* VariableManager::get(std::string name) {
  if(exists(name))
    return proxy_var_map[name];
  throw fem_exception(std::string(name + " is not a valid variable").c_str());
}

bool inline VariableManager::exists(std::string name) const {
  return proxy_var_map.count(name) != 0;
}

IVariable* VariableManager::addVariable(IVariable* var){

	// If a variable with this name already exists, then delete the existing version
	if(var_map.count(var->name()))
		delete var_map[var->name()];
	var_map[var->name()] = var;
	
	// If there is not yet a proxy variable with this name, then create it
	// and add a variale node for this variable to the node builder
	if(proxy_var_map.count(var->name()) == 0) {
		ProxyVariable* p = new ProxyVariable(var->name(), var->description());
		proxy_var_map[var->name()] = p;
		if(builder != NULL)
			builder->addTerminalNode(new VariableNode(p));
	}

	// Have the proxy for this variable point to the actual variable
	proxy_var_map[var->name()]->setVar(var);
	return proxy_var_map[var->name()];
}

void VariableManager::setBuilder(NodeBuilder* b) {
	builder = b;
	if(builder != NULL) {
		std::map<std::string, ProxyVariable*>::iterator itr;
		for(itr = proxy_var_map.begin(); itr != proxy_var_map.end(); ++itr)
			if(!builder->containsTerminalNode((*itr).first))
				builder->addTerminalNode(new VariableNode((*itr).second));
	}
}


IVariable* VariableManager::addVariable(std::string var_def) {
	
  size_t equal_pos = var_def.find_first_of("=");
  size_t desc_pos = var_def.find_first_of(":");
  size_t type_pos = std::string::npos;
  if(desc_pos < var_def.length())
    type_pos = var_def.substr(desc_pos+1).find_first_of(":");
  type_pos = type_pos==std::string::npos ? std::string::npos : type_pos + desc_pos + 1;

  std::string var_name = var_def.substr(0, equal_pos);
  std::string equation = var_def.substr(equal_pos+1, desc_pos - equal_pos - 1);
  std::string desc = var_def.substr(desc_pos+1, min(type_pos, var_def.length()) - desc_pos - 1);
  if(desc_pos==std::string::npos) desc="";
  std::string type = var_def.substr(type_pos+1, max(var_def.length() - type_pos - 1, 0));
  if(type_pos==std::string::npos || type_pos==desc_pos) type="";

  trim(equation);
  trim(var_name);
  trim(desc);
  trim(type);
  StringToLower(type);
  
  VarTypes::VarTypes_t varType = VarTypes::Double;
  if(type=="boolean")
    varType=VarTypes::Boolean;
  else if(type=="short")
    varType=VarTypes::Short;
  else if(type=="long")
    varType=VarTypes::Long;
  else if(type=="float")
    varType=VarTypes::Float;

	if(builder == NULL)
		throw fem_exception("No NodeBuilder loaded!");
	try {
	  return addVariable(new DerivedVariable(var_name, EquationParser::parseString(equation, builder), desc, varType));
	} catch (const fem_exception & e) {
		std::ostringstream ss;
		ss << "Error in variable equation for variable " << var_name << ": " << e.what();
		Logger::log(ss.str(), ERROR);
		throw(e);
	}
}

void VariableManager::readVariableDefinitions(std::istream& istrm) {
	char buf[5000];
	while(!istrm.eof()) {

		// Read a line
		istrm.getline(buf, 5000);

		// Check that a full line, and not a comment line, were read in
		if(strlen(buf) > 0 && buf[0] != '|') {
			// Trim off any potential extra whitespaces or carriage returns
			std::string str(buf);
			trim(str);

			// Read the variable
			addVariable(str);
		}
	}
}

void VariableManager::readVariableDefinitions(std::istream& istrm, std::vector<IVariable*>& vars_added) {
	char buf[5000];
	while(!istrm.eof()) {
		// Read a line
		istrm.getline(buf, 5000);

		// Check that a full line, and not a comment line, were read in
		if(strlen(buf) > 0 && buf[0] != '|') {
			// Trim off any potential extra whitespaces or carriage returns
			std::string str(buf);
			trim(str);

			// Read the variable
			vars_added.push_back(addVariable(str));
		}
	}
}



void VariableManager::readVariableDefinitions(const char* file) {
	
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
		throw file_not_found_exception(file);
	readVariableDefinitions(inf);
	inf.close();
}

void VariableManager::readVariableDefinitions(const char* file, std::vector<IVariable*>& vars_added) {
	
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
		throw file_not_found_exception(file);
	readVariableDefinitions(inf, vars_added);
	inf.close();
}

void VariableManager::getAll(std::vector<IVariable*> &vec) {
	std::map<std::string, ProxyVariable*>::iterator itr;
	for(itr = proxy_var_map.begin(); itr != proxy_var_map.end(); ++itr)
		vec.push_back((*itr).second);
}
