#pragma once
#include <map>
#include "Person.h"
#include "PersonVector.h"
#include "Scenario.h" 
#include "Random.h"
#include "Model.h"
#include "TimeSeries.h"
#include "Variable.h"

#include <set>

class Intervention
{
public:
  Intervention(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~Intervention(void) {}

	/** Resets the intervention when a simulation is finished, clearing out any state information */
	virtual void reset();
	
	/** Apply the intervention to persons for the year 
		\param[in,out] persons The persons to apply the intervention to
		\param[in] year The year the intervention is being applied
		\param[in] random The Random number provider 
	*/
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random)= 0;

	/** Hook called prior to running any interventions.
		If more than one intervention has been specified, this hook allows the intervention
		to gather any state information before other interventions destroy that state information.
		By default, does nothing.
		\param[in,out] persons The persons in the simulation
		\param[in] year The year the intervention is being applied
		\param[in] random The Random number provider 
	*/
	virtual void preIntervetion(PersonVector& persons, unsigned int year, Random* random) {}

	/** Hook called after running all interventions.
		Allows the intervention to access and save any information about persons, after all 
		interventions have been run.
		By default, does nothing.
		\param[in,out] persons The persons
		\param[in] year The year the intervention is being applied
		\param[in] random The Random number provider 
	*/
	virtual void postIntervetion(PersonVector& persons, unsigned int year, Random* random) {}

	virtual void describe(std::ostream& strm) const;
	virtual std::string name() const = 0;
	virtual void setScenario(Scenario* scen);
	virtual void setModelProvider(IModelProvider* modp) {mp = modp; }

	virtual void yearEndHook(Scenario* scenario, Random* random, unsigned int year);

protected: 
	std::map<std::string, std::string> params_map;
	unsigned int intervention_id;

	ITimeSeriesProvider* tp; ///< time series provider for the interventions that require it
	IVariableProvider* vp; ///< variable provider for the interventions that require it
	IModelProvider* mp; ///< model provider for the interventions that require it

	void mark_eligible(Person* p); ///< Use to mark a Person as eligible for an intervention
	void mark_treated(Person* p); ///< Use to mark a Person as having been treated with an intervention this time step
	inline bool was_ever_eligible( Person* p) const {return ever_elig.count(p) > 0;} ///< Test whether someone was ever eligible for this intervention
	inline bool was_eligible_last( Person* p) const {return last_elig.count(p) > 0;} ///< Test whether someone was eligible for this intervention in the last timestep only
	inline bool was_ever_treated( Person* p) const {return ever_treated.count(p) > 0;} ///< Test whether someone was ever treated with this intervention
	inline bool was_treated_last( Person* p) const {return last_treated.count(p) > 0;} ///< Test whether someone was treated with this intervention in the last timestep

	std::set<Person*> ever_elig; ///< Set of persons ever eligible for this intervention
	std::set<Person*> last_elig; ///< Set of persons eligible last timestep
	std::set<Person*> curr_elig; ///< Set of persons currently eligible
	std::set<Person*> ever_treated; ///< Set of persons ever treated with this intervention
	std::set<Person*> last_treated; ///< Set of persons treated last timestep
	std::set<Person*> curr_treated; ///< Set of persons treated this timestep
};
