
#include "Person.h"
#include <iostream>
#include <sstream>
#include <vector>
#include "utility.h"
#include "PersonVector.h"
#include "FEM.h"
#include "FEM_MPIMaster.h"
#include "FEM_MPISlave.h"
#include "TimeSeries.h"
#include "Table.h"
#include "EquationParser.h"
#include "EquationNode.h"
#include "Logger.h"
#include "RandomBlowfishProvider.h"
#include "RandomBasicProvider.h"
#include "TimeSeriesManager.h"
#include "TableManager.h"
#include "ScenarioVector.h"
#include "PersonPool.h"
#include "fem_exception.h"
#include "mpi.h"
#include <fstream>
#include <time.h>

#include <stdio.h>  /* defines FILENAME_MAX */
#ifdef __FEM_WIN__
    #include <direct.h>
    #define GetCurrentDir _getcwd
#else
    #include <unistd.h>
	#include <sys/types.h>
    #define GetCurrentDir getcwd
#endif


void copy_settings(std::string source, std::string dest, Settings &settings);
void test_ss_calc(std::string settings_path);

int main(int argc,char **argv)
{

	std::ostringstream ss;
#ifdef __FEM_UNIX__
	// Reset priority asap!
	pid_t pid = getpid();
	ss << "renice +19 -p " << pid;
  int sysret = system(ss.str().c_str());
  if(sysret != 0)
    std::cerr << "Renice had nonzero return code.";
	ss.str("");
#endif
	// Initialize the MPI environment and find the rank of this processor.
	int myid;
	MPI::Init(argc,argv);
	myid     = MPI::COMM_WORLD.Get_rank();

	std::string settings_name("settings.txt");
	if(argc > 1)
	  settings_name = std::string(argv[1]);

	// Find out if this processor is the master
	bool is_master = myid == 0;


	// Find the current path. Should be something of the form XXXXXXX/runtime
	char cCurrentpath[FILENAME_MAX];

	if (!GetCurrentDir(cCurrentpath, sizeof(cCurrentpath)))
	{
		std::cerr << "Could not get the current working directory! Fatal!";
		return 2;
	}
	/*
	cCurrentpath[sizeof(cCurrentpath) - 1] = '\0';
	ss << cCurrentpath << _PATH_DELIM_ << "FEM_CPP_settings";
	test_ss_calc(ss.str());
	 return 0;
 */
	try{
		// Create an initial pool of 50,000 person objects. This should be enough for most simulations
		PersonPool::initPool(50000);

		Settings settings;
		settings.set("base_dir", cCurrentpath);

		// Read in settings file
		settings.readSettings(std::string(settings.get("base_dir") + _PATH_DELIM_ + settings_name.c_str()).c_str());

		// Setup Logging
		if(is_master) {

			// Log everything to the log_all.txt file
			Logger::setLogLevel(ALL);
			ss << settings.get("base_dir") << _PATH_DELIM_ << "log_all.txt";
			Logger::addHandler(
				new SeverityFormattingLogHandler(
				new TimeFormattingLogHandler(
				new FileLogHandler(ss.str().c_str()))));
			ss.str("");

			// Log just general and warning/error messages to the log_info.txt file
			ss << settings.get("base_dir") << _PATH_DELIM_ << "log_info.txt";
			Logger::addHandler(
				new SeverityFormattingLogHandler(
				new TimeFormattingLogHandler(
				new FileLogHandler(ss.str().c_str(), INFO))));
			ss.str("");

			// Log just errors or warnings to log_error.txt
			ss << settings.get("base_dir") << _PATH_DELIM_ << "log_error.txt";
			Logger::addHandler(
				new SeverityFormattingLogHandler(
				new FileLogHandler(ss.str().c_str(), WARNING)));
			ss.str("");

			// Log info to standard out
			Logger::addHandler(
					new SeverityFormattingLogHandler(
						new StreamLogHandler(std::cout, INFO)));
			ss.str("");
		}

		// Log to stderr if indicated in the settings
		if(settings.get("log_stderr") == "yes") {
			// Both the master and slave will be logging to stderr. Need to add a prefix so we can tell what message is from
			// what processor
			if(is_master)
				ss << "[Master] " ;
			else
				ss << "[Slave " << myid << "] ";

			Logger::addHandler(
				new PrefixFormattingLogHandler(
					new SeverityFormattingLogHandler(
						new StreamLogHandler(std::cerr, ERROR)), ss.str()));
			ss.str("");
		}

		// Setup Randomness based on the settings file
		RandomProvider* rnd_provider;
		if(settings.get("random_provider") == "blowfish") {
			// Setup blowfish random environment
			RandomBlowfishProvider* rbp = new RandomBlowfishProvider();
			ss << settings.get("base_dir") << _PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << "random_tables" << _PATH_DELIM_ << "blowfish_keys.txt";
			rbp->readKeyFile(ss.str().c_str());
			rnd_provider = rbp;
			ss.str("");
		} else if (settings.get("random_provider") == "basic") {
			// Random numbers just drawn using normal rand() calls.
			// Seed the random number engine with the current time.
			srand(time(NULL));
			rnd_provider = new RandomBasicProvider();
		} else {
			ss << "Unknown Random Provider [" << settings.get("random_provider") << "]!";
			throw fem_exception(ss.str());
		}

		// Read scenarios
		ss << settings.get("base_dir") << _PATH_DELIM_ << settings.get("scenarios_file");
		ScenarioVector sv;
		sv.readDelimited(ss.str().c_str(), ',');
		ss.str("");


		FEM* fem = NULL;

		for(unsigned int i = 0; i < sv.size(); i++) {
		  if(fem != NULL) delete fem;

		  // Create the correct FEM engine, depending on whether this process is the Master or Slave in the MPI setting
		  if(is_master)
		    fem = new FEM_MPIMaster(settings);
		  else
		    fem = new FEM_MPISlave(settings);


			if(is_master) {
				// Check if output directory exists. If not, create it.
				std::string outdir = sv[i]->OutputDir()  + _PATH_DELIM_ + sv[i]->Name();
				if(!dir_exists(outdir))
					make_dir(outdir);

				// Now check if the detailed_output subdirectory exists. If not create it
				outdir += _PATH_DELIM_;
				outdir += "detailed_output";
				if(!dir_exists(outdir))
					make_dir(outdir);
			}

			// Run the scenario
			fem->runScenario(sv[i], rnd_provider);

			// Scenario is done and all data is written.
			// Copy all small input files (settings, models, variables, etc) into the
			// scenario directory for reproducibility
			if(is_master) {
				// Check if a directory exists in the scenario folder called "FEM_CPP_settings". If not, make it
				ss << sv[i]->OutputDir()  << _PATH_DELIM_ << sv[i]->Name() << _PATH_DELIM_ << "FEM_CPP_settings";
				std::string dest_settings_dir = ss.str();
				ss.str("");
				if(!dir_exists(dest_settings_dir))
					make_dir(dest_settings_dir);

				// Copy over the settings.txt, scenarios.csv, and log files
				std::vector<std::string> files_to_copy;
                files_to_copy.push_back("settings.txt");
                files_to_copy.push_back(settings.get("scenarios_file"));
				files_to_copy.push_back("log_all.txt");
				files_to_copy.push_back("log_info.txt");
				files_to_copy.push_back("log_error.txt");

				for(unsigned int j = 0; j < files_to_copy.size(); j++)
					copy_file(dest_settings_dir  + _PATH_DELIM_ + files_to_copy[j], settings.get("base_dir") + _PATH_DELIM_ + files_to_copy[j]);
				files_to_copy.clear();

				// Copy over the scenario migration table, if any
				if(sv[i]->contains("migration_table")) {
					ss << sv[i]->get("migration_table") << ".txt";
					copy_file(dest_settings_dir  + _PATH_DELIM_ + ss.str(), settings.get("base_dir") + _PATH_DELIM_ + "FEM_CPP_settings" + _PATH_DELIM_ + ss.str());
					ss.str("");
				}

				// Check if a directory exists in the scenario folder called "settings/input_data". If not, make it
				ss << sv[i]->OutputDir()  << _PATH_DELIM_ << sv[i]->Name() << _PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << "input_data";
				std::string input_data_dir = ss.str();
				ss.str("");
				if(!dir_exists(input_data_dir))
					make_dir(input_data_dir);

				if(sv[i]->SimuType() == 3) {
					/* Copy incoming cohorts if simutype is 3*/
					for(unsigned int yr = sv[i]->StartYr(); yr <= sv[i]->StopYr(); yr+= sv[i]->YrStep()) {
						ss << settings.get("base_dir") << _PATH_DELIM_ << "input_data" << _PATH_DELIM_ << "new51_" << yr << "_" << sv[i]->NewCohortModel() << ".dta";
						std::string src_new_cohort_file = ss.str();
						ss.str("");

						ss << input_data_dir << _PATH_DELIM_ << "new51_" << yr << "_" << sv[i]->NewCohortModel() << ".dta";
						std::string dest_new_cohort_file = ss.str();
						ss.str("");

						copy_file(dest_new_cohort_file, src_new_cohort_file);
					}
				}

				// Copy over settings
				ss << settings.get("base_dir")  << _PATH_DELIM_ << "FEM_CPP_settings";
				std::string src_settings_dir = ss.str();
				ss.str("");

				copy_settings(src_settings_dir,dest_settings_dir,settings);

				if(sv[i]->contains("settings") && sv[i]->get("settings").length() > 0) {

					ss << sv[i]->OutputDir()  << _PATH_DELIM_ << sv[i]->Name() << _PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_  << sv[i]->get("settings");
					dest_settings_dir = ss.str();
					ss.str("");
					if(!dir_exists(dest_settings_dir))
						make_dir(dest_settings_dir);

					ss << settings.get("base_dir")  << _PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_  << sv[i]->get("settings");
					src_settings_dir = ss.str();
					ss.str("");

					copy_settings(src_settings_dir,dest_settings_dir,settings);
				}

			}

		}

		// Clean up
		delete fem;
		PersonPool::deletePool();

	} catch (const fem_exception & e) 	{
		std::ostringstream oss;
		ss << "Unknown FEM error!" << std::endl << "\t\t" << e.what();
		Logger::log(ss.str(), ERROR);
		MPI::Finalize();
		return 1;
	} catch (const std::exception & e) {
		std::ostringstream oss;
		ss << "Unknown error!" << std::endl << "\t\t" << e.what();
		Logger::log(ss.str(), ERROR);
		MPI::Finalize();
		return 1;
	}
	MPI::Finalize();
	return 0;
}

