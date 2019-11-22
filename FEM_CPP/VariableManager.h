#pragma once
#include "EquationNode.h"
#include "Vars.h"
#include <map>
#include <iostream>
#include <vector>
#include "Variable.h"
#include "ProxyVariable.h"

class VariableManager : public IVariableProvider
{
public:
	VariableManager(void);
	virtual ~VariableManager(void);

	virtual IVariable* get(std::string name);
	virtual inline bool exists(std::string name) const;

	virtual IVariable* addVariable( IVariable* var);
	IVariable* addVariable(std::string var_def);
	void setBuilder(NodeBuilder* builder);
	inline NodeBuilder* getBuilder() {return builder;}
	void readVariableDefinitions(std::istream& istrm);
	void readVariableDefinitions(const char* file);
	void readVariableDefinitions(std::istream& istrm, std::vector<IVariable*>& vars_added);
	void readVariableDefinitions(const char* file, std::vector<IVariable*>& vars_added);

	virtual void getAll(std::vector<IVariable*> &vec);

protected:
	std::map<std::string, IVariable*> var_map;
	std::map<std::string, ProxyVariable*> proxy_var_map;
	NodeBuilder* builder;
};
