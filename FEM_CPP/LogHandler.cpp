#include "LogHandler.h"
#include <time.h>

#include "fem_exception.h"

StreamLogHandler::StreamLogHandler(std::ostream& o) : ostrm(&o) { }
StreamLogHandler::StreamLogHandler(std::ostream& o, LogLevel level) : LogHandler(level), ostrm(&o) { }
StreamLogHandler::~StreamLogHandler(void) {}

void StreamLogHandler::log(std::string msg, LogLevel level) {
	if(level >= log_level)
		*ostrm << msg << std::endl;
	ostrm->flush();
}

FileLogHandler::FileLogHandler(const char* file) : outf(file) 
{
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	stream_handler = new StreamLogHandler(outf);
}

FileLogHandler::FileLogHandler(const char* file, LogLevel level) : LogHandler(level), outf(file) 
{
	if( outf.bad() || outf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	stream_handler = new StreamLogHandler(outf, level);
}

FileLogHandler::~FileLogHandler(void) {
	delete stream_handler;
	outf.close();
}

void FileLogHandler::log(std::string msg, LogLevel level) {
	if(level >= log_level)
		stream_handler->log(msg, level);
}


FormattingLogHandler::FormattingLogHandler(LogHandler* lh) : logHandler(lh) { }
FormattingLogHandler::FormattingLogHandler(LogHandler* lh, LogLevel level) : LogHandler(level), logHandler(lh) { }

FormattingLogHandler::~FormattingLogHandler(void) {
	delete logHandler;
}

void FormattingLogHandler::log(std::string msg, LogLevel level) {
	if(level >= log_level)
		logHandler->log(format(msg, level), level);
}


TimeFormattingLogHandler::TimeFormattingLogHandler(LogHandler* logHandler) : FormattingLogHandler(logHandler) {}
TimeFormattingLogHandler::TimeFormattingLogHandler(LogHandler* logHandler, LogLevel level) : FormattingLogHandler(logHandler, level) {}
TimeFormattingLogHandler::~TimeFormattingLogHandler(void) {}

std::string TimeFormattingLogHandler::format(std::string& msg, LogLevel level) {
	time_t rawtime;
	tm * ptm;
	time ( &rawtime );
	ptm = localtime  ( &rawtime );
	std::string time_str("[");

	time_str.append(asctime(ptm));
	time_str.erase(time_str.length() -1, 1);
	time_str.append("] ");
	return time_str + msg;
	
}


SeverityFormattingLogHandler::SeverityFormattingLogHandler(LogHandler* logHandler) : FormattingLogHandler(logHandler) {}
SeverityFormattingLogHandler::SeverityFormattingLogHandler(LogHandler* logHandler, LogLevel level) : FormattingLogHandler(logHandler, level) {}
SeverityFormattingLogHandler::~SeverityFormattingLogHandler(void) {}


std::string SeverityFormattingLogHandler::format(std::string& msg, LogLevel level) {
	std::string level_str = "";
	switch(level) {
		case WARNING:
			level_str = "[WARNING] ";
			break;
		case ERROR:
			level_str = "[ERROR] ";
			break;
		default:
			break;
	}
	return level_str + msg;
	
}
