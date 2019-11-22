#pragma once

#include "PersonVector.h"
#include "Variable.h"
#include "EquationNode.h"
#include "Accumulator.h"
#include <string>

/** This class represents a single summary measure.
*/
class SummaryMeasure
{
public:
	SummaryMeasure(IVariable *var, INode* condition, const std::string name, const std::string desc, double scale, INode* weight, const std::string summary_type);
	virtual ~SummaryMeasure(void);
	virtual double calculate(PersonVector &persons);
	std::string getName() {return name;}
	std::string getDesc() {return desc;}

protected:
	IVariable* var;
	INode* condition;
	INode* weight;
	std::string name;
	std::string desc;
	double scale;
	Accumulator* accum;
};







/*
class SummaryMeasureSum
{
public:
	SummaryMeasureSum(IVariable *var, INode* condition, std::string &name, std::string &desc, double scale);
	virtual ~SummaryMeasureSum(void) {}
	virtual double calculate(PersonVector &persons);
};


class SummaryMeasureMean
{
public:
	SummaryMeasureSum(IVariable *var, INode* condition, std::string &name, std::string &desc, double scale, IVariable* weight);
	virtual ~SummaryMeasureSum(void) {}
	virtual double calculate(PersonVector &persons);
};

*/
