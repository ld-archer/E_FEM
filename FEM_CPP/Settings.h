#pragma once
#include <string>
#include <map>
#include <ostream>
class Settings
{
public:
	Settings(void);
	~Settings(void);

	void readSettings(const char* file);

	std::string get(std::string name);
		
	inline void set(std::string name, std::string val) {params[name] = val;}
	void dumpSettings(std::ostream& strm);

protected:
	std::map<std::string, std::string> params;
};
