#include "SummaryMeasure.h"
#include "SummaryModule.h"
#include "fem_exception.h"

SummaryMeasure::SummaryMeasure(IVariable *v, INode* c, const std::string n, const std::string d, double s, INode* w, const std::string summary_type) :
	var(v), condition(c), weight(w), name(n), desc(d), scale(s)
{
	if(summary_type == "sum")
		accum = new AccumulatorSum();
	else if(summary_type == "mean")
		accum = new AccumulatorMean();
	else if(summary_type == "median")
		accum = new AccumulatorMedian();
	else if(summary_type == "min")
	  accum = new AccumulatorMinimum();
	else if(summary_type == "max")
	  accum = new AccumulatorMaximum();
	else if(summary_type.find("quantile") != std::string::npos) {
	  std::vector<std::string> tokens;
	  str_tokenize(summary_type, tokens, "-");
	  double f = 0.0;
	  if(tokens.size() == 2)
	    f = atof(tokens[1].c_str());
	  else throw fem_exception("Unknown summary type " + summary_type);
	  if(f < 0 || f > 1) throw fem_exception("Invalid quantile value: " + tokens[1]);
	  accum = new AccumulatorQuantile(f);
	}
	else
	  throw fem_exception("Unknown summary type " + summary_type);
}

SummaryMeasure::~SummaryMeasure(void)
{
	delete condition;
	delete accum;
}


double SummaryMeasure::calculate(PersonVector &persons) {
	Accumulator* accum_clone = accum->clone();
	std::vector<Person*>::iterator itr;

	// Check if there were persons with weight > 0 and passed the condition
	bool has_persons = false;
	for(itr = persons.begin(); itr != persons.end(); ++itr) {
		Person* person = *itr;
		if(person->test(Vars::active) && condition->value(person) == 1.0) {
			if(!has_persons)
				has_persons = weight->value(person) > 0;
			accum_clone->accum(var->value(person), weight->value(person));
		}
	}
	double val = scale*accum_clone->value();
	delete accum_clone;
	// If there were valid persons to calculate over then return the measure value. Otherwise return missing.
	return has_persons ? val : SummaryModule::MISSING_VAL;
}

