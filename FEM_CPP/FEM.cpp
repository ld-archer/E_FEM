#include "FEM.h"
#include "utility.h"
#include "Logger.h"
#include "Random.h"
#include "fem_exception.h"
#include "file_not_found_exception.h"
#include <sstream>
#include <iomanip>
#include "ConstantTimeSeries.h"
#include "SurvivalModel.h"

FEM::FEM(Settings& s) : model_manager(&var_manager), settings(s)
{
	/* set up list of survival model types */
	survival_type_names.insert("WeibullPHSurvival");
	survival_type_names.insert("Survival");
	
	/* Prepare a string stream to make messages */
	std::ostringstream ss;
	ss.str("");

	ss << "Preparing the FEM Simulator:";
	Logger::log(ss.str(), INFO);

	ss.str("");

	/* Assign the equation builder to the variable and time series managers */
	ts_manager.setBuilder(&builder);
	table_manager.setBuilder(&builder);
	var_manager.setBuilder(&builder);

	// Setup medicare elig age time series 
	medicare_elig_age = new ProxyTimeSeries("medicare_elig_age", "Medicare Eligibility Age");
	ts_manager.addTimeSeries(medicare_elig_age);
	medicare_elig_age->setSeries(ts_manager.addTimeSeries(new ConstantTimeSeries("medicare_elig_age_default", 65)));

	// Setup global variables
	scenario_variables.push_back(new GlobalVariable("mcare_ptb_coin_elas", -.2, "Medicare Part B elasticity to coinsurance"));
	scenario_variables.push_back(new GlobalVariable("mcare_ptb_coin_chg", 0, "The % change in Medicare Part B co-insurance"));
	scenario_variables.push_back(new GlobalVariable("tot_meps",1.05,"NHEA/MEPS adjustment for total medical expenditures"));
	scenario_variables.push_back(new GlobalVariable("tot_mcbs",1.08,"NHEA/MCBS adjustment for total medical expenditures"));
	scenario_variables.push_back(new GlobalVariable("mcaid_meps",1.59,"NHEA/MEPS adjustment for medicaid expenditures"));
	scenario_variables.push_back(new GlobalVariable("mcaid_mcbs",1.48,"NHEA/MCBS adjustment for medicaid expenditures"));
	scenario_variables.push_back(new GlobalVariable("mcare_meps",1.08,"NHEA/MEPS adjustment for medicare expenditures"));
	scenario_variables.push_back(new GlobalVariable("mcare_mcbs",1.09,"NHEA/MCBS adjustment for medicare expenditures"));
	scenario_variables.push_back(new GlobalVariable("hrs_data",0.0,"Boolean for whether to run any HRS-only components"));
	scenario_variables.push_back(new GlobalVariable("elsa_data",1.0,"Boolean for whether to run any ELSA-only components"));
	scenario_variables.push_back(new GlobalVariable("psid_data",0.0,"Boolean for whether to run any PSID-only components"));
	scenario_variables.push_back(new GlobalVariable("nested",1,"Nested bootstrap reps"));
	scenario_variables.push_back(new GlobalVariable("yr_step",2,"Number of years per timestep"));

	for(std::vector<GlobalVariable*>::const_iterator itr = scenario_variables.begin(); itr < scenario_variables.end(); itr++)
		var_manager.addVariable(*itr);

	var_manager.addVariable(new GlobalVariable("bs_elig_bmi1", 35.0, "Min BMI for Bariatric Surgery, having comorbid conditions"));
	var_manager.addVariable(new GlobalVariable("bs_elig_bmi2", 40.0, "Min BMI for Bariatric Surgery, without having comorbid conditions"));
	
	// This is just a placeholder so that the derived variables can be loaded before the health module.
	// The HealthModule constructor will replace this with the actual variable to be used.
	var_manager.addVariable(new GlobalVariable("median_pdied", 0.0,"median mortality probability"));

	// Get bootstrap settings 
	std::string bootsName;
	// Set parameter bootstrap method
	bootsName = settings.get("bootstrap_params");
	if(bootsName == "external")
		bootstrapParams = external;
	else if(bootsName == "no")
		bootstrapParams = none;
	else
		throw fem_exception("Unrecognized parameter bootstrap setting: bootstrap_params=" + bootsName);
	// Set input data bootstrap
	bootsName = settings.get("bootstrap_input");
	if(bootsName == "no")
		bootstrapInput = false;
	else if(bootsName == "yes")
		bootstrapInput = true;
	else
		throw fem_exception("Unrecognized input bootstrap setting: bootstrap_input=" + bootsName);
	// Set new 51 cohort data bootstrap
	bootsName = settings.get("bootstrap_new51");
	if(bootsName == "no")
		bootstrapNew51 = false;
	else if(bootsName == "yes")
		bootstrapNew51 = true;
	else
		throw fem_exception("Unrecognized new 51 cohort bootstrap setting: bootstrap_New51=" + bootsName);

	// Load the default settings
	ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings";
	loadSettings(ss.str(), false);
	ss.str("");

	ss << "Loaded default settings";
	Logger::log(ss.str(), INFO);
	ss.str("");
	describeSettings();


	// Create the interention factory
	interv_fac = new InterventionFactory(&var_manager, &ts_manager);

	// Create Modules	
	health_module = new HealthModule(&var_manager, &ts_manager, &builder, &table_manager);
	// educ_module = new EducModule(&var_manager, &ts_manager);
	crosssec_module = new CrossSectionalModule(&var_manager, &ts_manager);
	interventions_module = new InterventionModule(interv_fac);
	init_interventions_module = new InitInterventionModule(interv_fac);
	global_preinit_module = new GlobalPreInitializationModule(&var_manager, &ts_manager);
	hrs_init_module = new HRSInitializationModule(&var_manager, &ts_manager);
	psid_init_module = new PSIDInitializationModule(&var_manager, &ts_manager);
	global_postinit_module = new GlobalPostInitializationModule(&var_manager, &ts_manager);
	var_calc_module = new VarCalcModule();
	lag_module = new LagModule();
	med_costs_module = new MedCostsModule(&var_manager, &ts_manager, &builder);
	econ_gen_module = new EconGenModule(&ts_manager);
	gov_exp_module = new GovExpModule(&ts_manager);
	summary_module = NULL;
	immig_module = new ImmigrationAdjModule(&var_manager, &table_manager);
	earnings_module = new EarningsModule(&var_manager, &ts_manager);
	output_modules = new OutputModules(&var_manager, settings.get("output"), settings.get("output_vars"));

	modules.push_back(health_module);
	modules.push_back(crosssec_module);
	modules.push_back(interventions_module);
	modules.push_back(init_interventions_module);
	modules.push_back(global_preinit_module);
	modules.push_back(hrs_init_module);
	modules.push_back(psid_init_module);
	modules.push_back(global_postinit_module);
	modules.push_back(var_calc_module);
	modules.push_back(lag_module);
	modules.push_back(med_costs_module);
	modules.push_back(econ_gen_module);
	modules.push_back(immig_module);
	modules.push_back(output_modules);
	modules.push_back(earnings_module);
	modules.push_back(gov_exp_module);
	// modules.push_back(educ_module);
}

