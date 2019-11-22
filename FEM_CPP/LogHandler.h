#pragma once
#include <string>
#include <iostream>
#include <fstream>

enum LogLevel {
	ALL,
	FINEST,
	FINER,
	FINE,
	INFO,
	WARNING,
	ERROR
};

class LogHandler
{
public:
	LogHandler(void) {log_level = ALL;}
	LogHandler(LogLevel level) {log_level = level;}
	virtual ~LogHandler(void) {}
	virtual	void log(std::string msg, LogLevel level) = 0;
	inline virtual void log(const char* msg, LogLevel level) {log(std::string(msg), level);}

protected:
	LogLevel log_level;
};

class StreamLogHandler : public LogHandler 
{
public:
	StreamLogHandler(std::ostream& ostrm);
	StreamLogHandler(std::ostream& ostrm, LogLevel level);
	virtual ~StreamLogHandler(void);
	virtual	void log(std::string msg, LogLevel level);

protected:
	std::ostream* ostrm;
};


class FileLogHandler : public LogHandler 
{
public:
	FileLogHandler(const char* file);
	FileLogHandler(const char* file, LogLevel level);
	virtual ~FileLogHandler(void);
	virtual	void log(std::string msg, LogLevel level);

protected:
	StreamLogHandler* stream_handler;
	std::ofstream outf;
};


class FormattingLogHandler : public LogHandler 
{
public:
	FormattingLogHandler(LogHandler* logHandler);
	FormattingLogHandler(LogHandler* logHandler, LogLevel level);
	virtual ~FormattingLogHandler(void);
	virtual	void log(std::string msg, LogLevel level);

protected:
	virtual std::string format(std::string& msg, LogLevel level) = 0;
	LogHandler* logHandler;
};

class PrefixFormattingLogHandler : public FormattingLogHandler 
{
public:
	PrefixFormattingLogHandler(LogHandler* logHandler, std::string pfx) : FormattingLogHandler(logHandler), prefix(pfx) {}
	PrefixFormattingLogHandler(LogHandler* logHandler, LogLevel level, std::string pfx) : FormattingLogHandler(logHandler, level), prefix(pfx)  {}
	virtual ~PrefixFormattingLogHandler(void) {}

protected:
	virtual std::string format(std::string& msg, LogLevel level) {return prefix + msg;}
	std::string prefix;
};

class TimeFormattingLogHandler : public FormattingLogHandler 
{
public:
	TimeFormattingLogHandler(LogHandler* logHandler);
	TimeFormattingLogHandler(LogHandler* logHandler, LogLevel level);
	virtual ~TimeFormattingLogHandler(void);

protected:
	virtual std::string format(std::string& msg, LogLevel level);
};

class SeverityFormattingLogHandler : public FormattingLogHandler 
{
public:
	SeverityFormattingLogHandler(LogHandler* logHandler);
	SeverityFormattingLogHandler(LogHandler* logHandler, LogLevel level);
	virtual ~SeverityFormattingLogHandler(void);

protected:
	virtual std::string format(std::string& msg, LogLevel level);
};



