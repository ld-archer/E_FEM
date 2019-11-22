#pragma once
#include "GlobalVariable.h"
#include "Module.h"
#include "Model.h"
#include "SummaryMeasure.h"
#include <vector>
#include <map>

///!\todo Make name of mortality model a parameter somewhere.

class HealthModule :
	public Module
{
public:
	HealthModule(IVariableProvider* vp, ITimeSeriesProvider *tsp, NodeBuilder *builder, ITableProvider *tabp);
	virtual ~HealthModule(void);

	/** The process method executes all the health transition models.
	    In particular, the process method always executes the died model for mortality. This model requires
	    a table named mortaliy_adj.txt. The default table includes adjustments to mortality from the SSA.
	    If you don't want any mortality adjustments, use the mortality_adj_none settings directory.
	    
	    Individiuals are currently limited to a maximum age of 120 years.
	*/
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Health Module";}
	virtual void setModelProvider(IModelProvider* modp);
	virtual void setScenario(Scenario* scen);
	
protected:
	void loadModels();
	void mortalityAdj(Person* person, unsigned int year, Random* random) const;
	void do_marriage(Person* person, Random* random);
	IModelProvider* mp;
  IModel* cogstate_stock; /* applied here to get cogstate at age 65-66 for simulated cohort (more notes below)*/
	std::map<std::string, std::vector<Vars::Vars_t>*> var_categories;
	std::map<Vars::Vars_t, IModel*> models;
    std::vector<Vars::Vars_t> bin_hzd;
    std::vector<Vars::Vars_t> condlist;
    std::vector<Vars::Vars_t> bin_trst;
    std::vector<Vars::Vars_t> cenbin;
    std::vector<Vars::Vars_t> ordered;
    std::vector<Vars::Vars_t> continuous;
    std::vector<Vars::Vars_t> combo_set;
	
	IVariable* medicare_elig_var;
	IVariable* diclaim2yr;
	/*    runcogstk if 65-66. HRS began asking Qs regularly at age 65 (and first interview).
	      So need to run this for simulated cohort at age 65-66.  Model is called cogstate_stock
	   runcog if 67+.  This is the cogstate transition model. Model is called cogstate.
	*/
	IVariable* runcogstk_var;
	IVariable* runcog_var;
	
	ITimeSeries* nra;
	ITimeSeries* eea;
	
	// summary measure used to compute the median mortality probability
	SummaryMeasure* summ_median_pdied;
	// variable used to reference the median mortality probability
	GlobalVariable* median_pdied;
};
