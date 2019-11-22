#pragma once
#include "fem_exception.h"

/** Exception thrown when the value of a variable flagged as missing is requested
*/
class missing_var_exception :
	public fem_exception
{
public:
	/** Creates a missing_var_exception with the given message and variable name */
	missing_var_exception(const std::string& message, const std::string& vname) : fem_exception(message), varname(vname) { }
	
	/** Creates a missing_var_exception with the default message for the given variable name 
		The default message is "Attempted to read missing variable [varname]"
	*/
	missing_var_exception(const std::string& vname) : fem_exception(default_msg(vname)), varname(vname) { }

	/** Creates a missing_var_exception with the given message and variable name */
	missing_var_exception(const char* message, const char* vname) : fem_exception(message), varname(vname) { }

	/** Creates a missing_var_exception with the default message for the given variable name 
		The default message is "Attempted to read missing variable [varname]"
	*/
	missing_var_exception(const char* vname) : fem_exception(default_msg(vname)), varname(vname) { }

	/** Destructor */
	virtual ~missing_var_exception(void) throw()  { }

	/** Returns the name of the missing variable */
	virtual std::string getVarname(void) {return varname;}

protected:
  /** The name of the variable with a missing value */
  std::string varname;

  /** Creates the default message from the given variable name */
  std::string default_msg(const std::string& varname);

  /** Creates the default message from the given variable name */
  std::string default_msg(const char* vname);
};
