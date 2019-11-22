#pragma once
#include "Scenario.h"
#include "Settings.h"

/** Interface for classes configurable by scenario and settings parameters
*/	
class Configurable
{
public:

	virtual ~Configurable(void) {}
	virtual setScenario(Scenario* scen) {}
	virtual setSettings(Settings* settings) {}

};
