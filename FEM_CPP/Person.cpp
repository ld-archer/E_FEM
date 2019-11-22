#include "Person.h"
#include "utility.h"
#include <iostream>
#include "fem_exception.h"
#include <cstring>
#include <cstdlib>
#include <sstream>

std::map<double, unsigned int> Person::idMap;

bool personComparer (Person* a,Person* b) {
  return (a->getID() < b->getID() ); 
}


void Person::clear() {

	memset(data_dbl, 0, sizeof(double)*VarsInfo::NVars(VarTypes::Double));
	memset(data_short, 0, sizeof(short)*VarsInfo::NVars(VarTypes::Short));
	memset(data_long, 0, sizeof(long)*VarsInfo::NVars(VarTypes::Long));
	memset(data_float, 0, sizeof(float)*VarsInfo::NVars(VarTypes::Float));
	data_bool.reset();
	missing.set();
	this->spouse = NULL;

}

void Person::init() {
	data_dbl = new double[VarsInfo::NVars(VarTypes::Double)];
	data_short = new short[VarsInfo::NVars(VarTypes::Short)];
	data_long = new long[VarsInfo::NVars(VarTypes::Long)];
	data_float = new float[VarsInfo::NVars(VarTypes::Float)];
}

Person::Person(void)
{
	init();
	clear();
}

void Person::set(Vars::Vars_t v, double val)
{
  if(v==Vars::_NONE)
    throw missing_var_exception("Person cannot set " + std::string(VarsInfo::labelOf(v)));
	switch(VarsInfo::typeOf(v)) {
		case VarTypes::Boolean:
			data_bool[VarsInfo::typeIndexOf(v)] = val == 1.0;
			break;
		case VarTypes::Short:
			data_short[VarsInfo::typeIndexOf(v)] = (short)val;
			break;
	case VarTypes::Long:
	  data_long[VarsInfo::typeIndexOf(v)] = (long) val;
	  break;
	case VarTypes::Float:
	  data_float[VarsInfo::typeIndexOf(v)] = (float) val;
	  break;
		case VarTypes::Double:
			data_dbl[VarsInfo::typeIndexOf(v)] = val;
			break;
	default:
	  throw fem_exception("Unknown VarsType_t in Person::Set(double)");
	}
	missing[v] = false;
}


void Person::set(Vars::Vars_t v, bool val) {
  if(v==Vars::_NONE)
    throw missing_var_exception("Person cannot set " + std::string(VarsInfo::labelOf(v)));
	switch(VarsInfo::typeOf(v)) {
		case VarTypes::Boolean:
			data_bool[VarsInfo::typeIndexOf(v)] = val;
			break;
		case VarTypes::Short:
			data_short[VarsInfo::typeIndexOf(v)] = val ? 1 : 0;
			break;
	case VarTypes::Long:
	  data_long[VarsInfo::typeIndexOf(v)] = val ? 1 : 0;
	  break;
	case VarTypes::Float:
	  data_float[VarsInfo::typeIndexOf(v)] = val ? 1.0 : 0.0;
	  break;
		case VarTypes::Double:
			data_dbl[VarsInfo::typeIndexOf(v)] = val ? 1.0 : 0.0;
			break;
	default:
	  throw fem_exception("Unkown VarsType_t in Person::Set(bool)");
	}
	missing[v] = false;
}


void Person::set(Vars::Vars_t v, int val)
{
  if(v==Vars::_NONE)
    throw missing_var_exception("Person cannot set " + std::string(VarsInfo::labelOf(v)));
	switch(VarsInfo::typeOf(v)) {
		case VarTypes::Boolean:
			data_bool[VarsInfo::typeIndexOf(v)] = val ==  1;
			break;
		case VarTypes::Short:
			data_short[VarsInfo::typeIndexOf(v)] = (short)val;
			break;
	case VarTypes::Long:
	  data_long[VarsInfo::typeIndexOf(v)] = (long) val;
	  break;
	case VarTypes::Float:
	  data_float[VarsInfo::typeIndexOf(v)] = (float) val;
	  break;
		case VarTypes::Double:
			data_dbl[VarsInfo::typeIndexOf(v)] = (double)val;
			break;
	default:
	  throw fem_exception("Unknown VarsType_t in Person::Set(int)");
	}
	missing[v] = false;
}

void Person::set(Vars::Vars_t v, unsigned int val) {
  set(v, (int) val);
}

