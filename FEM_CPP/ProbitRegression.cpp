#include "ProbitRegression.h"
#include "Random.h"


ProbitRegression::ProbitRegression(void)
{
	name = "probit";
}

ProbitRegression::ProbitRegression(const ProbitRegression& source) : Regression(source)
{
}


void ProbitRegression::predict(Person* person, const Random* random) const
{
	double prob = transform(calc_xb(person));
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);
	if(pvar != Vars::_NONE)
		prob = storeProb(person);

	predictWithProb(person, random, prob);	
}

double ProbitRegression::storeProb(Person* person) const {
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);

	if(pvar != Vars::_NONE) {
		double prob = transform(calc_xb(person));
		person->set(pvar, prob);
		return prob;
	} else {
		throw fem_exception("Cannot store probability of " + VarsInfo::labelOf(predicted_var));
	}
}

void ProbitRegression::predictWithProb(Person* person, const Random* random, double prob) const
{
	if(prob < 0.0 || prob > 1.0)
		throw fem_exception("Probability for simulating " + VarsInfo::labelOf(predicted_var) + " is not in [0,1]");
	
	bool roll = random->uniformDist(person->getID(), predicted_var, person->getYear()) + prob > 1;
	person->set(predicted_var, roll ? 1.0 : 0.0);
}









