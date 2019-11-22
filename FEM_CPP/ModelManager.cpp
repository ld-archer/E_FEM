#include "ModelManager.h"
#include "utility.h"
#include "LogitRegression.h"
#include "OrderedProbitRegression.h"
#include "ProbitRegression.h"
#include "ShiftedProbitRegression.h"
#include "Regression.h"
#include "TimeScaledProbitRegression.h"
#include "PoissonRegression.h"
#include "GHREG.h"
#include "MultinomialLogit.h"
#include "MultinomialProbit.h"
#include "TableModel.h"
#include "WeibullPHSurvivalModel.h"
#include "Logger.h"
#include <fstream>
#include <limits>
#include "fem_exception.h"
ModelManager::ModelManager(IVariableProvider* vp)
{
	this->var_provider = vp;
	IModel* m;
	
	m = new Regression();
	model_templates[m->getType()] = m;

	m = new LogitRegression();
	model_templates[m->getType()] = m;

	m = new PoissonRegression();
	model_templates[m->getType()] = m;


	m = new ProbitRegression();
	model_templates[m->getType()] = m;

	m = new OrderedProbitRegression();
	model_templates[m->getType()] = m;

	m = new GHREG();
	model_templates[m->getType()] = m;

	m = new ShiftedProbitRegression();
	model_templates[m->getType()] = m;

	m = new TimeScaledProbitRegression();
	model_templates[m->getType()] = m;

	m = new MultinomialLogit();
	model_templates[m->getType()] = m;
	
	m = new MultinomialProbit();
	model_templates[m->getType()] = m;
	
	m = new WeibullPHSurvivalModel();
	model_templates[m->getType()] = m;
	
	m = new TableModel();
	model_templates[m->getType()] = m;
}

ModelManager::~ModelManager(void)
{
	clearModels();
	
	std::map<std::string, IModel*>::iterator itr;
	
	for(itr = model_templates.begin(); itr != model_templates.end(); ++itr)
		delete (*itr).second;
}


IModel* ModelManager::get(std::string name) {
	if(loaded_models.count(name))
		return loaded_models[name];
	throw fem_exception(std::string(name + " is not a loaded model").c_str());
}

IModel* ModelManager::getModelTemplate(std::string template_name) {
	if(model_templates.count(template_name))
		return model_templates[template_name]->clone();
	throw fem_exception(std::string(template_name + " is not a valid model_type").c_str());
}

IModel* ModelManager::addModel(IModel* model){
	if(loaded_models.count(model->getName()))
		delete loaded_models[model->getName()];
	loaded_models[model->getName()] = model;
	return model;
}

IModel* ModelManager::addModel(std::string model_name, const char* file) {
	std::ifstream inf(file);
	if( inf.bad() || inf.fail())
	  throw fem_exception("Could not open file "+std::string(file));
	std::string model_type;
	
	// Read in the model type, which is the first line in the file
	inf >> model_type;
	
	// Eat any newline characters
	inf.ignore(std::numeric_limits<std::streamsize>::max(), '\n');

	// Get a blank copy of the model for this model type
	IModel* model = getModelTemplate(model_type);

	// Set the name of the model (usually the name of the predicted variable)
	model->setName(model_name);
	try {
		// Tell the model to read in the rest of the file
		model->read(inf, var_provider);

		// If reading the file went well, then add the model to the list
		addModel(model);
	} catch(const fem_exception & e) {
		// There was a problem reading the model.

		// Close the file
		inf.close();

		// Rethrow the exception
		throw e;
	}
	
	// Success! Close the file and return the newly created model
	inf.close();

	return model;
}



void ModelManager::readModelDefinitions(const char* dir, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		addModel(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str());
}

void ModelManager::readModelDefinitions(const char* dir, std::vector<IModel*>& models_added, const char* ext) {
	std::vector<std::string> files;
	std::string dir_str(dir);
	getdir(dir, files, ext);
	
	for(unsigned int i = 0; i < files.size(); i++)
		models_added.push_back(addModel(files[i].substr(0, files[i].find_last_of(".")), (dir_str + _PATH_DELIM_ + files[i]).c_str()));
}

void ModelManager::getAll(std::vector<IModel*> &vec) {
	std::map<std::string, IModel*>::iterator itr;
	for(itr = loaded_models.begin(); itr != loaded_models.end(); ++itr)
		vec.push_back((*itr).second);
}

void ModelManager::clearModels() {
	std::map<std::string, IModel*>::iterator itr;

	for(itr = loaded_models.begin(); itr != loaded_models.end(); ++itr)
		delete (*itr).second;	
	loaded_models.clear();
}