void Person::set(Vars::Vars_t v, float val) {
  if(v==Vars::_NONE)
    throw missing_var_exception("Person cannot set " + std::string(VarsInfo::labelOf(v)));
  switch(VarsInfo::typeOf(v)) {
  case VarTypes::Boolean:
    data_bool[VarsInfo::typeIndexOf(v)] = val == 1.0;
    break;
  case VarTypes::Short:
    data_short[VarsInfo::typeIndexOf(v)] = (short) val;
    break;
  case VarTypes::Long:
    data_long[VarsInfo::typeIndexOf(v)] = (long) val;
    break;
  case VarTypes::Float:
    data_float[VarsInfo::typeIndexOf(v)] = val;
    break;
  case VarTypes::Double:
    data_dbl[VarsInfo::typeIndexOf(v)] = (double) val;
    break;
  default:
    throw fem_exception("Unknown VarsType_t in Person::Set(float)");
  }
  missing[v] = false;
}

void Person::set(Vars::Vars_t v, long val) {
  if(v==Vars::_NONE)
    throw missing_var_exception("Person cannot set " + std::string(VarsInfo::labelOf(v)));
  switch(VarsInfo::typeOf(v)) {
  case VarTypes::Boolean:
    data_bool[VarsInfo::typeIndexOf(v)] = val == 1;
    break;
  case VarTypes::Short:
    data_short[VarsInfo::typeIndexOf(v)] = (short) val;
    break;
  case VarTypes::Long:
    data_long[VarsInfo::typeIndexOf(v)] = val;
    break;
  case VarTypes::Float:
    data_float[VarsInfo::typeIndexOf(v)] = (float) val;
    break;
  case VarTypes::Double:
    data_dbl[VarsInfo::typeIndexOf(v)] = (double) val;
    break;
  default:
    throw fem_exception("Unknown VarsType_t in Person::Set(long)");
  }
  missing[v] = false;
}


bool Person::test(Vars::Vars_t v) const {
  if (is_missing(v) || v == Vars::_NONE) 
	  throw missing_var_exception("Person cannot test " + std::string(VarsInfo::labelOf(v)));
	return VarsInfo::typeOf(v) == VarTypes::Boolean ? data_bool[VarsInfo::typeIndexOf(v)] : get(v) == 1.0;
}

double Person::get(Vars::Vars_t v) const {
  if (is_missing(v) || v == Vars::_NONE) 
	  throw missing_var_exception("Person cannot get " + std::string(VarsInfo::labelOf(v)));
	switch(VarsInfo::typeOf(v)) {
		case VarTypes::Boolean:
			return data_bool[VarsInfo::typeIndexOf(v)] ? 1.0 : 0.0;
			break;
		case VarTypes::Short:
			return data_short[VarsInfo::typeIndexOf(v)];
			break;
	case VarTypes::Long:
	  return data_long[VarsInfo::typeIndexOf(v)];
	  break;
	case VarTypes::Float:
	  return data_float[VarsInfo::typeIndexOf(v)];
	  break;
		case VarTypes::Double:
			return data_dbl[VarsInfo::typeIndexOf(v)];
			break;
	default:
	  throw fem_exception("Uknown VarsType_t in Person::get");
	}

}

Person::Person(const Person &source)
{
	init();
	copyFrom(source);
}

Person& Person::operator =(const Person & source)
{
  copyFrom(source);
	return *this;
}

/*
copyFrom assumes member data arrays have already been initialized
by the constructor
*/
void Person::copyFrom(const Person & source)
{
	if (this != &source) // Check that we are not assigning the same object
	{
		for(unsigned int i = 0; i < VarsInfo::NVars(VarTypes::Double); i++)
			data_dbl[i] = source.data_dbl[i];
		for(unsigned int i = 0; i < VarsInfo::NVars(VarTypes::Short); i++)
			data_short[i] = source.data_short[i];
		for(unsigned int i = 0; i < VarsInfo::NVars(VarTypes::Long); i++)
	  	data_long[i] = source.data_long[i];
		for(unsigned int i = 0; i < VarsInfo::NVars(VarTypes::Float); i++)
		  data_float[i] = source.data_float[i];
		for(unsigned int i = 0; i < VarsInfo::NVars(VarTypes::Boolean); i++)
			data_bool[i] = source.data_bool[i];
		for(unsigned int i = 0; i < Vars::NVars; i++)
			missing[i] = source.missing[i];
	}
}



Person::~Person(void)
{
	delete[] data_dbl;
	delete[] data_short;
	delete[] data_long;
	delete[] data_float;
	// delete[] data_bool;
}


