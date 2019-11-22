#pragma once
#include "FEM.h"

class FEM_MPIMaster :
	public FEM
{
public:
	FEM_MPIMaster(Settings& settings);
	virtual ~FEM_MPIMaster(void);
	virtual void runScenario(Scenario* scenario, RandomProvider* rnd_provider);
	
protected:
	virtual void yearEndHook(Scenario* scenario, Random* random, unsigned int year) { FEM::yearEndHook(scenario, random, year); checkSlaves(scenario); }
	virtual void checkSlaves(Scenario* scenario);
	
	int numprocs;///< For some reason, OpenMPI stores the number of processors as int instead of unsigned int
	unsigned long int reps_finished ;
	unsigned long int rep;
	unsigned int nyr_steps;
	unsigned int nmeasures;
	double* summary_data;
};
