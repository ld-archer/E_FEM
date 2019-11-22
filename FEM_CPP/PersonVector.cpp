#include "PersonVector.h"
#include "utility.h"
#include "PersonPool.h"
#include <map>
#include <fstream>
#include "fem_exception.h"
#include <cstring>
#include <cstdlib>
#include "Logger.h"
#include <set>
#include <sstream>


PersonVector::PersonVector(void)
{
}

PersonVector::~PersonVector(void)
{
	for(unsigned int i = 0; i < size(); i++)
		PersonPool::releasePerson((*this)[i]);
}

void PersonVector::clear(void)
{
	for(unsigned int i = 0; i < size(); i++)
		PersonPool::releasePerson((*this)[i]);
	std::vector<Person*>::clear();
}

void PersonVector::remove(std::vector<Person*>::iterator pos)
{
	PersonPool::releasePerson(*pos);
	std::vector<Person*>::erase(pos);
}

void PersonVector::readStata(const char *file) {
	std::ifstream istrm(file, std::ios_base::binary);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));


	const unsigned int MAX_VARS = 2000;
	const unsigned int MAX_DESCRIPTOR = MAX_VARS*118+2;
	const unsigned int BUF_SIZE = MAX_DESCRIPTOR;

	char buf[BUF_SIZE];
	memset(buf, 0, BUF_SIZE);
	// Read Stata Header 
	istrm.read(buf, 109);
	if((buf[0] != 0x72) && (buf[0] != 0x73)) {
		throw fem_exception("Currently can only read Stata format 114 or 115");
	}
	// Figure out bytye order;
	bool ds_lohi, my_lohi;
	unsigned int a=1;
	if(0 != *((unsigned char *)(&a)))
		my_lohi = true;
	else 
		my_lohi = false; 
	if(buf[1] == 0x02)
		ds_lohi = true;
	else
		ds_lohi = false;

	size_t nvars = (size_t) readStataShort(buf + 4, ds_lohi, my_lohi);
	size_t nobs = (size_t) readStataInt(buf + 6, ds_lohi, my_lohi);


	memset(buf, 0, BUF_SIZE);

	/* Read Stata Descriptors */
	istrm.read(buf, (std::streamsize) (118*nvars + 2));

	// Read in the types and store into an array
	unsigned char var_types[MAX_VARS];
	memcpy(var_types, buf, nvars);

	// Read in the var names, figure out which variable enum they are for, and store into an array
	Vars::Vars_t vars[MAX_VARS];
	for(size_t i = 0; i < nvars; i++) {
		vars[i] = VarsInfo::indexOf(buf+i*33+nvars);
		if(vars[i] == Vars::_NONE) Logger::log("present in data, missing in FEM: " + std::string(buf+i*33+nvars), WARNING);
	}
	// Don't care about the srtlist, fmtlist, or lbllist 

	/* Read Variable Labels, but dont care about them */
	istrm.read(buf, (std::streamsize) (81*nvars));

	// Read expansion fields to skip over them 
	bool more_to_read = true;
	while(more_to_read) {
		istrm.read(buf, 5);
		char flag = buf[0];
		int len = readStataInt(buf+1, ds_lohi, my_lohi);
		istrm.read(buf, len);
		more_to_read = !(len == 0 && flag == 0);
	}
		
	// Now read the data
	// First, figure out how long each observation is:
	int obslen = 0;
	for(size_t i = 0; i < nvars; i++) 
		obslen += var_types[i] == 0xfb ? 1 : ( // byte
				  var_types[i] == 0xfc ? 2 : ( // short
				  var_types[i] == 0xfd ? 4 : ( // int
				  var_types[i] == 0xfe ? 4 : ( // float
				  var_types[i] == 0xff ? 8 : ( // double
								  var_types[i] // string
				 )))));
	// Now read the data
	for(size_t j = 0; j < nobs; j++) {
		Person* p = PersonPool::newPerson();
		istrm.read(buf, obslen);
		char* cur_buf = buf;
		for(size_t i = 0; i < nvars; i++) {
			if(vars[i] != Vars::_NONE) {
				switch(var_types[i]) {
					case 0xfb:		// byte
						p->set(vars[i], *cur_buf);
						if(*cur_buf == STATA_BYTE_MISSING)
							p->set_missing(vars[i]);
						break;
					case 0xfc:		// short
						p->set(vars[i], readStataShort(cur_buf, ds_lohi, my_lohi));
						if(readStataShort(cur_buf, ds_lohi, my_lohi) == STATA_INT_MISSING)
							p->set_missing(vars[i]);
						break;
					case 0xfd:		// int
						p->set(vars[i], readStataInt(cur_buf, ds_lohi, my_lohi));
						if(readStataInt(cur_buf, ds_lohi, my_lohi) == STATA_LONG_MISSING)
							p->set_missing(vars[i]);
						break;
					case 0xfe:		// float
						p->set(vars[i], readStataFloat(cur_buf, ds_lohi, my_lohi));
						if(readStataFloat(cur_buf, ds_lohi, my_lohi) == STATA_FLOAT_MISSING)
							p->set_missing(vars[i]);
						break;
					case 0xff:		// double
						p->set(vars[i], readStataDouble(cur_buf, ds_lohi, my_lohi));
						if(readStataDouble(cur_buf, ds_lohi, my_lohi) == STATA_DOUBLE_MISSING)
							p->set_missing(vars[i]);
						break;
				}
			}
			cur_buf +=	  var_types[i] == 0xfb ? 1 : ( // byte
						  var_types[i] == 0xfc ? 2 : ( // short
						  var_types[i] == 0xfd ? 4 : ( // int
						  var_types[i] == 0xfe ? 4 : ( // float
						  var_types[i] == 0xff ? 8 : ( // double
										  var_types[i] // string
						 )))));
		}
		p->set(Vars::internal_id, p->getID());
		p->set(Vars::active, false);
		this->push_back(p);
	}

	istrm.close();	
	buildSpouses();

}

