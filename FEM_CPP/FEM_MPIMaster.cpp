#include "FEM_MPIMaster.h"
#include "utility.h"
#include "Logger.h"
#include "Random.h"
#include "fem_exception.h"
#include <sstream>
#include <iomanip>
#include "mpi.h"


#ifdef __FEM_WIN__
#include <windows.h>
#define sleep(x) Sleep((x)*1000)
#endif 

#ifdef __FEM_UNIX__
#include <unistd.h>
#endif 




FEM_MPIMaster::FEM_MPIMaster(Settings& settings) : FEM(settings)
{
}

FEM_MPIMaster::~FEM_MPIMaster(void)
{
}



void FEM_MPIMaster::runScenario(Scenario* scenario, RandomProvider* rnd_provider) {
	std::ostringstream ss;
	Logger::log("Starting FEM Simulation", INFO);
	ss << "Scenario: " << scenario->Name();
	Logger::log(ss.str(), INFO);
	ss.str("");

	Logger::log(scenario->describe(), FINE);
	prepScenario(scenario);
	
	Random* random;
	
	numprocs = MPI::COMM_WORLD.Get_size();
	
	reps_finished = 0;
	rep = 0;
	nyr_steps = (scenario->EndYr() - scenario->StartYr())/scenario->YrStep() + 1;
	nmeasures = summary_module->numMeasures();
	summary_data = new double[nyr_steps*nmeasures+1];
	MPI::Status stats;

	// NOTE: MPI communicates with the actual rep number (1,2,3,...), but
	// FEM classes uses zero-indexing for the rep number (0,1,2,...)
	for(int i = 1; i < min(numprocs, scenario->NReps()); i++) {
		unsigned long int MPI_rep = rep+1;
		MPI::COMM_WORLD.Send(&MPI_rep, 1, MPI::UNSIGNED_LONG, i, 1); 
		ss << "Master Assigned Rep " << rep+1 << " to slave [" << i << "]";
		Logger::log(ss.str().c_str(), FINER);
		ss.str("");
		rep++;
	}
	for(int i = ((unsigned long int) numprocs < scenario->NReps() ? numprocs : (int) scenario->NReps()); i < numprocs; i++) {
		unsigned long int dummy = 0;
		MPI::COMM_WORLD.Send(&dummy, 1, MPI::UNSIGNED_LONG, i, 1); 
	}

	while(rep < scenario->NReps()){
		ss << "Repetition " << rep+1 << "..........";
		Logger::log(ss.str().c_str(), INFO);
		ss.str("");
		random = rnd_provider->getRandom(rep);
		unsigned long int masters_rep = rep;
		rep++; // increment to next rep for the next available node
		runRep(scenario, random, masters_rep); // master run current rep
		ss << "Master finished Rep " << masters_rep+1;
		Logger::log(ss.str().c_str(), INFO);
		ss.str("");
		reps_finished++;
	}

	while(reps_finished < scenario->NReps()) {
		checkSlaves(scenario);
		sleep(1);
	}

	summary_module->scenarioFinished();
	summary_module->outputByRep();
	summary_module->output();
	
	ss << "Simulation for Scenario [" << scenario->Name() << "] Finished!";
	Logger::log(ss.str().c_str(), INFO);
	ss.str("");
	delete[] summary_data;
}


void FEM_MPIMaster::checkSlaves(Scenario* scenario) {

	MPI::Status stats;
	std::ostringstream ss;
	while(MPI::COMM_WORLD.Iprobe(MPI::ANY_SOURCE, MPI::ANY_TAG)){
	  MPI::COMM_WORLD.Recv(summary_data, (int) (nyr_steps*nmeasures+1), MPI::DOUBLE, MPI::ANY_SOURCE, MPI::ANY_TAG, stats);
		ss << "Master Received Rep " << (int)(summary_data[0] + 1) << " summary data from slave [" << stats.Get_source() << "]";
		reps_finished++;
		Logger::log(ss.str().c_str(), FINER);
		ss.str("");
		summary_module->addRepData(summary_data[0], summary_data+1);

		unsigned long int dummy = rep < scenario->NReps() ? rep+1 : 0;
		MPI::COMM_WORLD.Send(&dummy, 1, MPI::UNSIGNED_LONG, stats.Get_source(), 1); 
		if(dummy >= 1) {
			ss << "Master Assigned Rep " << dummy << " to slave [" << stats.Get_source() << "]";
			Logger::log(ss.str().c_str(), FINER);
			ss.str("");
		}
		rep++;
	}
}
