#pragma once
#include <string>
#include <vector>
#include <map>
#include "Person.h"
#include "Lookup.h"
#include <math.h>
#include "Variable.h"


class INode   {
public:
	virtual ~INode() {}
	virtual double value(const Person* person) const = 0;
	virtual unsigned int getPrecedence() const = 0;
	virtual std::string getName() const = 0;
	virtual INode* clone() const = 0;
};


class LookupNode : public INode
{
protected:
	const static unsigned int MAX_INPUTS = 10;
	Lookup* lookup;
	INode* inputs[MAX_INPUTS];
	unsigned int preced;
	unsigned int nReq;
	unsigned int nInputs;

public:
	LookupNode(Lookup* lkup, unsigned int p = 99);
	LookupNode(const LookupNode& source);
	virtual ~LookupNode();
	inline virtual LookupNode* clone() const { return new LookupNode(*this); }

	virtual std::string getName() const;
	inline virtual bool Complete() const {  return nInputs == nReq;         }
	inline virtual unsigned int getPrecedence() const { return preced; }

	virtual double value(const Person* person) const;

	inline virtual void addNode(INode* n)    {    inputs[nInputs++] = n;     }

};

class VariableNode : public INode
{
private:
	IVariable* var;

public:
	VariableNode(IVariable* v) { var = v; }
	inline virtual ~VariableNode() {}
	inline virtual double value(const Person* person) const { return var->value(person); }

	inline virtual unsigned int getPrecedence() const { return 99; }

	inline virtual std::string getName() const { return var->name();}

	inline virtual INode* clone() const { return new VariableNode(var);}
};

class NumberNode : public INode
{
protected:
	double num;

public:
	NumberNode(double n) { num = n; }

	virtual inline double value(const Person* person) const { return num; }

	virtual inline unsigned int getPrecedence() const { return 99; } 
	virtual std::string getName() const;
	inline virtual INode* clone() const { return new NumberNode(num); }
};


/* Operations */
inline double add_op(double a, double b) {return a + b;}
inline double minus_op(double a, double b) {return a - b;}
inline double mult_op(double a, double b) {return a * b;}
inline double divide_op(double a, double b) {return a / b;}
inline double pow_op(double a, double b) {return pow(a,b);}
inline double lt_op(double a, double b) {return a < b;}
inline double gt_op(double a, double b) {return a > b;}
inline double le_op(double a, double b) {return a <= b;}
inline double ge_op(double a, double b) {return a >= b;}
inline double eq_op(double a, double b) {return a == b;}
inline double ne_op(double a, double b) {return a != b;}
inline double max(double a, double b) {return std::max(a,b);}
inline double min(double a, double b) {return std::min(a,b);}
inline double not_op(double a) {return !a;}
inline double and_op(double a, double b) {return a && b;}
inline double or_op(double a, double b) {
	return a || b;
}

class OpNode : public INode
{
protected:
	lookupFunction_2param myOp;
	const static unsigned int MAX_INPUTS = 10;
	INode* nodes[MAX_INPUTS];
	std::string opCode;
	unsigned int preced;
	unsigned int nReq;
	unsigned int nInputs;

public:
	OpNode(std::string opcd, unsigned int p, lookupFunction_2param op);
	OpNode(const OpNode &source);
	virtual ~OpNode();
	inline std::string OpCode() const { return opCode; }
	inline virtual INode* clone() const  {  return new OpNode(*this); }

	std::string getName() const;

	inline virtual bool Complete() const { return nInputs == nReq; }     
	inline virtual unsigned int getPrecedence() const { return preced; }
	inline virtual double value(const Person* person) const { return myOp(nodes[0]->value(person), nodes[1]->value(person));  }
	inline virtual void addNode(INode* n)    {    nodes[nInputs++] = n;     }
};


class NodeBuilder
{
protected:
	std::vector<LookupNode*> availableLookups;
	std::vector<OpNode*> availableOps;
	std::map<std::string, INode*> terminalNodes;

public:
	NodeBuilder();
	~NodeBuilder();
	bool containsLookup(std::string name) const;

	LookupNode* buildLookupNode(std::string name);

	void addLookup(LookupNode* l); 

	bool containsOp(std::string name) const;

	OpNode* buildOpNode(std::string name);

	std::vector<std::string> getOps();

	std::vector<std::string> getLookups();

	bool containsTerminalNode(std::string name) const;

	INode* buildTerminalNode(std::string name);

	std::vector<std::string> getTerminalNodes();

	void addTerminalNode(INode* n);


};