void PersonVector::readDelimited(const char* file, char delim)
{
	std::ifstream istrm(file);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));

	std::string delim_str(1, delim);
	std::string line;
	istrm >> line;
	std::vector<std::string> tokens;
	str_tokenize(line, tokens, delim_str);
	std::vector<Vars::Vars_t> vars;
    for(unsigned int i = 0; i < tokens.size(); i++)
		vars.push_back(VarsInfo::indexOf(tokens[i]));


        
    while (!istrm.eof()) {
		try {
			Person* p = PersonPool::newPerson();
			p->readDelimited(istrm, delim, vars);
			push_back(p);
		} catch(fem_exception) {
		}
	}
    buildSpouses();
}

void PersonVector::buildSpouses() {
	std::map<double, std::vector<Person*> > households;
	std::vector<Person*>::iterator it;
	for ( it=begin() ; it < end(); it++ ) {
		double hhid = ((*it)->get(Vars::hhid));
		households[hhid].push_back(*it);
	}
	std::map<double, std::vector<Person*> >::iterator mit;
	for ( mit=households.begin() ; mit != households.end(); mit++ ) {
		if((*mit).second.size() > 1) {
			
			if((*mit).second.size() > 2) {
				std::ostringstream ss;
				ss << "Found more than two people in one household [hhid = " << (*mit).first << "].";
				throw fem_exception(ss.str());	
			}
			
			(*mit).second[0]->setSpouse((*mit).second[1]);
			(*mit).second[1]->setSpouse((*mit).second[0]);
		}
	}
}

void PersonVector::writeDelimited(const char* file, char delim) const
{
	std::ofstream outf(file);
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	
	outf.unsetf(std::ios_base::floatfield);
	outf.precision(14);
	/* Write variable names into first row */
	for(unsigned i = 0; i < Vars::NVars; i++)
	{
		outf << VarsInfo::labelOf((Vars::Vars_t)i);
		if (i < Vars::NVars - 1)
			outf << delim;
	}
	outf << std::endl;


	std::vector<Person*>::const_iterator itr;
	for(itr = begin(); itr != end(); ++itr) {
		(*itr)->writeDelimited(outf, delim);
		outf << std::endl;
	}
	outf.close();
}


void PersonVector::serialize(std::ostream& ostrm) const {
	size_t npersons = size();
	ostrm.write((char*)&npersons, sizeof(int));
	std::vector<Person*>::const_iterator itr;
	for(itr = begin(); itr != end(); ++itr)
		(*itr)->serialize(ostrm);
}

void PersonVector::serialize(const char* file) const
{
	std::ofstream outf(file, std::ios::out | std::ios::binary);
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	serialize(outf);
	outf.close();
}


void PersonVector::deserialize(std::istream& istrm) {
	size_t npersons = 0;
	istrm.read((char*)&npersons, sizeof(int));
	this->clear();
	this->reserve(npersons);
	for(size_t i = 0; i < npersons; i++) {
		Person* p = PersonPool::newPerson();
		p->deserialize(istrm);
		push_back(p);
	}
	buildSpouses();
}

void PersonVector::deserialize(const char* file)
{
	std::ifstream istrm(file, std::ios::in | std::ios::binary);
	if( istrm.bad() || istrm.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	deserialize(istrm);
	istrm.close();
}

bool PersonVector::checkIDs() const {
  
  std::set<unsigned int> ids;
  PersonVector::const_iterator itr;
  for(itr = begin(); itr < end(); itr++) {
    double id = (*itr)->getID();
    if(ids.count(id) > 0)
      throw fem_exception("Two or more Persons have the same getID");
    else ids.insert(id);
  }

  return false;
}