FEM::~FEM(void)
{
	std::vector<Module*>::iterator it;
	for(it = modules.begin(); it != modules.end(); ++it)
		delete (*it);
}

void FEM::describeSettings() {

	std::ostringstream ss;
	ss.str("");

	// Describe the loaded series 
	ss << "Loaded Time Series:" << std::endl;
	std::vector<ITimeSeries*> series;
	ts_manager.getAll(series);
	for(unsigned int i = 0; i < series.size(); i++) {
		ss << "  " <<  series[i]->getName() << "(" << series[i]->StartYear() << "," << series[i]->EndYear() << ") ";
		ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  series[i]->getDescription() << std::endl;
	}


	// Describe the loaded tables 
	ss << "Loaded Tables:" << std::endl;
	std::vector<ITable*> tables;
	table_manager.getAll(tables);
	for(unsigned int i = 0; i < tables.size(); i++) {
		ss << "  " <<  tables[i]->getName();
		ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  tables[i]->getDescription() << std::endl;
	}

	
	// Describe the loaded variables
	ss << "Loaded Variables:" << std::endl;
	std::vector<IVariable*> vars;
	var_manager.getAll(vars);
	for(unsigned int i = 0; i < vars.size(); i++) {
		ss << "  " <<  vars[i]->name();
		ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  vars[i]->description() << "\t(" << VarsInfo::labelOf(vars[i]->type()) << ")" << std::endl;
	}

	// Describe the models
	ss << "Loaded Models:" << std::endl;
	std::vector<IModel*> models;
	model_manager.getAll(models);
	for(unsigned int i = 0; i < models.size(); i++) {
		ss << std::endl << "Model: " <<  models[i]->getName() << std::endl;
		ss << models[i]->describe();
	}
	
	Logger::log(ss.str(), FINE);
	ss.str("");

}

