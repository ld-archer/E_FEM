#include "LogitRegression.h"
#include "Random.h"


LogitRegression::LogitRegression(void)
{
		name = "logit";
}


LogitRegression::LogitRegression(const LogitRegression& source) : Regression(source)
{
}


void LogitRegression::predict(Person* person, const Random* random) const
{
  double prob = estimate(person);
	Vars::Vars_t pvar = VarsInfo::probOf(predicted_var);
	if(pvar != Vars::_NONE)
	  person->set(pvar, prob);
	predictWithProb(person, random, prob);
}
void LogitRegression::predictWithProb(Person* person, const Random* random, double prob) const {
  if(prob < 0.0 || prob > 1.0)
    throw fem_exception("Probability for simulating " + VarsInfo::labelOf(predicted_var) + " is not in [0,1]");
	
  bool roll = random->uniformDist(person->getID(), predicted_var, person->getYear()) + prob > 1;
  person->set(predicted_var, roll ? 1.0 : 0.0);
}







