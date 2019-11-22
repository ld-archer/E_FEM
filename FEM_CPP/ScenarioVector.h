#pragma once
#include <vector>
#include "Scenario.h"
class ScenarioVector :
	public std::vector<Scenario*>
{
public:
	ScenarioVector(void);
	virtual ~ScenarioVector(void);

	
	void readDelimited(const char* file, char delim);

	virtual void clear();
};

