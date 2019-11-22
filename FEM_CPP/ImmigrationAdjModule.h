#pragma once
#include "Module.h"
#include "Table.h"

/** 
\todo Generalize \a process code to work with any size time step instead of only 2 year steps
*/
class ImmigrationAdjModule :
	public Module
{
public:
	ImmigrationAdjModule(IVariableProvider* vp, ITableProvider* tabp);
	virtual ~ImmigrationAdjModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Immigration Adjustment Module";}
	virtual void setModelProvider(IModelProvider* mp) {}
	virtual void clear();		
	virtual void setScenario(Scenario* scen);

protected:
	void zeroWts();
	ITable* netMigration;
	unsigned int yr_step; ///< the scenario time step
};
