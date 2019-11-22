#include "missing_var_exception.h"



std::string missing_var_exception::default_msg(const std::string& vname)  {
	std::string msg("Attempted to read missing variable [");
	msg += vname;
	msg += "]";
	return msg;
}


std::string missing_var_exception::default_msg(const char* vname)  {
	std::string varname_str(vname);
	return default_msg(varname_str);
}