void FEM::loadSettings(std::string settings_path, bool specific_settings) {	

	std::ostringstream ss;
	ss.str("");

	if(!dir_exists(settings_path))
	  throw file_not_found_exception(settings_path);

	// Load time series
	ss << settings_path << _PATH_DELIM_ << "timeseries" << _PATH_DELIM_;
	std::string timeseries_dir = ss.str();
	ss.str("");
	Logger::log(" Loading time series data", FINE);
	ss << "  source: " << timeseries_dir;
	Logger::log(ss.str(), FINE);
	ss.str("");

	// Vector to hold list of series read in
	std::vector<ITimeSeries*> series;
	try {
		ts_manager.readTimeSeriesDefinitions(timeseries_dir.c_str(), series);

		// If this is for a specific settings set, document what series were read in
		if(specific_settings) {
			ss << "Loaded Time Series:" << std::endl;
			for(unsigned int i = 0; i < series.size(); i++) {
				ss << "  " <<  series[i]->getName() << "(" << series[i]->StartYear() << "," << series[i]->EndYear() << ") ";
				ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  series[i]->getDescription() << std::endl;
			}
			Logger::log(ss.str(), FINE);
			ss.str("");
		}
	} catch (file_not_found_exception fnfe) {
		// Could not find a directory with time series in it. If this is the default settings, then this is bad
		if(!specific_settings)
			throw fem_exception("Could not access time series for default settings!");

		// If this is for specific settings, then its not a problem.

	} catch (fem_exception e) {
		Logger::log(e.what(), ERROR);
	}

	// Load variables
	Logger::log(" Loading variable definitions", FINE);
	ss << settings_path << _PATH_DELIM_ << settings.get("vars_def_file");
	std::string var_def_file = ss.str();
	ss.str("");
	ss << "  source: " << var_def_file;
	Logger::log(ss.str(), FINE);
	ss.str("");

	// Vector to hold list of variables added
	std::vector<IVariable*> vars_added;
	try {
		var_manager.readVariableDefinitions(var_def_file.c_str(), vars_added);

		// If this is for a specific settings set, document what variables were read in
		if(specific_settings) {
			ss << "Loaded Variables:" << std::endl;
			for(unsigned int i = 0; i < vars_added.size(); i++) {
				ss << "  " <<  vars_added[i]->name();
				ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  vars_added[i]->description() << "\t(" << VarsInfo::labelOf(vars_added[i]->type()) << ")" << std::endl;
			}
			Logger::log(ss.str(), FINE);
			ss.str("");
		}
	} catch (file_not_found_exception fnfe) {
		// Could not find the variables definition file. If this is the default settings, then this is bad
		if(!specific_settings)
			throw fem_exception("Could not access variables definition file!");

		// If this is for specific settings, then its not a problem.

	} catch (fem_exception e) {
		Logger::log(e.what(), ERROR);
	}

	// Load tables
	ss << settings_path << _PATH_DELIM_ << "tables" << _PATH_DELIM_;
	std::string tables_dir = ss.str();
	ss.str("");
	Logger::log(" Loading table data", FINE);
	ss << "  source: " << tables_dir;
	Logger::log(ss.str(), FINE);
	ss.str("");

	// Vector to hold list of tables read in
	std::vector<ITable*> tables;
	try {
		table_manager.setVariableProvider(&var_manager);
		table_manager.readTableDefinitions(tables_dir.c_str(), tables);

		// If this is for a specific settings set, document what tables were read in
		if(specific_settings) {
			ss << "Loaded Tables:" << std::endl;
			for(unsigned int i = 0; i < tables.size(); i++) {
				ss << "  " <<  tables[i]->getName();
				ss << std::setw(20 - ss.str().length()) << std::right << " " <<  std::setw(5) << std::left << "-"  <<  tables[i]->getDescription() << std::endl;
			}
			Logger::log(ss.str(), FINE);
			ss.str("");
		}
	} catch (file_not_found_exception fnfe) {
		// Could not find a directory with tables in it. If this is the default settings, then this is bad
		if(!specific_settings)
			throw fem_exception("Could not access tables for default settings!");

		// If this is for specific settings, then its not a problem.

	} catch (fem_exception e) {
		Logger::log(e.what(), ERROR);
	}

	// There is no longer a default model directory; everything is specific
	if(specific_settings) {
	  // Load models here, bootstrap models will be loaded at the start of each rep
	  ss << settings_path << _PATH_DELIM_ << "models";
	  std::string models_dir = ss.str();
	  loadModels(models_dir, specific_settings);
	}
}

