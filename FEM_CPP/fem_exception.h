#pragma once
#include <exception>
#include <string>

class fem_exception : public std::exception
{
protected:
  // Description: Message for this exception.
  std::string theMessage;
public:
  // Description: Initializes the message.
  //
  // Arguments:
  //   message: Message for this exception.
  fem_exception( const std::string& message ) : exception(),
    theMessage(message) { }
   // Description: Initializes the message.
  //
  // Arguments:
  //   message: Message for this exception.
  fem_exception( const char* message ) : exception(),
    theMessage(message) { }
  // Description: Destructor.
  ~fem_exception()  throw()  { }
  // Description: Returns description of this exception.
  //
  // Returns: Description of this exception.
  virtual const char *what() const throw() { return theMessage.c_str(); }
};
