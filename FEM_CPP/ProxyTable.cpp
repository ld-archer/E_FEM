#include "ProxyTable.h"
#include "fem_exception.h"


ProxyTable::ProxyTable(void)
{
	table = NULL;
}



double ProxyTable::Value(const TableIndex &index) const {
	checkTable();
	return table->Value(index);
}

double ProxyTable::Value(const Person &person) const {
	checkTable();
	return table->Value(person);
}

TableIndex ProxyTable::getIndexTemplate() const {
	checkTable();
	return(table->getIndexTemplate());
}


bool ProxyTable::isIndex(const TableIndex &index) const {
	checkTable();
	return(table->isIndex(index));
}

bool ProxyTable::isIndex(const Person &person) const {
	checkTable();
	return(table->isIndex(person));
}

void ProxyTable::checkTable() const {
	if(table == NULL) {
		std::ostringstream ss;
		ss << "Proxy table [" << name << "] has no underlying implementation.";
		throw fem_exception(ss.str());
	}
}

