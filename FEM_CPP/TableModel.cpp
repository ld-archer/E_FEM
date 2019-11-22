#include "TableModel.h"
#include <limits>
#include "fem_exception.h"

TableModel::TableModel(void)
{
	predicted_var = Vars::_NONE;
	name = "table";
}

TableModel::TableModel(const TableModel& source)
{
	predicted_var = source.predicted_var;
	name = source.name;
	table = source.table;	
}

TableModel::~TableModel(void)
{
}

void TableModel::predict(Person* person, const Random* random) const
{
	person->set(predicted_var, estimate(person));
}

void TableModel::predictWithProb(Person* person, const Random* random, double prob) const
{
	throw fem_exception("predictWithProb is not implmented for TableModel class");
}


double TableModel::estimate(const Person* person) const
{
	// check that person has a corresponding table entry
	if(table.isIndexKey(*person))
		return(table.get(*person));
	else
		throw fem_exception("Person does not have table entry for predicting " + VarsInfo::labelOf(predicted_var));
}

std::string TableModel::describe() const
{
	std::stringstream strm;
	if(predicted_var == Vars::_NONE) // Model is loaded?
	  strm << "TableModel has no predicted variable" << std::endl;
	else
	{
	  strm << getTypeDesc() << " for " << VarsInfo::labelOf(predicted_var) << std::endl;
	}
	strm << "Index variables:" << std::endl;
	std::vector<std::string> idxvars = table.getIndexVarNames();
	for(unsigned int i = 0; i < idxvars.size(); i++)
	  strm << " " << idxvars[i];
	strm << std::endl;

	return strm.str();
} 

void TableModel::read(std::istream& istrm, IVariableProvider* provider)
{
	std::string buf;

	table.clear();
	table.setVariableProvider(provider);
	
	istrm >> buf;
	predicted_var = VarsInfo::indexOf(buf);

	// Check if the variable read in exists
	if (predicted_var == Vars::_NONE) {
		std::ostringstream ss;
		ss << "Error reading model " << getName() << ": Predicted variable [" << buf << "] does not exist!";
		throw fem_exception(ss.str().c_str());
	} else {
		// Eat any newline characters
		istrm.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
		table.read(istrm);
	}
}


