#pragma once
#include "FEM.h"

class FEM_MPISlave :
	public FEM
{
public:
	FEM_MPISlave(Settings& settings);
	virtual ~FEM_MPISlave(void);
	virtual void runScenario(Scenario* scenario, RandomProvider* rnd_provider);
};
