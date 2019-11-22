#pragma once
#include "Intervention.h"
#include "Module.h"
#include "Person.h"
#include "InterventionModule.h"
#include "InitInterventionModule.h"
#include "HealthModule.h"
#include "GlobalPreInitializationModule.h"
#include "HRSInitializationModule.h"
#include "PSIDInitializationModule.h"
#include "GlobalPostInitializationModule.h"
#include "VarCalcModule.h"
#include "LagModule.h"
#include "MedCostsModule.h"
#include "EconGenModule.h"
#include "OutputModules.h"
#include "ImmigrationAdjModule.h"
#include "EarningsModule.h"
#include "GovExpModule.h"
#include "CrossSectionalModule.h"
#include "SummaryModule.h"
#include "PersonVector.h"
#include "EquationNode.h"
#include "TimeSeriesManager.h"
#include "TableManager.h"
#include "VariableManager.h"
#include "Settings.h"
#include "ModelManager.h"
#include "ProxyTimeSeries.h"
#include "GlobalVariable.h"
#include "InterventionFactory.h"
#include "RandomProvider.h"
#include "EducModule.h"
#include <vector>
#include <set>

/** \mainpage The Future Elderly Model

This is the main documentation for the Future Elderly Model. From here, you can access the simulation documentation as well as the documentation for the Stata code that generates the simulation inputs. This is also where information global to the model (like high-level todo items) will be located.

The documentation is organized as follows:
\li \subpage cpp The C++ Simulation Documentation
\li \subpage stata The Stata Data Generation Code
\li \subpage estimation The Stata Estimation Code

\section longterm Long Term ToDo list
This isn't quite a wishlist, since this stuff needs to be done, but we can keep producing results without finishing any of these items.

\todo Create a regressions tests group of scenarios and settings files. 
\li prevalence of 1+ ADLs
\li prevalence of working (under age 65)
\li Part A spending
\li Part B spending
\li total population
\li prevalence of diabetes
\li total population 50+ in 2050
\li total population 65+ in 2050
\li gov't expenditure totals in 2050 (by program)

\todo Create a list of desirable unit tests.

\todo Write the unit tests.

\todo Create an extreme conditions group of scenarios and settings files
\li zero mortality
\li total mortality
\li zero incidence of disease
\li no monetary growth of any kind
\li minimalistic models

\todo Use Hudson to auto-build after each commit

\todo Use Hudson to run tests after each commit
\li unit tests
\li regression tests
\li extreme values tests
\li valgrind

\todo Consider rewriting the classes to be more agent-oriented

\todo parallelize MPI over scenario/rep combos instead of waiting for one scenario to finish

\todo use inflation vectors to report all financial outcomes in constant dollars for a given base year

\todo add a flag to the settings file that will turn on/off the copying of all settings to the output directory

\todo add another obesity category for BMI > 35
*/

/** \page cpp The C++ Simulation

This is where the predictions are actually made. The best place to start is with the FEM class.
*/

/** \page stata The Stata Data Generation Code

We use Stata to do lots of the data generation.
*/

/** \page estimation The Stata Estimation Code

We use Stata to create all of the estimation models that are then executed in the \ref cpp "C++ simulation".
*/

/** This is the main workhorse class for the Future Elderly Model. This is where scenarios are loaded, setup, and repetitions run. This is where every instantiation of Module gets stored as well as any global variables you want hanging around.
*/
class FEM
{
public:
	FEM(Settings& s);
	virtual ~FEM(void);

	/** This method runs an entire scenario, including all the Monte-Carlo repetitions.

	    \todo Implement a standard-deviation measure to automatically determine when we can stop running additional reps. The scenario would then contain the parameters for this determination (variable to track and completion threshold) rather than a hard number.
	*/
	virtual void runScenario(Scenario* scenario, RandomProvider* rnd_provider) = 0;
	virtual void prepScenario(Scenario* scenario);
	virtual void runRep(Scenario* scenario, Random* random, unsigned int rep);

protected:
	/* Hooks */
	virtual void yearStartHook(Scenario* scenario, Random* random, unsigned int year) {}
	virtual void yearEndHook(Scenario* scenario, Random* random, unsigned int year);
	void loadSettings(std::string settings_path, bool specific_settings);
	void describeSettings();
	virtual void loadModels(std::string models_dir, bool specific_settings);
	virtual void loadRepModels(Scenario* scenario, unsigned int rep);
	virtual void setModels();
	

	HealthModule* health_module;
	CrossSectionalModule* crosssec_module;
	InterventionModule* interventions_module;
	InitInterventionModule* init_interventions_module;
	GlobalPreInitializationModule* global_preinit_module;
	HRSInitializationModule* hrs_init_module;
	PSIDInitializationModule* psid_init_module;
	GlobalPostInitializationModule* global_postinit_module;
	VarCalcModule* var_calc_module;
	LagModule* lag_module;
	OutputModules* output_modules;
	MedCostsModule* med_costs_module;
	EconGenModule* econ_gen_module;
	ImmigrationAdjModule* immig_module;
	EarningsModule* earnings_module;
	SummaryModule* summary_module;
	GovExpModule* gov_exp_module;
	NodeBuilder builder;
	VariableManager var_manager;
	std::vector<Module*> modules;
	TimeSeriesManager ts_manager;
	TableManager table_manager;
	ModelManager model_manager;
	Settings settings;
	EducModule* educ_module;
	
	InterventionFactory* interv_fac;

	/** Variable for holding the Medicare eligibility age at each year */
	ProxyTimeSeries* medicare_elig_age;

	/** Variables that are set in the scenario specification */ 
	std::vector<GlobalVariable*> scenario_variables;

	/** Variable for holding the Medicare Part B elasticity to premium */
	GlobalVariable* mcare_ptb_prm_elas;

	/** Variable for holding the Medicare Part B elasticity to coinsurance */
	GlobalVariable* mcare_ptb_coin_elas;

	/** Variable for holding the % change in Medicare Part B co-insurance */
	GlobalVariable* mcare_ptb_coin_chg;
	
	/** Variable for holding the method used for model parameter bootstrap draws */
	enum pbootstype {external, none} bootstrapParams;
	
	/** Variable for setting whether or not to use external draws of input data */	
	bool bootstrapInput;

	/** Variable for setting whether or not to use external draws of new 51 cohort data */	
	bool bootstrapNew51;
	
	unsigned int nested;
		
	/** List of survival model types -- required for setting time step values in models */
	std::set<std::string> survival_type_names;

};
