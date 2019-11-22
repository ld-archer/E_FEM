#pragma once
#include "Intervention.h"
#include "Variable.h"

class WorkTillMedicareIntervention :
	public Intervention
{
public:
  WorkTillMedicareIntervention(unsigned int intervention_id, ITimeSeriesProvider* tp, IVariableProvider* vp);
	virtual ~WorkTillMedicareIntervention(void);
	virtual void intervene(PersonVector& persons, unsigned int year, Random* random);
	virtual void setScenario(Scenario* scen);

	virtual inline std::string name() const {return "WorkTillMedicare";}
	

protected:
	IVariable* medicare_elig_var;
};
