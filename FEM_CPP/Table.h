#pragma once
#include <string>
#include <vector>
#include <map>
#include "Variable.h"
#include "VarMap.h"

/**
The TableIndex class defines objects used for indexing entries in derivatives of the ITable class
*/
class TableIndex
{
	public:
		TableIndex();
		
		TableIndex(IVariableProvider* vp);

		/**
		Adds element name to TableIndex but does not set a value for the element
		@param[in] name The name of the index element
		*/
		void addName(std::string name) {name2val[name] = 0;}

		/**
		Sets values of the TableIndex to match values of person
		@param[in] person The person object from which to get index values
		*/
		void set(const Person &person);
		
		/**
		Set value for a single element of TableIndex identified by name
		@param[in] name The name of the index element to set
		@param[in] value The value to assign to the index element
		*/
		void set(std::string name, double value);

		/**
		Get value for a single element of TableIndex identified by name
		@param[in] name The name of the index element to get
		*/
		double get(std::string name) const;
			
		/**
		Returns true if TableIndex element values have been modified since creation
		*/
		bool isSet() const {return modified;};
		
		void setVariableProvider(IVariableProvider* vp) { variableProvider=vp; };
		
		/**
		Returns a vector of strings containing the variable name for each index element
		*/
		std::vector<std::string> getNames(void);
		
	private:
		bool modified;
		std::map<std::string, double> name2val;
		IVariableProvider* variableProvider;
};

class ITable
{
public:
	virtual ~ITable(void) {}
	virtual double Value(const TableIndex &index) const = 0;
	virtual double Value(const Person &person) const = 0;
  virtual std::string getName() const = 0;
  virtual void setName(std::string name)= 0;
  virtual std::string getDescription() const = 0;
  virtual void setDescription(std::string desc)= 0;
  virtual bool isIndex(const TableIndex &index) const = 0;
 	virtual bool isIndex(const Person &person) const = 0;

  	
  /** 
  Returns a TableIndex object with key names from the table, but no values filled in. 
  Once the values are filled in, the TableIndex object can be used to index elements in the table.
  */
  virtual TableIndex getIndexTemplate() const = 0;

	static ITable* Read(std::string table_name, const char* filename, IVariableProvider* vp);
};



class ITableProvider
{
public:
	virtual ~ITableProvider(void) {}
	virtual ITable* get(std::string name) = 0;
	virtual void getAll(std::vector<ITable*> &vec) = 0;
	virtual bool hasTable(std::string name) = 0;
};


