#include "ConcreteTable.h"
#include "fem_exception.h"
#include <sstream>
#include "VarMap.h"

ConcreteTable::ConcreteTable(std::string n, VarMap<double> table) : data(table) {
	name = n;
}

ConcreteTable::~ConcreteTable(void)
{
  data.clear();
}

double ConcreteTable::Value(const TableIndex &index) const {
	std::vector<std::string> names = data.getIndexVarNames();
	VarMapKey k(names.size());
	for(unsigned int i=0; i < names.size(); i++) {
		k[i] = index.get(names[i]);
	}
	return(data.get(k));
}

double ConcreteTable::Value(const Person &person) const {
	TableIndex t = getIndexTemplate();
	t.set(person);
	return(Value(t));
}

TableIndex ConcreteTable::getIndexTemplate(void) const {
	TableIndex t(data.getVariableProvider());
	std::vector<std::string> names = data.getIndexVarNames();
	for(unsigned int i=0; i < names.size(); i++) {
		t.addName(names[i]);
	}
	return(t);
}

bool ConcreteTable::isIndex(const TableIndex &index) const {
	std::vector<std::string> names = data.getIndexVarNames();
	VarMapKey key(names.size());
	for(unsigned int i=0; i < names.size(); i++)
		key[i] = index.get(names[i]);
	return(data.isIndexKey(key));
}

bool ConcreteTable::isIndex(const Person &person) const {
	TableIndex t = getIndexTemplate();
	t.set(person);
	return(isIndex(t));
}

