#pragma once
#include "Module.h"
#include <map>
#include "SummaryMeasure.h"
class SummaryModule :
	public Module
{
 public:
  /** This is the constructor for the SummaryModule class. It creates all the summary measure objects
      required for this run of the simulation.

      \bug If you swap the weight and the factor values in the summary output text file, 
      no errors are thrown, but no outputs are generated, either (all values zero due to
      the atof function processing the string weight for scale and coming up with zero).
  */
	SummaryModule(const char* file, NodeBuilder* builder, IVariableProvider* vp) ;
	virtual ~SummaryModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Summary Module";}
	virtual void setModelProvider(IModelProvider* mp) {};
	void scenarioFinished();
	virtual void setScenario(Scenario* scen);
	virtual inline unsigned int numMeasures() const {return measures.size();}
	virtual void output();
	virtual void outputByRep();
	void addRepData(unsigned int rep, double* data);	
	void getRepData(unsigned int rep, double* data) const;
	double getValue(unsigned int year, std::string name, Random* random) const;
	bool hasMeasure(std::string name) const {return measures.count(name) > 0;}
	SummaryMeasure* getMeasure(std::string name);
	void addMeasure(SummaryMeasure* sm);

	/** Denotes a missing value. Used when there is no persons to compute a measure over */
	static const double MISSING_VAL;
protected:
	std::map<std::string, SummaryMeasure*> measures;
	std::vector<std::map<unsigned int, std::map<std::string, double> >* > year_measure_val_vec;
	std::map<unsigned int, std::map<std::string, double> > year_measure_mean;
	unsigned short nreps;

	void prepStataDescriptors();
	void prepStataVarLabels();

	void prepStataDescriptorsByRep();
	void prepStataVarLabelsByRep();

	static const unsigned int BUF_SIZE = 5000;
	char buf[BUF_SIZE];

	static const unsigned int MAX_VARS = 4000;

	static const unsigned int MAX_DESCRIPTOR = MAX_VARS*118+2;
	char descriptor[MAX_DESCRIPTOR];

	static const unsigned int MAX_VARLABELS = MAX_VARS*81;
	char var_labels[MAX_VARLABELS];


};
