#pragma once
#include "Table.h"
#include <sstream>

class ProxyTable :
	public ITable
{
public:
	ProxyTable(void);
	ProxyTable(std::string n, std::string d = "") 
		: table(NULL), name(n), desc(d) {}
	virtual ~ProxyTable(void) {}
	virtual double Value(const TableIndex &index) const;
	virtual double Value(const Person &person) const;
	virtual std::string getName() const { return name;}
	virtual void setName(std::string n) {name = n;}
	virtual std::string getDescription() const {return desc;}
	virtual void setDescription(std::string d) {desc = d;}
	void setTable(ITable* t) {table = t;}
  virtual TableIndex getIndexTemplate() const;
	virtual bool isIndex(const TableIndex &index) const;
	virtual bool isIndex(const Person &person) const;

protected:

	void checkTable() const;
	ITable* table;
	std::string name;
	std::string desc;
};
