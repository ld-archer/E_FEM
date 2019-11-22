#pragma once

#include <string>
#include <vector>
#include <bitset>
#include "Vars.h"
#include "missing_var_exception.h"
#include <map>

class Person
{
public:
	Person(void);
	virtual ~Person(void);

	Person(const Person& source);

	void clear();

	Person& operator=(const Person& source);

	void copyFrom(const Person& source);

	void set(Vars::Vars_t v, double val);
	void set(Vars::Vars_t v, int val);
	void set(Vars::Vars_t v, unsigned int val);
	void set(Vars::Vars_t v, bool val);
	void set(Vars::Vars_t v, float val);
	void set(Vars::Vars_t v, long val);

	bool is_missing(Vars::Vars_t v) const {return missing[v];}
	void set_missing(Vars::Vars_t v) {missing[v] = true;}

	double get(Vars::Vars_t v) const ;
	inline double operator[](Vars::Vars_t v) const { return get(v);}
	bool test(Vars::Vars_t v) const ;

	Person* getSpouse() const {return spouse;}
	void setSpouse(Person* sp) {spouse = sp;}

	void readDelimited(std::istream& istrm, char delim, std::vector<Vars::Vars_t>& vars);
	void writeDelimited(std::ostream& ostrm, char delim, std::vector<Vars::Vars_t>& vars) const;
	void writeDelimited(std::ostream& ostrm, char delim) const;
	void serialize(std::ostream& ostrm) const;
	void deserialize(std::istream& istrm);

	/** This should be a unique ID used mostly for seeding random number generator. 
	 It is not a const operator, because the first time an ID is requested we might need to create
	one and add it to the static idMap.
	*/
	unsigned int getID();
	unsigned int getYear() const {return (unsigned int)get(Vars::year);}
	
protected:
	double* data_dbl;
	// char* data_bool;
	short* data_short;
	long* data_long;
	float* data_float;
	std::bitset<Vars::NVars> missing;
	std::bitset<Vars::NVars> data_bool;

	Person* spouse;
	
private:
	void init();
	static std::map<double, unsigned int> idMap;
};


bool personComparer (Person* a,Person* b);