void Person::readDelimited(std::istream& istrm, char delim, std::vector<Vars::Vars_t>& vars) {
	std::string delim_str(1, delim);
	std::string line;
	istrm >> line;
	if(line == "")
		throw fem_exception("No person data");
	std::vector<std::string> tokens;
	str_tokenize(line, tokens, delim_str);
	for(unsigned int i = 0; i < tokens.size(); i++)
		if(vars[i] != Vars::_NONE) {
			if(tokens[i] != ".")
				set(vars[i], atof(tokens[i].c_str()));
			else
				set_missing(vars[i]);
		}
}

void Person::writeDelimited(std::ostream& ostrm, char delim, std::vector<Vars::Vars_t>& vars) const {
	for(unsigned i = 0; i < vars.size(); i++)	{
		if(is_missing(vars[i])) {
			ostrm << ".";
		} else {
		  switch(VarsInfo::typeOf(vars[i])) {
		  case VarTypes::Boolean:
		  case VarTypes::Short:
		    ostrm << (short)get(vars[i]);
		    break;
		  case VarTypes::Long:
		    ostrm << (long) get(vars[i]);
		    break;
		  case VarTypes::Float:
		    ostrm << (float) get(vars[i]);
		    break;
		  case VarTypes::Double:
		    ostrm << get(vars[i]);
		    break;
		  default:
		    throw fem_exception("Unknown VarsTYpe_t in Person::writeDelimited");
		  }
		}
		if (i < vars.size() - 1)
			ostrm << delim;
	}
	//ostrm << std::endl;
}


void Person::writeDelimited(std::ostream& ostrm, char delim) const {
	for(unsigned v = 0; v < Vars::NVars; v++)	{
		if(is_missing((Vars::Vars_t)v))  {
			ostrm << ".";
		} else {
			if(VarsInfo::typeOf((Vars::Vars_t)v) == VarTypes::Boolean || VarsInfo::typeOf((Vars::Vars_t)v) == VarTypes::Short)  {
				//ostrm.setf(std::ios_base::floatfield);
				ostrm.precision(0);
			} else if(VarsInfo::typeOf((Vars::Vars_t)v) == VarTypes::Double) {
				//ostrm.unsetf(std::ios_base::floatfield);
				ostrm.precision(14);
			}
			ostrm << get((Vars::Vars_t)v);
		}
		if (v < Vars::NVars - 1)
			ostrm << delim;
	}
	//ostrm << std::endl;
}

void Person::serialize(std::ostream& ostrm) const {
	ostrm.write((char*)data_dbl, VarsInfo::NVars(VarTypes::Double)*sizeof(double)/sizeof(char));
	ostrm.write((char*)data_short, VarsInfo::NVars(VarTypes::Short)*sizeof(short)/sizeof(char));
	ostrm.write((char*)data_long, VarsInfo::NVars(VarTypes::Long)*sizeof(long)/sizeof(char));
	ostrm.write((char*)data_float, VarsInfo::NVars(VarTypes::Float)*sizeof(float)/sizeof(char));
	//ostrm.write((char*)data_bool, VarsInfo::NVars(VarTypes::Boolean)*sizeof(char)/sizeof(char));
	std::string str;
	str = data_bool.to_string();
	ostrm.write(str.c_str(), Vars::NVars);

	str = missing.to_string();
	ostrm.write(str.c_str(), Vars::NVars);
}


void Person::deserialize(std::istream& istrm) {
	istrm.read((char*)data_dbl, VarsInfo::NVars(VarTypes::Double)*sizeof(double)/sizeof(char));
	istrm.read((char*)data_short, VarsInfo::NVars(VarTypes::Short)*sizeof(short)/sizeof(char));
	istrm.read((char*)data_long, VarsInfo::NVars(VarTypes::Long)*sizeof(long)/sizeof(char));
	istrm.read((char*)data_float, VarsInfo::NVars(VarTypes::Float)*sizeof(float)/sizeof(char));
//	istrm.read((char*)data_bool, VarsInfo::NVars(VarTypes::Boolean)*sizeof(char)/sizeof(char));
	char buf[Vars::NVars];
	istrm.read(buf, Vars::NVars);
	data_bool = std::bitset<Vars::NVars>(std::string(buf));
	istrm.read(buf, Vars::NVars);
	missing = std::bitset<Vars::NVars>(std::string(buf));
}

unsigned int Person::getID() {
  std::ostringstream strs;
  double hhidpn = get(Vars::hhidpn);

  if(idMap.count(hhidpn) == 0)
    idMap[hhidpn] = idMap.size();

  return idMap[hhidpn];
}
