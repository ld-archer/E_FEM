#pragma once
#include "Person.h"
#include <vector>
#include <algorithm>

/** Wrapper class for a vector to hold lots of persons.

*/
class PersonVector : public std::vector<Person*>
{
public:
	PersonVector(void);
	virtual ~PersonVector(void);
	
	void readStata(const char* file);
	void readDelimited(const char* file, char delim);
	void writeDelimited(const char* file, char delim) const;

	void serialize(std::ostream& ostrm) const;
	void deserialize(std::istream& istrm);

	void serialize(const char* file) const;
	void deserialize(const char* file);

	virtual void clear();
	virtual void remove(std::vector<Person*>::iterator pos);

	inline void sortByID() { std::sort(begin(), end(), personComparer); }

	/** A function to check for duplicate IDs. not something to be run frequently, as
	    it cycles through all persons.

	    @return returns false if all IDs are unique, throws an exception otherwise
	*/
	bool checkIDs() const;
protected:
	void buildSpouses();
};
