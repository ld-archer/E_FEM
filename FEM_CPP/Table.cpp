#include "Table.h"
#include "ConcreteTable.h"
#include <fstream>
#include <vector>
#include <sstream>
#include "fem_exception.h"
#include "utility.h"
#include <cstring>
#include "VarMap.h"
#include "fem_exception.h"

TableIndex::TableIndex() {
	modified = false;
}

TableIndex::TableIndex(IVariableProvider* vp) {
	modified = false;
	setVariableProvider(vp);
}

void TableIndex::set(std::string name, double value) {
	name2val[name] = value;
	modified = true;
}
	
void TableIndex::set(const Person &person) {
	if(!name2val.empty()) {
		for(std::map<std::string, double>::iterator it = name2val.begin(); it != name2val.end(); it++) {
			if(variableProvider != NULL)
				it->second = variableProvider->get(it->first)->value(&person);
			else
				it->second = person.get(VarsInfo::indexOf(it->first));	
		}
		modified = true;
	}	else {
		throw fem_exception("Attempted to set TableIndex value from Person, but TableIndex has no variables");
	}
}

double TableIndex::get(std::string name) const {
	if(modified & !name2val.empty())
		return(name2val.at(name));
	else
		throw fem_exception("Attempted to get TableIndex element, but values have not been assigned.");
}

std::vector<std::string> TableIndex::getNames(void) {
	std::vector<std::string> res;
	for(std::map<std::string, double>::iterator it = name2val.begin(); it != name2val.end(); it++) {
		res.push_back(it->first);
	}
	return(res);
}

ITable* ITable::Read(std::string table_name, const char* filename, IVariableProvider* vp) {

	std::string desc = "";
	VarMap<double> data(vp, filename);
	
	desc = table_name + " indexed by";
	for(unsigned int i=0; i < data.getIndexVarNames().size(); i++) {
		desc += " " + data.getIndexVarNames()[i];
	}
	
	ITable* tab = new ConcreteTable(table_name, data);
	tab->setDescription(desc);
	return tab;
}
