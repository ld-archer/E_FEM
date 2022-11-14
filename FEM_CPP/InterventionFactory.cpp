#include "InterventionFactory.h"
#include "InitVarDelta.h"
#include "VarProbIntervention.h"
#include "OrderedVarMultIntervention.h"
#include "DelayIntervention.h"
#include "CureIntervention.h"
#include "WorkTillMedicareIntervention.h"
#include "BariatricSurg.h"
#include "WeightLossPill.h"
#include "SmokeStopIntervention.h"
#include "ModExIncrease.h"
#include "ReduceBMI.h"

InterventionFactory::InterventionFactory(IVariableProvider* vp, ITimeSeriesProvider* tp)
{
	unsigned int index = Vars::NVars;

	Vars::Vars_t init_vars[] = {
		Vars::cancre,
		Vars::diabe,
		Vars::hibpe,
		Vars::hearta,
		Vars::hearte,
		Vars::lunge,
		Vars::stroke,
		Vars::dbclaim,
		Vars::ssclaim,
		Vars::nhmliv,
		Vars::diclaim,
		Vars::ssiclaim,
		Vars::anyhi,
		Vars::work,
		Vars::wlth_nonzero,
		Vars::smoken,
		Vars::smokev,
		Vars::iadl1,
		Vars::iadl2p,
		Vars::adl1,
		Vars::adl2,
		Vars::adl3p,
		Vars::hsless,
		Vars::college,
		Vars::memrye,
		Vars::alzhmr,
		Vars::drink,
	};

	int nInitVars = sizeof(init_vars)/sizeof(Vars::Vars_t);
	Intervention* inter = NULL;
	for(int i = 0; i < nInitVars; i++) {
	  inter = new InitVarDelta(init_vars[i], index++, true, tp, vp);
		interventions[inter->name()] = inter;
		inter = new InitVarDelta(init_vars[i], index++, false, tp, vp);
		interventions[inter->name()] = inter;
	}

	Vars::Vars_t vars[] = {
		Vars::cancre,
		Vars::diabe,
		Vars::hibpe,
		Vars::hearte,
		Vars::hearta,
		Vars::lunge,
		Vars::nhmliv,
		Vars::stroke,
		Vars::died,
		Vars::alzhmr,
		Vars::memrye,
		Vars::work,
		Vars::ssclaim,
		Vars::smoken,
		Vars::smokev,
		Vars::drink,
		Vars::smoke_start,
		Vars::smoke_stop,
	};


	int nVars = sizeof(vars)/sizeof(Vars::Vars_t);

	for(int i = 0; i < nVars; i++) {

		// Create probability adjusting interventions
	  inter = new VarProbIntervention(vars[i], index++, tp, vp);
		interventions[inter->name()] = inter;

		// Create delay creating interventions
		inter = new DelayIntervention(vars[i], index++, tp, vp);
		interventions[inter->name()] = inter;

		// Create cure interventions
		inter = new CureIntervention(vars[i], index++, tp, vp);
		interventions[inter->name()] = inter;

	}

	interventions[inter->name()] = inter;

	Vars::Vars_t ordvars[] = {
		Vars::painstat,
		Vars::exstat
	};

	int nOrdVars = sizeof(ordvars)/sizeof(Vars::Vars_t);

	for(int i = 0; i < nOrdVars; i++) {
		// Create multiplier interventions
	  inter = new OrderedVarMultIntervention(ordvars[i], index++, tp, vp);
		interventions[inter->name()] = inter;
	}

	WorkTillMedicareIntervention* wtmi = new WorkTillMedicareIntervention(index++, tp, vp);
	interventions[wtmi->name()] = wtmi;

	BariatricSurg* bs = new BariatricSurg(index++, tp, vp);
	interventions[bs->name()] = bs;

	WeightLossPill* wlp = new WeightLossPill(index++, tp, vp);
	interventions[wlp->name()] = wlp;

	SmokeStopIntervention* ssi = new SmokeStopIntervention(index++, tp, vp);
	interventions[ssi->name()] = ssi;

	ReduceBMI* rbmi = new ReduceBMI(index++, tp, vp);
	interventions[rbmi->name()] = rbmi;



}

InterventionFactory::~InterventionFactory(void)
{
	std::map<std::string, Intervention*>::iterator mit;
	for(mit = interventions.begin(); mit != interventions.end(); mit++)
		delete mit->second;
}


Intervention* InterventionFactory::getIntervention(std::string name) {
	if(interventions.count(name) > 0)
		return interventions[name];
	else
		return NULL;
}



void InterventionFactory::setModelProvider(IModelProvider* mp) {
	std::map<std::string, Intervention*>::iterator mit;
	for(mit = interventions.begin(); mit != interventions.end(); mit++)
		mit->second->setModelProvider(mp);
}
