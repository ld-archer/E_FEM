
#include "EquationParser.h"
#include "utility.h"
#include <stack>
#include "fem_exception.h"
std::vector<std::string> EquationParser::getUnknownTokens(std::string equation, NodeBuilder* builder) {
	std::vector<std::string> delims = builder->getOps();
	delims.push_back(" ");
	delims.push_back(")");
	delims.push_back(",");
	delims.push_back("(");

	std::vector<std::string> tokens;
	str_tokenize_keep_delim(equation, tokens, delims);
	std::vector<std::string> unknownTokens;
	for(unsigned int i = 0; i < tokens.size(); i++) {
		std::string s = tokens[i];
		if (s.length() > 0 && s != "(" && s != ")" && s != "," && s != " " && !builder->containsLookup(s) && !builder->containsOp(s) && !builder->containsTerminalNode(s))
			unknownTokens.push_back(s);
	}
	return unknownTokens;
}

INode* EquationParser::parseString(std::string equation, NodeBuilder* builder) {

	std::vector<std::string> delims = builder->getOps();
	delims.push_back(" ");
	delims.push_back(")");
	delims.push_back(",");
	delims.push_back("(");

	std::vector<std::string> tokens;
	str_tokenize_keep_delim(equation, tokens, delims);
	std::queue<std::string> tokens_queue;
	for(unsigned int i = 0; i < tokens.size(); i++)
		if(tokens[i].length() > 0 && tokens[i] != " ")
			tokens_queue.push(tokens[i]);
	INode* n  = parse(tokens_queue, builder);
	return n;
}


INode* EquationParser::parse(std::queue<std::string>& tokens, NodeBuilder* builder) {
	LookupNode* functionnode = NULL;

	INode* active = NULL;
	std::stack<OpNode*> stack;
	std::string token;
	while (!tokens.empty())
	{
		token = tokens.front();
		tokens.pop();
		if (token.length() > 0)
		{
			if (builder->containsOp(token))
			{
				OpNode* o = builder->buildOpNode(token);
				if (stack.empty())
					stack.push(o);
				else if (o->getPrecedence() > stack.top()->getPrecedence())
					stack.push(o);
				else {
					while (!stack.empty() && o->getPrecedence() <= stack.top()->getPrecedence())	{
						stack.top()->addNode(active);
						active = stack.top();
						stack.pop();
					}
					stack.push(o);
				}
			}
			else if (builder->containsLookup(token))// && tokens.Count > 0 && tokens.Peek() == "("
				functionnode = builder->buildLookupNode(token);
			else if (token == "(") {
				if (functionnode == NULL)	{
					INode* n = parse(tokens, builder);
					if (active == NULL)
						active = n;
					else
					{
						stack.top()->addNode(active);
						active = n;
					}
				} else {
					while (!functionnode->Complete())
						functionnode->addNode(parse(tokens, builder));
					if (active == NULL)		{
						active = functionnode;
						functionnode = NULL;
					} else {
						stack.top()->addNode(active);
						active = functionnode;
						functionnode = NULL;
					}
				}
			}
			else if (token == ")" || token == ",") {
				while (!stack.empty())	{
					stack.top()->addNode(active);
					active = stack.top();
					stack.pop();
				}
				return active;
			}
			else if (builder->containsTerminalNode(token)) {
				INode* a = builder->buildTerminalNode(token);
				if (active == NULL)
					active = a;
				else {
					stack.top()->addNode(active);
					active = a;
				}
			}
			else {
				throw fem_exception(std::string("Found unhandled token [" + token + "] while parsing equation!").c_str());
			}
		}
	}
	while (!stack.empty()) {
		stack.top()->addNode(active);
		active = stack.top();
		stack.pop();
	}
	return active;
}

	
