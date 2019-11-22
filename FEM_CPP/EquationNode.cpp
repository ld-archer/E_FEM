#include "EquationNode.h"
#include <sstream>
#include "utility.h"
#include "fem_exception.h"
#include <cstdlib>



LookupNode::LookupNode(Lookup* lkup, unsigned int p)        {
	nReq = lkup->getNParams();;
	preced = p;
	lookup = lkup;
	nInputs = 0;
}



LookupNode::~LookupNode()
{
	for(unsigned int i = 0; i < nInputs; i++)
		delete inputs[i];
	delete lookup;
}


std::string LookupNode::getName() const {
	std::string name = lookup->getName();
	if (Complete())       {
		name += "(" + inputs[0]->getName();
		if (nReq > 1)                    
			for(unsigned int i = 1; i < nInputs; i++)
				name += "," + inputs[i]->getName();
		name += ")";
	}
	return name;
}

double LookupNode::value(const Person* person) const
{
  return lookup->lookup(inputs, nInputs, person);
}

LookupNode::LookupNode(const LookupNode &source)
{
	this->preced = source.preced;
	this->nReq = source.nReq;
	this->lookup = source.lookup->clone();
	this->nInputs = source.nInputs;
	for(unsigned int i = 0; i < nInputs; i++)
		this->inputs[i] = source.inputs[i]->clone();
}

std::string NumberNode::getName() const { 
	std::stringstream ss;
	ss << num;
	return ss.str();
}

OpNode::OpNode(std::string opc, unsigned int p, lookupFunction_2param op)        {
	opCode = opc;
	preced = p;
	nReq = 2;
	myOp = op;
	nInputs = 0;
}

OpNode::OpNode(const OpNode &source)
{
	this->preced = source.preced;
	this->nReq = source.nReq;
	this->opCode = source.opCode;
	this->myOp = source.myOp;
	this->nInputs = source.nInputs;
	for(unsigned int i = 0; i < nInputs; i++)
		this->nodes[i] = source.nodes[i]->clone();
}


OpNode::~OpNode()
{
	for(unsigned int i = 0; i < nInputs; i++)
		delete nodes[i];
}
std::string OpNode::getName() const {
	std::string name = opCode;
	if (Complete())             {
		if (nReq == 1)
			name = name + "(" + nodes[0]->getName() + ")";
		else if (nReq == 2)                    {
			std::string n1name = nodes[0]->getName();
			if (nodes[0]->getPrecedence() <= this->getPrecedence())
				n1name = "(" + n1name + ")";
			std::string n2name = nodes[1]->getName();
			if (nodes[1]->getPrecedence() <= this->getPrecedence())
				n2name = "(" + n2name + ")";
			return n1name + name + n2name;
		}
	}
	return name;
}

NodeBuilder::NodeBuilder()	{
	availableOps.push_back(new OpNode("+", 3, add_op));
	availableOps.push_back(new OpNode("-", 3, minus_op)); 
	availableOps.push_back(new OpNode("*", 4, mult_op));
	availableOps.push_back(new OpNode("/", 4, divide_op));
	availableOps.push_back(new OpNode("^", 5, pow_op));
	availableOps.push_back(new OpNode("<", 2, lt_op));
	availableOps.push_back(new OpNode(">", 2, gt_op));
	availableOps.push_back(new OpNode("<=", 2, le_op));
	availableOps.push_back(new OpNode(">=", 2, ge_op));
	availableOps.push_back(new OpNode("==", 2, eq_op));
	availableOps.push_back(new OpNode("!=", 2, ne_op));
	availableOps.push_back(new OpNode("&", 1, and_op));
	availableOps.push_back(new OpNode("|", 1, or_op));

	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("floor", floor)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("log", log)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("sin", sin)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("cos", cos)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("log", log)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("exp", exp)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("not", not_op)));
	availableLookups.push_back(new LookupNode(new BasicTwoParamLookup("min", min)));
	availableLookups.push_back(new LookupNode(new BasicTwoParamLookup("max", max)));
	availableLookups.push_back(new LookupNode(new BasicOneParamLookup("arcsinh", arcsinh)));
	availableLookups.push_back(new LookupNode(new IfThenElseLookup("if")));
	availableLookups.push_back(new LookupNode(new InRangeLookup("inrange")));
}


