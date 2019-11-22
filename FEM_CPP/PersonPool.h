#pragma once
#include "Person.h"
#include <set>

class PersonPool
{
public:
	~PersonPool(void);

	inline static Person* newPerson() {return get()->_newPerson();}
	inline static void releasePerson(Person* p) {get()->_releasePerson(p);}
	
	inline static PersonPool* get() {
		if(_pool == NULL)
			initPool();
		return _pool;
	}

	inline static void initPool(size_t size) {	_pool = new PersonPool(size);	}
	inline static void initPool() {	initPool(DEFAULT_SIZE);	}
	inline static void deletePool() {if(_pool != NULL) delete _pool;}

protected:

	static PersonPool* _pool;

	PersonPool(size_t size);
	Person* _newPerson();
	void _releasePerson(Person* p);

	size_t nPersons;
	size_t nFreePersons;
	size_t nUsedPersons;
	std::set<Person*> inuse_persons;
	std::vector<Person*> free_persons;
	static const int DEFAULT_SIZE = 50000;
};
