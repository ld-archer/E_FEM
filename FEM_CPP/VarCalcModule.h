#pragma once
#include "Module.h"

/** The VarCalc Module calculates derived values such as age splines based
    on the value of other variabes. It implements Module interface.
*/
class VarCalcModule :
	public Module
{
public:
  /** Creates a new, default VarCalc Module.
      This constructor does not do anything.
  */
  VarCalcModule(void);

  /** Destructor for the VarCalc Module.
      This destructor does not do anything since this module does not store any information.
  */
  virtual ~VarCalcModule(void);

  /** The module's main process method, run every year step. Calculates the derived variables based on
      either the person values or the person values.
      @param[in, out] persons The vector of persons to process
      @param[in] year The current year
      @param[in] random The random number generator to use (if necessary)
  */
  virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Variable Calculation Module";}
	virtual void setModelProvider(IModelProvider* mp) {}
};