void copy_settings(std::string source, std::string dest, Settings &settings) {

	std::ostringstream ss;

	// Check if the other settings directories we need are there, and if not, make them.
	std::vector<std::string> req_dirs;
	req_dirs.push_back("models");
	req_dirs.push_back("timeseries");
	req_dirs.push_back("tables");


	for(unsigned int j = 0; j < req_dirs.size(); j++) {
		ss << dest << _PATH_DELIM_<< req_dirs[j];
		if(!dir_exists(ss.str()))
				make_dir(ss.str());
		ss.str("");
	}

	// Copy all relevant files
	std::vector<std::string> files_to_copy;
	std::vector<std::string> temp;

	files_to_copy.push_back(settings.get("vars_def_file"));
	files_to_copy.push_back(settings.get("summary_output"));

	/* Copy time series, if any */
	ss << source << _PATH_DELIM_ << "timeseries";
	std::string time_series_dir = ss.str();
	ss.str("");
	if(dir_exists(time_series_dir)) {
		getdir(time_series_dir.c_str(), temp, "*.txt");
		for(unsigned int j = 0; j < temp.size(); j++) {
			ss << "timeseries" << _PATH_DELIM_ << temp[j];
			files_to_copy.push_back(ss.str());
			ss.str("");
		}
		temp.clear();
	}

	/* Copy tables, if any */
	ss << source << _PATH_DELIM_ << "tables";
	std::string tables_dir = ss.str();
	ss.str("");
	if(dir_exists(tables_dir)) {
		getdir(tables_dir.c_str(), temp, "*.txt");
		for(unsigned int j = 0; j < temp.size(); j++) {
			ss << "tables" << _PATH_DELIM_ << temp[j];
			files_to_copy.push_back(ss.str());
			ss.str("");
		}
		temp.clear();
	}

	/* Copy models, if any */
	ss << source << _PATH_DELIM_ << "models";
	std::string models_dir = ss.str();
	ss.str("");
	if(dir_exists(models_dir)) {
		getdir(models_dir.c_str(), temp, "*.est");
		for(unsigned int j = 0; j < temp.size(); j++) {
			ss << "models" << _PATH_DELIM_ << temp[j];
			files_to_copy.push_back(ss.str());
			ss.str("");
		}
		temp.clear();
	}

	for(unsigned int j = 0; j < files_to_copy.size(); j++)
		copy_file(dest  + _PATH_DELIM_ + files_to_copy[j], source +  _PATH_DELIM_ + files_to_copy[j]);
}

