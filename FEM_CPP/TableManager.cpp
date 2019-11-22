#include "TableManager.h"
#include "utility.h"
#include <fstream>
#include "fem_exception.h"

TableManager::TableManager(void)
{
	builder = NULL;
	variableProvider = NULL;
}

TableManager::~TableManager(void)
{
	for(std::map<std::string, ITable*>::iterator itr = table_map.begin(); itr != table_map.end(); ++itr)
		delete (*itr).second;

	for(std::map<std::string, ProxyTable*>::iterator itr = proxy_table_map.begin(); itr != proxy_table_map.end(); ++itr)
		delete (*itr).second;
}


ITable* TableManager::get(std::string name) {
  if(proxy_table_map.count(name) > 0)
    return proxy_table_map[name];
  else
    throw missing_var_exception("TableManager does not have entry named " + name, name);
}

ITable* TableManager::addTable(ITable* table){
	// If a table with this name already exists, then delete the existing version
	if(table_map.count(table->getName()))
		delete table_map[table->getName()];
	table_map[table->getName()] = table;
	
	// If there is not yet a proxy table with this name, then create it
	/** \todo (if needed) add a lookup node for this table to the node builder */
	if(proxy_table_map.count(table->getName()) == 0) {
		ProxyTable* p = new ProxyTable(table->getName(), table->getDescription());
		proxy_table_map[table->getName()] = p;
		// table lookup is not implemented at this time
		//if(builder != NULL)
		//	builder->addLookup(new LookupNode(new TableLookup(p)));
	}

	// Have the proxy for this table point to this new table
	proxy_table_map[table->getName()]->setTable(table);
	
	return proxy_table_map[table->getName()];
}

void TableManager::setBuilder(NodeBuilder* b) {
	builder = b;
	/* table lookup is not implemented at this time
	if(builder != NULL) {
		std::map<std::string, ProxyTable*>::iterator itr;
		for(itr = proxy_table_map.begin(); itr != proxy_table_map.end(); ++itr)
			if(!builder->containsLookup((*itr).first))
				builder->addLookup(new LookupNode(new TableLookup((*itr).second)));
	}
	*/
}

ITable* TableManager::addTable(std::string table_name, const char* file) {
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
	  throw fem_exception("Could not open file " + std::string(file));
	ITable* t = ITable::Read(table_name, file, variableProvider);
	addTable(t);
	inf.close();
	return t;
}

void TableManager::readTableDefinitions(const char* dir, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		addTable(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str());
}

void TableManager::readTableDefinitions(const char* dir, std::vector<ITable*>& add_table_vec, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		add_table_vec.push_back(addTable(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str()));
}

void TableManager::getAll(std::vector<ITable*> &vec) {
	std::map<std::string, ProxyTable*>::iterator itr;
	for(itr = proxy_table_map.begin(); itr != proxy_table_map.end(); ++itr)
		vec.push_back((*itr).second);
}