NodeBuilder::~NodeBuilder()
{
	for(unsigned int i = 0; i < availableLookups.size(); i++)
		delete availableLookups[i];
	for(unsigned int i = 0; i < availableOps.size(); i++)
		delete availableOps[i];
	std::map<std::string, INode*>::iterator itr;
	for(itr = terminalNodes.begin(); itr != terminalNodes.end(); ++itr)
		delete ((*itr).second);
}


bool NodeBuilder::containsLookup(std::string name) const {
	std::vector<LookupNode*>::const_iterator itr;
	for(itr = availableLookups.begin(); itr != availableLookups.end(); ++itr)
		if ((*itr)->getName() == name)
			return true;
	return false;
}

LookupNode* NodeBuilder::buildLookupNode(std::string name)	{
	std::vector<LookupNode*>::const_iterator itr;
	for(itr = availableLookups.begin(); itr != availableLookups.end(); ++itr)
		if ((*itr)->getName() == name)
			return (*itr)->clone();
	throw fem_exception(std::string("Invalid lookup name: " + name).c_str());
}

void NodeBuilder::addLookup(LookupNode* l) {
	// If the lookup already exists, make sure to remove it first
	std::vector<LookupNode*>::iterator itr;
	for(itr = availableLookups.begin(); itr != availableLookups.end(); ++itr)
		if ((*itr)->getName() == l->getName())
			availableLookups.erase(itr);
	availableLookups.push_back(l);	
}

bool NodeBuilder::containsOp(std::string name) const {
	std::vector<OpNode*>::const_iterator itr;
	for(itr = availableOps.begin(); itr != availableOps.end(); ++itr)
		if ((*itr)->OpCode() == name)
			return true;
	return false;
}

OpNode* NodeBuilder::buildOpNode(std::string name)	{
	std::vector<OpNode*>::iterator itr;
	for(itr = availableOps.begin(); itr != availableOps.end(); ++itr)
		if ((*itr)->OpCode() == name)
			return (OpNode*)(*itr)->clone();
	throw fem_exception(std::string("Invalid operation name: " + name).c_str());
}

std::vector<std::string> NodeBuilder::getOps()	{
	std::vector<std::string> ops;
	std::vector<OpNode*>::iterator itr;
	for(itr = availableOps.begin(); itr != availableOps.end(); ++itr)
		ops.push_back((*itr)->OpCode());
	return ops;
}

std::vector<std::string> NodeBuilder::getLookups()
{
	std::vector<std::string> lookups;
	std::vector<LookupNode*>::iterator itr;
	for(itr = availableLookups.begin(); itr != availableLookups.end(); ++itr)
		lookups.push_back((*itr)->getName());
	return lookups;
}

bool NodeBuilder::containsTerminalNode(std::string name) const {
	if(terminalNodes.count(name))
		return true;
	else  {
		std::stringstream ss(name);
		double d;
		ss >> d;
		return !(ss.fail()) && ss.eof();
	} 
}

INode* NodeBuilder::buildTerminalNode(std::string name)	{
	if(!containsTerminalNode(name))
		throw fem_exception(std::string("Bad terminal node: " + name).c_str());

	
	if(terminalNodes.count(name))
		return terminalNodes[name]->clone();
	else  
		return new NumberNode(atof(name.c_str()));
}

std::vector<std::string> NodeBuilder::getTerminalNodes()
{
	std::vector<std::string> nodes;
	std::map<std::string, INode*>::iterator itr;
	for(itr = terminalNodes.begin(); itr != terminalNodes.end(); ++itr)
		nodes.push_back((*itr).first);
	return nodes;
}

void NodeBuilder::addTerminalNode(INode* n) {
	if(terminalNodes.count(n->getName()))
		terminalNodes.erase(n->getName());
	terminalNodes[n->getName()] =  n;	
}
