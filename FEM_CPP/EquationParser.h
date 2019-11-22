#pragma once
#include <string>
#include <vector>
#include <queue>
#include "EquationNode.h"

/** This class handles the parsing of equations in summary files and vars files.

    \bug Does not check for balanced parentheses
*/
class EquationParser
{
public:
	static std::vector<std::string> getUnknownTokens(std::string equation, NodeBuilder* builder);
	static INode* parseString(std::string equation, NodeBuilder* builder);

	

private:
	static INode* parse(std::queue<std::string>& tokens, NodeBuilder* builder);
};
