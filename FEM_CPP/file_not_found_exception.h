#pragma once
#include <exception>

class file_not_found_exception : public fem_exception
{
protected:
  // Description: Filename tried to open
  std::string filename;
public:
  // Description: Initializes the message.
  //
  // Arguments:
  //   message: Message for this exception.
	//   filename: the file that cannot be opened
	file_not_found_exception( const std::string& message, const std::string& fname ) : fem_exception(message),
    filename(fname) { }
   // Description: Initializes the message.
  //
  // Arguments:
  //   message: Message for this exception.
  //   filename: the file that cannot be opened
  file_not_found_exception( const char* message, const char* fname ) : fem_exception(message),
    filename(fname) { }


   // Description: Initializes the message.
  //
  // Arguments:
  //   filename: the file that cannot be opened
	file_not_found_exception( const std::string& fname ) : fem_exception("Could not open file" + fname),
    filename(fname) { }
   // Description: Initializes the message.
  //
  // Arguments:
  //   filename: the file that cannot be opened
	  file_not_found_exception( const char* fname ) : fem_exception("Could not open file" + std::string(fname)),
    filename(fname) { }

  // Description: Destructor.
  ~file_not_found_exception()  throw()  { }
  // Description: Returns description of this exception.
  //
  // Returns: Description of this exception.
  virtual const char *what() const throw() { std::string s = theMessage + ", " + filename; return s.c_str(); }
};
