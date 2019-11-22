#pragma once
#include "Module.h"
#include "Model.h"
#include "EquationNode.h"
#include "SummaryMeasure.h"
#include <map>
#include <vector>


	

/** This class does regular medical costs, Medicare and Medicaid costs, and Medicare enrollment.

\bug The Medicare premium calculations, and hence the enrollment calculations, depend on a full population
of Medicare enrollees to dynamically compute the premiums. In a cohort simulation, even without any of the
Medicar reform options enabled, Part B enrollment will likely be slightly higher than normal. Not sure
what we can do about this.
*/
class MedCostsModule :
	public Module
{
public:
	/** Initializes and Creates the Medical Costs Module.
		\param[in]  vp  The runtime variable provider used to obtain the medicare eligibility variable
		\param[in] tsp The Time Series provider used to obtain medical cost growth and cpi
		\param[in] bldr The NodeBuilder object used to build derived variables if necessary
	*/
  MedCostsModule(IVariableProvider* vp, ITimeSeriesProvider *tsp, NodeBuilder* bldr);
	virtual ~MedCostsModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Medical Costs Module";}
	virtual void setModelProvider(IModelProvider* mp);
	virtual void setScenario(Scenario* scen);

protected:
	//bool IsMedicareElig(Person* p) {return p->get(Vars::age) >= medicare_elig_age || (p->test(Vars::diclaim) && p->test(Vars::ldiclaim));}
	inline bool IsMedicareElig(Person* p) const {return medicare_elig_var->value(p) == 1.0;}
	
	/** Models for predicted costs based on the MCBS dataset */
	std::vector<IModel*> cost_models_mcbs; 

	/** Models for predicted costs based on the MEPS dataset */
	std::vector<IModel*> cost_models_meps; 
	
	/** Models for predicting hospital and doctor events based on the MCBS dataset */
	std::vector<IModel*> event_models_mcbs; 

	/** Models for predicting hospital and doctor events based on the MEPS dataset */
	std::vector<IModel*> event_models_meps; 

	/** Model for probability of enrolling into Part D. */
	IModel* mcare_ptd_enroll;

	/** Model for probability of enrolling Medicare Part A */
	IModel* mcarea_takeup_newenroll;
	IModel* mcarea_takeup_curenroll;

	/** Model for probability of enrolling Medicare Part B */
	IModel* mcareb_takeup_newenroll;
	IModel* mcareb_takeup_curenroll;

	/** Models for any Rx use and subsequent cost */
	IModel* anyrx_mcbs_model;
	IModel* anyrx_mcbs_di_model;
	IModel* anyrx_meps_model;
	IModel* rxexp_mcbs_model;
	IModel* rxexp_mcbs_di_model;
	IModel* rxexp_meps_model;

	/** Specific Cost Models */
	IModel* mcare_pta_model;
	IModel* mcare_ptb_model;
	IModel* mcare_ptd_model;

	/** Models for Medicaid eligibility */
	IModel* medicaid_elig_meps;
	IModel* medicaid_elig_mcbs;

	/** Convenience vector for holding references to all cost variables */
	std::vector<Vars::Vars_t> cost_vars;

	/** Vector of cost variables estimated using the MCBS dataset */
	std::vector<Vars::Vars_t> cost_vars_mcbs;

	/** Vector of cost variables estimated using the MEPS dataset */
	std::vector<Vars::Vars_t> cost_vars_meps;

	/** Vector of variables for medical events */
	std::vector<Vars::Vars_t> event_vars;

	/** These are the NHEA adjustment factors for medical spending */
	//@{
	IVariable *tot_meps, *tot_mcbs, *mcaid_meps, *mcaid_mcbs, *mcare_meps, *mcare_mcbs;
	//@}

	/** Variable for calculating if the person is eligible for Medicare */
	IVariable* medicare_elig_var;
	
	/** Variable for calculating what fraction of the year the person was eligible for Medicare */
	IVariable* frac_medicare_elig_var;

	/** Variable for holding the Medicare Part A elasticity to premium */
	IVariable* mcare_pta_prm_elas;

	/** Variable for holding the Medicare Part B elasticity to premium */
	IVariable* mcare_ptb_prm_elas;

	/** Variable for holding the Medicare Part B elasticity to coinsurance */
	IVariable* mcare_ptb_coin_elas;

	/** Variable for holding the % change in Medicare Part B co-insurance */
	IVariable* mcare_ptb_coin_chg;

	/** Variable for computing the share of cost Part A participants must pay */
	IVariable* mcare_pta_share;

	/** Variable for computing the share of cost Part B participants must pay */
	IVariable* mcare_ptb_share;

	/** What percentage of people drop Part A if there is a transition from zero to non-zero premium */
	IVariable* dropPartA;

	/** What percentage of people drop Part B if there is a transition from zero to non-zero premium */
	IVariable* dropPartB;

	/** A derived variable that computes the poverty level */
	IVariable* poverty_level;

	/** A variable for the notional Medicare Part A premium to use for elasticity comparisons */
	IVariable* mcare_pta_premium_baseline;

	/** A variable to hold the Medicare Premium subsidy amount, used mostly for Vouchers */
	IVariable* mcare_pta_premium_subsidy_year;
	IVariable* mcare_pta_premium_subsidy_share;

	/** A variable to hold the Medicare Premium subsidy amount, used mostly for Vouchers */
	IVariable* mcare_ptb_premium_subsidy_year;
	IVariable* mcare_ptb_premium_subsidy_share;

       	/** Time series for Real Medical Cost Growth */
	ITimeSeries* medgrowth_yearly;

	/** ACA Puts a cap on medical cost growth, somehow */
	ITimeSeries* medgrowth_max;

	/** Time series for Consumer Price Index */ 
	ITimeSeries* cpi_yearly;

	/** Time series for Real GDP Growth */
	ITimeSeries* gdp_yearly;

	/** Time series for labor market growth */
	ITimeSeries* labor;

	/** History of Medicare Part B premiums */
	ITimeSeries* mcare_ptb_history;

	/** Low-income people are exempt from Medicare premiums. This time series defines low-income as poverty level */
	ITimeSeries* premium_exemption;

	/** Inflation factor for the medicare premium subsidy, if any */
	ITimeSeries* mcare_premium_subsidy_inflation;

	/** Precomputed Medicare Part A PC cost for cohort simulations */
	ITimeSeries* mcare_pta_stock;
	/** Precomputed Medicare Part B PC cost for cohort simulations */
	ITimeSeries* mcare_ptb_stock;

	/** Refernce year for models. Used to calculate the rise in medical costs based on CPI and real Medical Cost Growth */
	unsigned int ref_year;

	/** A NodeBuilder instance to allow computation of SummaryMeasure objects on the fly */
	NodeBuilder* builder;

 private:
	// Adjustments for medical costs
	static double  tot_65p;
	static double  tot_l65;
	static double  mcaid_65p;
	static double  mcaid_l65;
	static double  mcare_65p;
	static double  mcare_l65;

	/** Compute medical cost growth between two years. This method uses CPI (cpi.yearly.txt) 
	    and a medical spending growth rate (medgrowth.yearly.txt) that is over and above
	    real growth in GDP (gdp.yearly.txt). There is also a cap on the real rate of medical spending
	    growth to deal with ACA spending caps (medgrowth.max.txt).
	    \param[in] start_year The baseline year
	    \param[in] last_year The final year of growth
	    \returns The growth factor between the two years (e.g. 1.1 means 10% growth)
	*/
	double dDeltaMedgrowth(unsigned int start_year, unsigned int last_year) const;

	/** Compute the amount of Medicare subsidy for an individual, differentiating between parts. This method
	    uses a base year that the subsidy is based on, the portion of the average cost you'd have paid in that year,
	    the variable denoting the average cost, and an inflation factor.
	    \param[in] base_year year of subsidy
	    \param[in] curr_year the year to calculate the subsidy for
	    \param[in] inflation the time series holding the yearly inflation values
	    \param[in] premium_subsidy_share the portion of the base_year cost paid as premium
	    \param[in] summ_variable the name of the variable
	    \param[in] r pointer to the FEM-wide Random object
	    \returns the dollar amount of the subsidy
	*/
	double dMedicareSubsidy(unsigned int base_year, unsigned int curr_year, ITimeSeries* inflation, double premium_subsidy_share, std::string summ_variable, Random* r) const;

};

