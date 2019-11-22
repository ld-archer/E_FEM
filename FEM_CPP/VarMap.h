#pragma once
#include <cstring>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
#include "Person.h"
#include "fem_exception.h"
#include "Variable.h"
#include "Vars.h"

/**
The VarMapKey class defines the key objects used for indexing in VarMap objects.
*/
class VarMapKey : public std::vector<double>
{
	public:
		/** 
		Initializes a VarMapKey to have the given length 
		@param[in] length The length used for initialization
		*/
		VarMapKey(size_t length);
		
		//bool operator<(const VarMapKey &x);
};

/** 
The VarMap class template defines a mapping from a subset of the variables 
provided by a VariableProvider to objects of type val_type specified as a template 
argument. If no VariableProvider is given, then the variables must be in Vars::Vars_t.

Initial input can be read in the VarMap::VarMap(const IVariableProvider* variable_provider, const char* mapdef_file) 
constructor. The input format is documented in the 
VarMap::read(const char* mapdef_file) member function.
*/
template <class val_type> class VarMap
{
	public:
		VarMap();
		
		/** 
		Constructor to set up variable provider, but not read any input
		@param[in] variable_provider IVariableProvider that defines which variables are available for mapping
		*/
		VarMap(IVariableProvider* variable_provider);
		
		/** 
		Constructor to read input from mapdef_file 
		@param[in] mapdef_file Name of the input file
		*/
		VarMap(const char* mapdef_file);

		/** 
		Constructor to read input from mapdef_file 
		@param[in] variable_provider IVariableProvider that defines which variables are available for mapping
		@param[in] mapdef_file Name of the input file
		*/
		VarMap(IVariableProvider* variable_provider, const char* mapdef_file);

		/** 
		Constructor to create an empty mapping with indexing variables defined by names 
		@param[in] names Variable names that will be used for indexing
		*/
		VarMap(const std::vector<std::string> names);

		/** 
		Constructor to  create an empty mapping with indexing variables defined by names 
		@param[in] variable_provider IVariableProvider that defines which variables are available for mapping
		@param[in] names Variable names that will be used for indexing
		*/
		VarMap(IVariableProvider* variable_provider, const std::vector<std::string> names);

		
		virtual ~VarMap(void);

		/**
		Reads input from file mapdef_file.  The first line of the file will be ignored. The
		second line should have a list of variable names.  Each subsequent 
		line should have values for each of the variables named on the first line followed 
		by the val_type value to which the preceding variable values map.  On each line, 
		variable names (first line) and values (subsequent lines) can be delimited by tabs 
		or spaces.  
		Example:
		\verbatim
		|these comments will be ignored
		age	male
		60	0	100
		70	0	150
		80	0	250
		60	1	90
		70	1	80
		80	1	100
		\endverbatim

		@param[in] mapdef_file Name of the input file
		*/
		virtual void read(const char* mapdef_file);
		
		/**
		Reads input from already open istream. The first line pointed to by the istream should 
		have a list of variable names.  Each subsequent 
		line should have values for each of the variables named on the first line followed 
		by the val_type value to which the preceding variable values map.  On each line, 
		variable names (first line) and values (subsequent lines) can be delimited by tabs 
		or spaces.  
		Example:
		\verbatim
		age	male
		60	0	100
		70	0	150
		80	0	250
		60	1	90
		70	1	80
		80	1	100
		\endverbatim

		@param[in] infile The already-open istream
		*/
		virtual void read(std::istream& istrm);

		/** 
		Extracts index variable values from person and returns mapped value.
		Throws exception if mapping is not defined for the index values.
		
		@param[in] person Person object from which index variable values are extracted
		*/
		virtual val_type get(const Person &person) const;

		/** 
		Returns mapped value for index values stored in index.
		Throws exception if mapping is not defined for the index values.
		
		@param[in] index VarMapKey for which the mapping should be retrieved
		*/
		virtual val_type get(const VarMapKey &index) const;
		
		/** 
		Extracts index variable values from person and stores mapping from
		index values to value. Throws an exception if there are no indexing 
		variables for the mapping.
		
		@param[in] person Person object from which index variable values are extracted
		@param[in] value Value to which the index variable values will be mapped
		*/
		virtual void set(const Person &person, const val_type &value);

		/** 
		Stores mapping from index values to value.
		
		@param[in] index VarMapKey for which the mapping should be retrieved
		@param[in] value Value to which the index variable values will be mapped
		*/
		virtual void set(const VarMapKey &index, const val_type &value);

		/** Returns the names of the index variables */
		virtual std::vector<std::string> getIndexVarNames(void) const;

		/** 
		Checks to see if mapping has been defined for index.  
		@param[in] index VarMapKey to check for existence in the map
		*/
		virtual bool isIndexKey(const VarMapKey &index) const;
		
		/**
		Extracts index variable values from person and checks to see if 
		mapping is defined for those index values.
		
		@param[in] person Person object from which index variable values are extracted
		*/
		virtual bool isIndexKey(const Person &person) const;
		
		/** 
		Returns the set of index values for which the mapping is defined.
		*/		
		virtual std::vector<VarMapKey> getIndexKeys(void) const;
	
		virtual void operator=(const VarMap &source);

		/**
		Extracts index from person and returns corresponding key-value entry in human-readable format.
		*/
		virtual std::string printMap(const Person &person) const;
			
		/**
		Returns key-value entry for index in human-readable format.
		*/
		virtual std::string printMap(const VarMapKey &index) const;

		/**
		Returns the mapping as a human-readable table.
		*/
		virtual std::string printMap(void) const;
			
		/**
		Returns true if mapping is empty
		*/
		inline virtual bool isEmpty() { return table.empty(); };
		
		/**
		Clears mapping and index variable names to an empty state
		*/
		virtual void clear();
		
		virtual void setVariableProvider(IVariableProvider* vp) { variable_provider=vp; };

	  virtual IVariableProvider* getVariableProvider(void) const { return(variable_provider); };
	  
	private:
		/** Names of the variables used to index the mapping. */
		std::vector<std::string> varNames;
			
		/** Number of variables used to index the mapping. */		
		size_t indexLength;
		
		/** Stores the mapping */
		std::map<const VarMapKey, val_type> table;

		IVariableProvider* variable_provider;
};


