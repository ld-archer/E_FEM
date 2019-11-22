#include "PersonPool.h"
#include "Logger.h"
#include <sstream>
PersonPool* PersonPool::_pool = NULL;

PersonPool::PersonPool(size_t size)
{
	nPersons = size;
	nFreePersons = nPersons;
	nUsedPersons = 0;
	free_persons.reserve(nPersons);
	for(size_t i = 0; i < nFreePersons; i++)
		free_persons.push_back(new Person());
}

PersonPool::~PersonPool(void)
{
 	if(nUsedPersons > 0) {
		std::ostringstream ss;
		ss << "Deleting Persons Pool, but there are still " << nUsedPersons << " persons in use.";
		Logger::log(ss.str(), WARNING);
		ss.str("");
		ss << "This memory will be lost.";
		Logger::log(ss.str(), WARNING);
	}
	for(size_t i = 0; i < nFreePersons; i++)
		delete free_persons[i];
}


Person* PersonPool::_newPerson() {
	if(nFreePersons == 0) {
		// Double the size by creating nPerson number of free persons;
		std::ostringstream ss;
		ss << "Growing Persons Pool by " << nPersons << " persons";
		Logger::log(ss.str(), WARNING);
		nFreePersons = nPersons;
		for(size_t i = 0; i < nFreePersons; i++)
			free_persons.push_back(new Person());
		nPersons += nFreePersons;
	}
	Person* p = free_persons.back();
	free_persons.pop_back();
	inuse_persons.insert(p);
	nFreePersons--;
	nUsedPersons++;
	p->clear();
	return p;

}

void PersonPool::_releasePerson(Person* p) {
	p->clear();
	inuse_persons.erase(p);
	free_persons.push_back(p);
	nFreePersons++;
	nUsedPersons--;
}
