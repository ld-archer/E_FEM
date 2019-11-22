#include "FEM_MPISlave.h"
#include "utility.h"
#include "Logger.h"
#include "Random.h"
#include "fem_exception.h"
#include <sstream>
#include <iomanip>
#include "mpi.h"

FEM_MPISlave::FEM_MPISlave(Settings& settings) : FEM(settings)
{

}

FEM_MPISlave::~FEM_MPISlave(void)
{
}



void FEM_MPISlave::runScenario(Scenario* scenario, RandomProvider* rnd_provider) {
	std::ostringstream ss;
	ss.str("");
	prepScenario(scenario);
	
	Random* random;

	MPI::Status stats;

	unsigned int nyr_steps = (scenario->EndYr() - scenario->StartYr())/scenario->YrStep() + 1;
	unsigned int nmeasures = summary_module->numMeasures();
	double* summary_data = new double[nyr_steps*nmeasures+1];

	// NOTE: MPI communicates with the actual rep number (1,2,3,...), but
	// FEM classes uses zero-indexing for the rep number (0,1,2,...)
	unsigned long int rep;
	MPI::COMM_WORLD.Recv(&rep, 1, MPI::UNSIGNED_LONG, 0, MPI::ANY_TAG, stats);
	while(rep >= 1) {
		ss << "Repetition " << rep << "..........";
		Logger::log(ss.str().c_str(), INFO);
		ss.str("");
		random = rnd_provider->getRandom(rep-1);
		runRep(scenario, random, rep-1);
		summary_module->getRepData((unsigned int) rep-1, summary_data+1);
		summary_data[0] = rep-1;
		MPI::COMM_WORLD.Send(summary_data, (int)(nyr_steps*nmeasures+1), MPI::DOUBLE, 0, 1);
		
		MPI::COMM_WORLD.Recv(&rep, 1, MPI::UNSIGNED_LONG, 0, MPI::ANY_TAG, stats);
	}

	delete[] summary_data;
}

