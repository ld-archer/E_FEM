#pragma once

#include <vector>
#include <string>
#include <map>

class Scenario
{
public:
 Scenario(void) : yrstep(2) {}
	Scenario(Scenario& source);
	~Scenario(void);

	std::string describe();

	std::string Name() { return scenario_name;}
	std::string OutputDir() {return output_dir;}
	std::string BaseCohortName() {return base_cohort_name;}
	std::string NewCohortModel() {return new_cohort_model;}
	int SimuType() {return simutype;}
    unsigned int StartYr() {return startyr;}
    unsigned int StopYr() {return stpyr;}
    unsigned int EndYr() {return endyr;}
    unsigned int YrStep() {       return yrstep;    }
	unsigned long int NReps() {return nreps;}
	bool DoDetailedOutput() {return do_detailed_output;}
	

	
	void Name(std::string x) { scenario_name= x;}
	void OutputDir(std::string x) {output_dir= x;}
	void BaseCohortName(std::string x) {base_cohort_name= x;}
	void NewCohortModel(std::string x) {new_cohort_model= x;}
	void SimuType(int x) {simutype= x;}
    void StartYr(unsigned int x) {startyr= x;}
    void StopYr(unsigned int x) {stpyr= x;}
    void EndYr(unsigned int x) {endyr= x;}
    void YrStep(unsigned int x) {yrstep = x;}
	void NReps(unsigned int x) {nreps= x;}
	void DoDetailedOutput(bool x) {do_detailed_output = x;}
	

	std::string get(const std::string& name);
	bool contains(const std::string& name) {return params.count(name) != 0; }
	inline void set(std::string name, std::string val) {params[name] = val;}

protected:
	std::map<std::string, std::string> params;

    std::string scenario_name;
    std::string output_dir;
    int simutype;
    std::string base_cohort_name;
    std::string new_cohort_model;
    unsigned int startyr;
    unsigned int stpyr;
    unsigned int endyr;
    unsigned long int nreps;
	bool do_detailed_output;
	unsigned int yrstep;
    int medicare_elig_age;
	std::vector<std::string> init_interventions_str;
	std::vector<std::string> interventions_str;
    bool use_obese_baseline;
    std::string obese_baseline;

};