/**
This function will output descriptions of the newly loaded models only 
when specific_settings == true.  It is assumed that optional/default 
models are described elsewhere after loading, but scenario-specific 
models should be described when they are loaded.
*/
void FEM::loadModels(std::string models_dir, bool specific_settings)
{

  if(!specific_settings)
    throw fem_exception("There is no longer a default models directory. You must use specific settings (hrs or psid at the very least)");

	std::ostringstream ss;
	
	Logger::log(" Loading models", FINE);
	ss.str("");
	ss << "  source: " << models_dir;
	Logger::log(ss.str(), FINE);
	ss.str("");
	
	// Vector to hold list of models added
	std::vector<IModel*> models_added;
	try {
		model_manager.readModelDefinitions(models_dir.c_str(), models_added);

		// Special handling for survival models: set the simulation time step length
		SurvivalModel* m;
		for(unsigned int i = 0; i < models_added.size(); i++) {
			if(survival_type_names.count(models_added[i]->getType()) > 0) {
				m = (SurvivalModel*)models_added[i];
				m->set_time_step(var_manager.get("yr_step"));
			}
		}

		// If this is for a specific settings set, document what models were read in
		if(specific_settings) {
			ss << "Loaded Models:" << std::endl;
			for(unsigned int i = 0; i < models_added.size(); i++) {
				ss << std::endl << "Model: " <<  models_added[i]->getName() << std::endl;
				ss << models_added[i]->describe();
			}
			Logger::log(ss.str(), FINE);
			ss.str("");
		}
	} catch (file_not_found_exception fnfe) {
		// Could not find a directory with models in it. If this is the default settings, then this is bad
		if(!specific_settings)
			throw fem_exception("Could not access models directory for default settings!");

		// If this is for specific settings, then its not a problem.

	} catch (fem_exception e) {
		Logger::log(e.what(), ERROR);
	}
}

void FEM::loadRepModels(Scenario* scenario, unsigned int rep) {
	std::ostringstream ss;
		
	ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << "models" << _PATH_DELIM_ << "models_rep" << ceil((rep+1)/(double)nested);
		
	// Load scenario-specific models (if any) for this rep
	if(scenario->contains("settings") && scenario->get("settings").length() > 0) {
		// Settings are entered as "settings1 settings2" so space delimited. Load them in order, so the last one
		// has highest priority

		// Tokenize the settings string
		std::vector<std::string> settings_vec;
		str_tokenize(scenario->get("settings"), settings_vec, " ");
		
		// For each specific setting, load the data for this setting
		for(unsigned int i = 0; i < settings_vec.size(); i++) {
			ss.str("");
			ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << settings_vec[i] << _PATH_DELIM_ << "models" << _PATH_DELIM_ << "models_rep" << ceil((rep+1)/(double)nested);
			loadModels(ss.str(), true);
			ss.str("");
		}
	} 		
}

void FEM::setModels() {
	for(std::vector<Module*>::iterator it = modules.begin(); it != modules.end(); ++it)
		(*it)->setModelProvider(&model_manager);

	this->interv_fac->setModelProvider(&model_manager);
}

