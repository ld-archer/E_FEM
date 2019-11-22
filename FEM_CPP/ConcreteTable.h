#pragma once
#include "Table.h"
#include <string>

class ConcreteTable :
	public ITable
{
public:
  ConcreteTable(std::string n, VarMap<double> table);
	virtual ~ConcreteTable(void);
	virtual double Value(const TableIndex &index) const;
	virtual double Value(const Person &person) const;
	virtual std::string getName(void) const {return name;}
	virtual void setName(std::string n) {name = n;}
	virtual std::string getDescription(void) const {return desc;}
	virtual void setDescription(std::string d) {desc = d;}
  virtual TableIndex getIndexTemplate(void) const;
  virtual void setVariableProvider(IVariableProvider* vp) { variableProvider = vp; };
	virtual bool isIndex(const TableIndex &index) const;
	virtual bool isIndex(const Person &person) const;

protected:
	VarMap<double> data;
  std::string name;
  std::string desc;
  IVariableProvider* variableProvider;
};
