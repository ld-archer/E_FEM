#include <cstring>
#include "VarMap.h"

/*
// elementwise comparison
bool VarMapKey::operator<(const VarMapKey &x) {
	for(unsigned int i=0; i < size(); i++) {
		if(this->at(i) < x[i])
			return true;
		else if(this->at(i) > x[i])
			return false;
	}
	// if not returned yet, they are equal
	return false;
}
*/

VarMapKey::VarMapKey(size_t length) : std::vector<double>() { 
	resize(length); 
}

template <class val_type> void VarMap<val_type>::read(const char* mapdef_file) {
	std::ifstream inf(mapdef_file);
	if( inf.bad() || inf.fail())
		throw fem_exception("Could not open file: " + std::string(mapdef_file));
	char buf[5000];

	clear();
	
	// First line has comments -- read and ignore;
	inf.getline(buf, 5000);

	read(inf);

	inf.close();
}


template <class val_type> void VarMap<val_type>::read(std::istream& inf) {
	char buf[5000];
	const char* delims = " \t"; // delimiters of variable names

	int line = 1;
	// Read definition variables from next line
	size_t nvars = 0;
	inf.getline(buf, 5000);
	
	if(!inf.eof()) {
		// parse out variable names
		char* namep = std::strtok(buf, delims);
		while(namep != NULL) {
			std::string vname = std::string(namep);
			// it would be good to check if vname is a valid variable name, but the variable provider might not 
			// be set until after this read. so, we'll allow invalid variable names here and throw an exception 
			// later when a table lookup is attempted.
			varNames.push_back(vname);
			nvars++;
			namep = std::strtok(NULL, delims);
		}
	} else {
		throw fem_exception("Could not read first line of table");
	}
	
	indexLength = nvars;
	/** \todo Should it be an exception if indexLength==0? */
	/* not sure because it's possible that someone might have a 
	   special table that gives the same value for all persons
	*/
	
	// read the table data
	while(!inf.eof()) {
		line++;
		// Read a line
		inf.getline(buf, 5000);	
		
		// Check that the line is valid and not a comment
		if(strlen(buf) > 0 && buf[0] != '|')  {
			// Create a stream to parse the line
			std::istringstream iss(buf);
			VarMapKey tableIndex(nvars);
			val_type value;
			
			iss >> value;
			for(size_t i=0; i < nvars; i++) {
				if(iss.fail()) {
					// Something bad happened trying to read the data. 
					// Most likely, it read something that was not a number or there was not nvals values on the line
					// Throw an exception
					std::ostringstream ss;
					ss << "Error reading table line " << line << ": \"" << buf << "\". Please check the input.";
					throw fem_exception(ss.str().c_str());
				}
				// create index mapping (if needed)
				tableIndex[i] = value;
				
				iss >> value;
			}
			
			table[tableIndex] = value;
			
		}
	}
}

template <class val_type> VarMap<val_type>::VarMap() {
	variable_provider = NULL;
	indexLength = 0;
}

template <class val_type> VarMap<val_type>::VarMap(IVariableProvider* vp) {
	variable_provider = vp;
	indexLength = 0;
}

template <class val_type> VarMap<val_type>::VarMap(const char* mapdef_file) {
	variable_provider = NULL;
	this->read(mapdef_file);
}

template <class val_type> VarMap<val_type>::VarMap(IVariableProvider* vp, const char* mapdef_file) {
	variable_provider = vp;
	this->read(mapdef_file);
}

template <class val_type> VarMap<val_type>::VarMap(const std::vector<std::string> names) {
	variable_provider = NULL;
	varNames = names;
	indexLength = names.size();
}

template <class val_type> VarMap<val_type>::VarMap(IVariableProvider* vp, const std::vector<std::string> names) {
	variable_provider = vp;
	varNames = names;
	indexLength = names.size();
}

template <class val_type> VarMap<val_type>::~VarMap(void) {
	
}


template <class val_type> std::vector<std::string> VarMap<val_type>::getIndexVarNames(void) const {
	std::vector<std::string> res;
	res.resize(varNames.size());
	for(size_t i=0; i < varNames.size(); i++)
		res[i] = varNames[i];
	
	return res;
}


