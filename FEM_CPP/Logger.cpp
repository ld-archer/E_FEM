#include "Logger.h"

Logger* Logger::logger = 0;

void Logger::_log(std::string& msg, LogLevel level) {
	if(level >= log_level)
		for(unsigned int i = 0; i < handlers.size(); i++)
			handlers[i]->log(msg, level);
}

void Logger::_log(const char* msg, LogLevel level) {
	log(std::string(msg), level);		
}

Logger& Logger::get() {
	if(logger == NULL)
		logger = new Logger();
	return *logger;
}
