#pragma once
#include "Variable.h"
#include "EquationNode.h"

class DerivedVariable : public IVariable {
 public:
 DerivedVariable(std::string name, INode* n, std::string d = "", VarTypes::VarTypes_t typ = VarTypes::Double) 
   : node(n), var_name(name), desc(d), myType(typ) {}
  
  virtual ~DerivedVariable(void) 	{ delete node;	}
  virtual double value(const Person* person) const;
  virtual inline std::string name() const { return var_name; }
  virtual inline std::string equation() const { return node->getName(); }
  virtual inline std::string description() const { return desc == "" ? node->getName() : desc; }
  virtual inline VarTypes::VarTypes_t type() const {return myType; }
  virtual inline bool is_missing(const Person* person) const {return false;}
  
 protected:
  INode* node;
  std::string var_name;
  std::string desc;
  VarTypes::VarTypes_t myType;
};