#include "SSCalculator.h"
void test_ss_calc(std::string settings_path) {



	std::ostringstream ss;
	ss.str("");

	TimeSeriesManager ts_manager;

	// Load time series
	ss << settings_path << _PATH_DELIM_ << "timeseries" << _PATH_DELIM_;
	std::string timeseries_dir = ss.str();
	ss.str("");
	ss << "  source: " << timeseries_dir;
	ss.str("");
	try {
		ts_manager.readTimeSeriesDefinitions(timeseries_dir.c_str());
	} catch (const fem_exception & e) {
		std::cout << e.what() << std::endl;
	}

	// Test retirement benefits
	SSCalculator sscalc(&ts_manager);
	Person p;
	p.set(Vars::married, false);
	p.set(Vars::widowed, false);
	p.set(Vars::ry_earn, 0.0);
	p.set(Vars::rq, 400);
	while(0) {
		std::cout << "aime rbyr rbmonth rclyr cyr" << std::endl;
		double aime;
		unsigned int rbyr, rbmonth, rclyr, cyr;
		std::cin >> aime >> rbyr >> rbmonth >> rclyr >> cyr;
		p.set(Vars::raime, aime);
		p.set(Vars::rbyr, rbyr);
		p.set(Vars::rbmonth, rbmonth);
		int ben = (int) sscalc.SSBenefit(&p, cyr, rclyr);
		std::cout << "Benefit Amount: " << ben << std::endl << std::endl;
	}

	// Test spousal benefits
	Person sp;
	sp.set(Vars::married, false);
	p.set(Vars::married, false);
	p.set(Vars::widowed, true);
	p.set(Vars::raime, 0.0);
	p.setSpouse(&sp);

	sp.set(Vars::widowed, false);
	sp.set(Vars::ry_earn, 0.0);
	sp.set(Vars::rq, 400);

	while(0) {
		std::cout << "person aime rbyr rbmonth rclyr cyr" << std::endl;
		double aime;
		unsigned int rbyr, rbmonth, rclyr, cyr, dyr;
		std::cin >> aime >> rbyr >> rbmonth >> rclyr >> cyr;
		p.set(Vars::raime, aime);
		p.set(Vars::rbyr, rbyr);
		p.set(Vars::rbmonth, rbmonth);

		std::cout << "spouse aime rbyr rbmonth rclyr dyr ssclaim" << std::endl;
		int ssclaim;
		std::cin >> aime >> rbyr >> rbmonth >> rclyr >> dyr >> ssclaim;
		sp.set(Vars::raime, aime);
		sp.set(Vars::rbyr, rbyr);
		sp.set(Vars::year, dyr);
		sp.set(Vars::rbmonth, rbmonth);
		sp.set(Vars::ssclaim, ssclaim);
		sp.set(Vars::rssclyr, rclyr);

		int ben = (int) sscalc.SSBenefit(&p, cyr, rclyr);
		std::cout << "Benefit Amount: " << ben << std::endl << std::endl;
	}

	sscalc.test();
}
