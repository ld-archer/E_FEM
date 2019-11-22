
#include "Lookup.h"
#include "fem_exception.h"
#include "EquationNode.h"

LookupPlaceHolder::LookupPlaceHolder(std::string n, unsigned int num) : nparams(num), name(n) { }

double LookupPlaceHolder::lookup(INode* const x[], unsigned int nInputs, const Person* person) const {
	throw fem_exception(std::string(std::string("Error LookupPlaceHolder ") + name + std::string(": Cannot call Lookup on placeholder!")).c_str());
}



std::string TimeSeriesLookup::getName() const
{
	if (series == NULL)
		return placeHolderName;
	return series->getName();
}


double TimeSeriesLookup::lookup(INode* const x[], unsigned int nInputs, const Person* person) const
{
	if (placeHolderName == "" && series == NULL)
		throw fem_exception("Lookup called but no timeseries set!");
	else if (series == NULL)
		throw fem_exception(std::string(std::string("TimeSeries lookup called on [") + placeHolderName + std::string("] but no series set!")).c_str());
	else if(nInputs < 1) throw fem_exception(getName() + " requires at least one input");

	return series->Value(x[0]->value(person));
}

void TimeSeriesLookup::clearTimeSeries()  {
	if (placeHolderName == "")
		throw fem_exception("Clearing TimeSeries in TimeSeries Lookup, but no place holder name set!");
	series = NULL;
}

BasicOneParamLookup::BasicOneParamLookup(std::string n, lookupFunction_1param f) : name(n), nparams(1), func(f) { }
BasicTwoParamLookup::BasicTwoParamLookup(std::string n, lookupFunction_2param f) : name(n), nparams(2), func(f) { }
IfThenElseLookup::IfThenElseLookup(std::string n) : name(n), nparams(3) { }
InRangeLookup::InRangeLookup(std::string n) : name(n), nparams(3) { }

double BasicOneParamLookup::lookup(INode* const x[], unsigned int nInputs, const Person* person) const {
  if(nInputs > 0)
    return func(x[0]->value(person));
  else
    throw fem_exception(getName() + " requires one input, but was fed none");
}

double BasicTwoParamLookup::lookup(INode* const x[], unsigned int nInputs, const Person* person) const {
  if(nInputs > 1)
    return func(x[0]->value(person),x[1]->value(person));
  else
    throw fem_exception(getName() + " requires two inputs, was given fewer");
}

double IfThenElseLookup::lookup(INode* const x[], unsigned int nInputs, const Person* person) const {
  if(nInputs > 2) {
    if(x[0]->value(person)) return x[1]->value(person);
    else return x[2]->value(person);
  } else throw fem_exception(getName() + " requires three inputs, but was given fewer");
}

double InRangeLookup::lookup(INode* const x[], unsigned int nInputs, const Person* person) const {
  if(nInputs > 2)
    return (x[1]->value(person) <= x[0]->value(person) && x[0]->value(person) <= x[2]->value(person));
  else throw fem_exception(getName() + " requires three inputs, but was given fewer");
}