void FEM::prepScenario(Scenario* scenario) {
	
	std::ostringstream ss;
	ss.str("");

	/* Clear models from previous scenario (if any) */
	model_manager.clearModels();

	/* Reset default settings */
	ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings";
	loadSettings(ss.str(), false);
	ss.str("");

	/* Load any specific settings for this scenario */
	if(scenario->contains("settings") && scenario->get("settings").length() > 0) {

		// Settings are entered as "settings1 settings2" so space delimited. Load them in order, so the last one
		// has highest priority

		// Tokenize the settings string
		std::vector<std::string> settings_vec;
		str_tokenize(scenario->get("settings"), settings_vec, " ");
		
		// For each specific setting, load the data for this setting
		for(unsigned int i = 0; i < settings_vec.size(); i++) {
			ss << "Using specific settings from settings" << _PATH_DELIM_ << settings_vec[i];
			Logger::log(ss.str(), INFO);
			ss.str("");

			ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << settings_vec[i];
			loadSettings(ss.str(), true);
			ss.str("");
		}
	} else {
		ss << "Using default settings";
		Logger::log(ss.str(), INFO);
		ss.str("");
	}
	
	/* Load up the summary module so it can use any scenario-specific variables */
	ss << settings.get("base_dir") <<_PATH_DELIM_ << "FEM_CPP_settings" << _PATH_DELIM_ << settings.get("summary_output");
	std::string summary_output_file = ss.str();
	ss.str("");
	if(summary_module != NULL) {
	  for(std::vector<Module*>::iterator i=modules.begin(); i < modules.end(); i++) {
	    if(*i == summary_module) i = modules.erase(i);
	  }
	  //	  delete summary_module;
	}
	summary_module = new SummaryModule(summary_output_file.c_str(), &builder, &var_manager);
	med_costs_module->setSummaryModule(summary_module);
	global_preinit_module->setSummaryModule(summary_module);
	global_postinit_module->setSummaryModule(summary_module);
	modules.push_back(summary_module);

	/* Inform each module that there is a new scenario to run. If there is a parameter that
	   a module needs, it will be able to query the scenario for the value of that parameter */
	std::vector<Module*>::iterator it;
	for(it = modules.begin(); it != modules.end(); ++it)
		(*it)->setScenario(scenario);
	
	/* For Medicare Elig Age, can either be a overall number, a file that contains the schedule */
	if(atof(scenario->get("medicare_elig_age").c_str()) == 0.0) {
		medicare_elig_age->setSeries(ts_manager.get(scenario->get("medicare_elig_age")));
	} else {
	  medicare_elig_age->setSeries(ts_manager.addTimeSeries(new ConstantTimeSeries("medicare_elig_age" + scenario->get("medicare_elig_age"), atof(scenario->get("medicare_elig_age").c_str()), scenario->StartYr(), scenario->EndYr())));
	}	

	for(std::vector<GlobalVariable*>::const_iterator itr = scenario_variables.begin(); itr < scenario_variables.end(); itr++) {
		GlobalVariable* var = *itr;
		if(scenario->contains(var->name())) 
			var->setVal(atof(scenario->get(var->name()).c_str()));
	}
	
	nested = var_manager.get("nested")->value();

	setModels();
}

