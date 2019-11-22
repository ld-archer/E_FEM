#pragma once
#include "LogHandler.h"
#include <string>
#include <vector>




class Logger
{
public:
	~Logger(void) {}
	static inline void addHandler(LogHandler* handler) {Logger::get()._addHandler(handler);}
	static inline void log(std::string& msg, LogLevel level) {Logger::get()._log(msg, level);}
	static inline void log(std::string msg, LogLevel level) {Logger::get()._log(msg, level);}
	static inline void log(const char* msg, LogLevel level) {Logger::get()._log(msg, level);}
	static inline void setLogLevel(LogLevel level) {Logger::get()._setLogLevel(level);}
	static Logger& get();

protected:
	Logger(void) {log_level = INFO;}
	Logger(LogLevel level) {log_level = level;}

	inline void _addHandler(LogHandler* handler) {handlers.push_back(handler);}
	void _log(std::string& msg, LogLevel level);
	void _log(const char* msg, LogLevel level);
	inline void _setLogLevel(LogLevel level) {log_level = level;}

	std::vector<LogHandler*> handlers;
	LogLevel log_level;
	static Logger* logger;

};
