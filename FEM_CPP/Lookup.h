#pragma once
#include <string>
#include "TimeSeries.h"
#include "Person.h"

class INode;

typedef double (*lookupFunction_1param)(double);
typedef double (*lookupFunction_2param)(double, double);

class Lookup {
public:
  virtual ~Lookup() {}
	virtual unsigned int getNParams() const = 0;
	virtual std::string getName() const = 0;
	virtual double lookup(INode* const x[], unsigned int nInputs, const Person* person) const = 0;
	virtual Lookup* clone() const = 0;
};

class LookupPlaceHolder : public Lookup
{
public:
	LookupPlaceHolder(std::string name, unsigned int n);

	virtual unsigned int getNParams() const {return nparams;}
	virtual std::string getName() const {return name;}
	virtual double lookup(INode* const x[], unsigned int nInputs, const Person* person) const ;
	virtual Lookup* clone() const { return new LookupPlaceHolder(name, nparams);}


protected:
	unsigned int nparams;
	std::string name;
};

class TimeSeriesLookup : public Lookup    {
protected:
	ITimeSeries* series;
	std::string placeHolderName;
public:

	virtual unsigned int getNParams() const {return 1;}
	virtual std::string getName() const;


	virtual double lookup(INode* const x[], unsigned int nInputs, const Person* person) const;

	TimeSeriesLookup(ITimeSeries* t)   {   series = t;     }

	TimeSeriesLookup(std::string name)     {           placeHolderName = name;    series = NULL;    }
	TimeSeriesLookup(const TimeSeriesLookup& source)     {           placeHolderName = source.placeHolderName;    series = source.series;    }

	void setTimeSeries(ITimeSeries* its)        {            series = its;        }

	void clearTimeSeries()  ;
	virtual Lookup* clone() const {return new TimeSeriesLookup(*this);}
};

class BasicOneParamLookup : public Lookup
{
protected:
	std::string name;
	unsigned int nparams;
	lookupFunction_1param func;

public:
	BasicOneParamLookup(std::string name, lookupFunction_1param func);

	virtual inline unsigned int getNParams() const {return nparams;}
	virtual inline std::string getName() const {return name;}

	virtual inline double lookup(INode* const x[], unsigned int nInputs, const Person* person) const;
	virtual inline Lookup* clone() const {return new BasicOneParamLookup(name, func);}
};

class BasicTwoParamLookup : public Lookup
{
protected:
	std::string name;
	unsigned int nparams;
	lookupFunction_2param func;

public:
	BasicTwoParamLookup(std::string name, lookupFunction_2param func);

	virtual inline unsigned int getNParams() const {return nparams;}
	virtual inline std::string getName() const {return name;}

	virtual inline double lookup(INode* const x[], unsigned int nInputs, const Person* person) const;
	virtual inline Lookup* clone() const {return new BasicTwoParamLookup(name, func);}
};

class IfThenElseLookup : public Lookup
{
protected:
	std::string name;
	unsigned int nparams;

public:
	IfThenElseLookup(std::string name);

	virtual inline unsigned int getNParams() const {return nparams;}
	virtual inline std::string getName() const {return name;}

	virtual inline double lookup(INode* const x[], unsigned int nInputs, const Person* person) const;
	virtual inline Lookup* clone() const {return new IfThenElseLookup(name);}
};

/** This function replicates the Stata inrange function.

\bug Works fine in vars.txt, but causes a segfault when used in summary measure
*/
class InRangeLookup : public Lookup {
protected:
	std::string name;
	unsigned int nparams;

public:
	InRangeLookup(std::string name);

	virtual inline unsigned int getNParams() const {return nparams;}
	virtual inline std::string getName() const {return name;}

	virtual inline double lookup(INode* const x[], unsigned int nInputs, const Person* person) const;
	virtual inline Lookup* clone() const {return new InRangeLookup(name);}
};
