#pragma once
#include "AbstractOutputModule.h"

class OutputStataModule :
	public AbstractOutputModule
{
public:
	OutputStataModule(IVariableProvider *vp);
	OutputStataModule(IVariableProvider *vp, std::vector<std::string> var_names);
	virtual ~OutputStataModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Stata Output Module";}
protected:
	static char getStataTypeCode(VarTypes::VarTypes_t t);
	static size_t getStataNumBytes(VarTypes::VarTypes_t t);
	void prepStataDescriptors();
	void prepStataVarLabels();
	

	static const unsigned int BUF_SIZE = 5000;
	char buf[BUF_SIZE];

	static const unsigned int MAX_VARS = 2000;

	static const unsigned int MAX_DESCRIPTOR = MAX_VARS*118+2;
	char descriptor[MAX_DESCRIPTOR];

	static const unsigned int MAX_VARLABELS = MAX_VARS*81;
	char var_labels[MAX_VARLABELS];

};
