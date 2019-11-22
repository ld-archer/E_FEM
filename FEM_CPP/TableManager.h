#pragma once
#include "Table.h"
#include "EquationNode.h"
#include <vector>
#include "ProxyTable.h"
#include <map>

class TableManager :
	public ITableProvider
{
public:
	TableManager(void);
	virtual ~TableManager(void);
	virtual ITable* get(std::string name);
	ITable* addTable(ITable* table);
	ITable* addTable(std::string Table_name, const char* file);
	
	/** the NodeBuilder does not get used in this class because table lookups are not implemented
	*/	
	void setBuilder(NodeBuilder* builder);
	inline NodeBuilder* getBuilder() {return builder;}

	void readTableDefinitions(const char* dir, const char* ext = "*.txt");
	void readTableDefinitions(const char* dir, std::vector<ITable*>& add_table_vec, const char* ext = "*.txt");
	virtual void getAll(std::vector<ITable*> &vec);
	inline bool hasTable(std::string name) {return proxy_table_map.count(name) > 0;}
	virtual void setVariableProvider(IVariableProvider* vp) { variableProvider=vp; };

protected:
	std::map<std::string, ITable*> table_map;
	std::map<std::string, ProxyTable*> proxy_table_map;
	NodeBuilder* builder;
	IVariableProvider* variableProvider; 
};