/** This method executes one Monte-Carlo repetition of a particular scenario.

\todo Does it make any sense to keep running in time if everyone is dead? perhaps make that a flag in the stop year
*/
void FEM::runRep(Scenario* scenario, Random* random, unsigned int rep) {
	std::ostringstream ss;
	std::vector<Module*>::iterator it;
	std::ostringstream rep_subdir;
	rep_subdir.str("");
	std::ostringstream rep_subdir2;
	rep_subdir2.str("");
		
	/* Get model parameter bootstrap draws, if needed */	
	if (bootstrapParams == external) {
		model_manager.clearModels();
		loadRepModels(scenario, rep);
		/** \todo Describe newly loaded models */
		setModels();
	}
	
	/* Read in persons */
	Logger::log(" Reading base cohort", FINE);
	if(bootstrapInput == true)
		rep_subdir << "input_rep" << ceil((rep+1)/(double)nested) << _PATH_DELIM_;
	if(bootstrapNew51 == true)
		rep_subdir2 << "input_rep" << ceil((rep+1)/(double)nested) << _PATH_DELIM_;
	if(settings.get("use_restricted") == "yes")
		ss << settings.get("restricted_input_data_dir") << _PATH_DELIM_ << rep_subdir.str()<< scenario->BaseCohortName() << ".dta";
	else
		ss << settings.get("base_dir") << _PATH_DELIM_ << settings.get("input_data_dir") << _PATH_DELIM_ << rep_subdir.str()<< scenario->BaseCohortName() << ".dta";
	Logger::log(std::string(" source: " ) + ss.str(), FINE);
	PersonVector persons;
	persons.readStata(ss.str().c_str());
	persons.sortByID();
	ss.str("");

	global_preinit_module->process(persons, scenario->StartYr(), random);
	hrs_init_module->process(persons, scenario->StartYr(), random);
	psid_init_module->process(persons, scenario->StartYr(), random);
	global_postinit_module->process(persons, scenario->StartYr(), random);
	init_interventions_module->process(persons, scenario->StartYr(), random);

	if(scenario->SimuType()==3) {
	  ss << settings.get("base_dir") << _PATH_DELIM_ << "input_data" << _PATH_DELIM_ << rep_subdir2.str() << "new51s_" << scenario->NewCohortModel() << ".dta";
	  std::string new_cohort_file = ss.str();
	  ss.str("");
	  
	  ss << "Adding new cohort [" << new_cohort_file << "]";
	  Logger::log(ss.str(), FINER);
	  ss.str("");
	  
	  persons.readStata(new_cohort_file.c_str());
	}
	
	if(scenario->SimuType()==4) {
	  ss << settings.get("base_dir") << _PATH_DELIM_ << "input_data" << _PATH_DELIM_ << rep_subdir2.str() << "new25s_" << scenario->NewCohortModel() << ".dta";
	  std::string new_cohort_file = ss.str();
	  ss.str("");
	  
	  ss << "Adding new cohort [" << new_cohort_file << "]";
	  Logger::log(ss.str(), FINER);
	  ss.str("");
	  
	  persons.readStata(new_cohort_file.c_str());
	}
	
	if(scenario->SimuType()==5) {
	  ss << settings.get("base_dir") << _PATH_DELIM_ << "input_data" << _PATH_DELIM_ << rep_subdir2.str() << scenario->NewCohortModel() << ".dta";
	  std::string new_cohort_file = ss.str();
	  ss.str("");
	  
	  ss << "Adding new cohort [" << new_cohort_file << "]";
	  Logger::log(ss.str(), FINER);
	  ss.str("");
	  
	  persons.readStata(new_cohort_file.c_str());
	}

	ss << " Read in " << persons.size() << " persons";
	Logger::log(ss.str().c_str(), FINER);
	ss.str("");

	for (unsigned int yr = scenario->StartYr(); yr <= scenario->EndYr(); yr += scenario->YrStep()) {
		ss << "Starting simulation for year " << yr;
		Logger::log(ss.str(), yr % 20 == 0 || yr == scenario->StartYr() || yr == scenario->EndYr() ? FINE : FINE);
		ss.str("");
		try {
			yearStartHook(scenario, random, yr);
			if (yr > scenario->StartYr()) {
				var_calc_module->process(persons, yr, random);

				// Run the module to determine health trends
				// These are all longitudinal models, meaning state at time T depends on factors in T - 1
				health_module->process(persons, yr, random);
				
				// Run the education module - currently only for PSID
				// educ_module->process(persons, yr, random);

				// Run any interventions on these health trends
				interventions_module->process(persons, yr, random);

				// Run the earning and wealth module. These are also longitudinal.
				//earnings_module->process(persons, yr, random);

				// Run the immigration module to adjust weights to reflect immigration trends.
				immig_module->process(persons, yr, random);

				/* Add new cohorts */
				if(yr <= scenario->StopYr() && (scenario->SimuType() == 3 || scenario->SimuType() == 4 || scenario->SimuType() == 5 )) {
				  
					global_preinit_module->process(persons, yr, random);
					hrs_init_module->process(persons, yr, random);
					psid_init_module->process(persons, yr, random);
					global_postinit_module->process(persons, yr, random);
					init_interventions_module->process(persons, yr, random);
				}
				
			}

			// Apply cross sectional models and other adjustments, such as reasignment of marital status
			// for people with newly dead spouses
			crosssec_module->process(persons, yr, random);
	

			// Calculate economic outcomes
			if(scenario->get("hrs_data")=="1")
				econ_gen_module->process(persons, yr, random);

			// Calculate government expenditures and revenues, such OASDI and taxes
			if(scenario->get("hrs_data")=="1")
				gov_exp_module->process(persons, yr, random);

			// Calculate Medical Costs
			//med_costs_module->process(persons, yr, random);
			
			// Calculate summary measures
			summary_module->process(persons, yr, random);

			// Write detailed output, if requested.
			if(scenario->DoDetailedOutput())
				output_modules->process(persons, yr, random);

			// Update lagged variables
			lag_module->process(persons, yr, random);

			// Hook to perform any end of year calculations required by subclasses
			yearEndHook(scenario, random, yr);
		} catch (fem_exception e) {
			Logger::log(std::string("Error: ") + e.what(), ERROR);
			throw(e);
		}
	}
	persons.checkIDs();
	persons.clear();
	interventions_module->reset_intervetions();
}




void FEM::yearEndHook(Scenario* scenario, Random* random, unsigned int year) {
  interventions_module->yearEndHook(scenario, random, year);
}