template <class val_type> void VarMap<val_type>::operator=(const VarMap &source) {
	indexLength = source.indexLength;
	varNames.resize(indexLength);
	for(size_t i=0; i < indexLength; i++)
		varNames[i] = source.varNames[i];

	table.clear();
	std::vector<VarMapKey> ik = source.getIndexKeys();
	for(size_t i=0; i < ik.size(); i++) 
		set(ik[i], source.get(ik[i]));
	
}


template <class val_type> void VarMap<val_type>::set(const Person &person, const val_type &value) {
	if(indexLength > 0) {
		VarMapKey index(indexLength);
		
		for(size_t i=0; i < indexLength; i++) {
			if(variable_provider != NULL)
				index[i] = variable_provider->get(varNames[i])->value(&person);
			else
				index[i] = person.get(VarsInfo::indexOf(varNames[i]));
		}
		
		set(index, value);
	} else
		throw fem_exception("Cannot set VarMap value because no indexing variables were defined.");
}


template <class val_type> void VarMap<val_type>::set(const VarMapKey &index, const val_type &value) {
		table[index] = value;
}


template <class val_type> std::vector<VarMapKey> VarMap<val_type>::getIndexKeys(void) const {
	std::vector<VarMapKey> res;
	typename std::map<const VarMapKey, val_type>::const_iterator tabit;
	for ( tabit=table.begin() ; tabit != table.end(); tabit++ ) {
		res.push_back((*tabit).first);
	}
	
	return res;
}

template <class val_type> val_type VarMap<val_type>::get(const Person &person) const {
	VarMapKey index(indexLength);
	
	for(size_t i=0; i < indexLength; i++) {
		if(variable_provider != NULL)
			index[i] = variable_provider->get(varNames[i])->value(&person);
		else
			index[i] = person.get(VarsInfo::indexOf(varNames[i]));
	}
	
	return get(index);
}


template <class val_type> val_type VarMap<val_type>::get(const VarMapKey &index) const {
	return table.at(index);
}


template <class val_type> bool VarMap<val_type>::isIndexKey(const VarMapKey &index) const {
	return (!table.empty() && table.find(index) != table.end());
}


// does a person's variable values correspond to an index in the table?
template <class val_type> bool VarMap<val_type>::isIndexKey(const Person &person) const {
	VarMapKey index(this->indexLength);
	
	for(size_t i=0; i < indexLength; i++) {
		if(variable_provider != NULL)
			index[i] = variable_provider->get(varNames[i])->value(&person);
		else
			index[i] = person.get(VarsInfo::indexOf(varNames[i]));
	}
	
	return isIndexKey(index);
}

template <class val_type> std::string VarMap<val_type>::printMap(const Person &person) const {
	VarMapKey index(this->indexLength);
	
	for(size_t i=0; i < indexLength; i++) {
		if(variable_provider != NULL)
			index[i] = variable_provider->get(varNames[i])->value(&person);
		else
			index[i] = person.get(VarsInfo::indexOf(varNames[i]));
	}
	
	return printMap(index);
}


template <class val_type> std::string VarMap<val_type>::printMap(const VarMapKey &index) const {
	std::ostringstream ss;
	
	for(size_t i=0; i < indexLength; i++)
		ss << varNames[i] << "=" << index[i] << "    ";
	ss << "value=" << get(index);
	
	return ss.str();
}

template <class val_type> std::string VarMap<val_type>::printMap(void) const {
	std::ostringstream ss;
	typename std::map<const VarMapKey, val_type>::const_iterator tabit;
	
	for(size_t i=0; i < varNames.size(); i++)
		ss << varNames[i] << "\t\t";
	ss << "value\n";
		
	for ( tabit=table.begin() ; tabit != table.end(); tabit++ ) {
		VarMapKey index = (*tabit).first;
		for(unsigned int i=0; i < index.size(); i++)
			ss << index[i] << "\t\t";
		ss << get(index) << "\n";
	}
	
	return ss.str();
}

template <class val_type> void VarMap<val_type>::clear(void) {
	table.clear();
	varNames.clear();
	indexLength = 0;
}

template class VarMap<double>;
