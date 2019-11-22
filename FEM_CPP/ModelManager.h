#pragma once
#pragma once
#include "Model.h"
#include "Variable.h"
#include <vector>
#include <map>


/** This is the class that handles the loading, storing, and retrieval of all the predictive models.

\todo Currently, much of the code assumes that the name of the model and the predicted variable are one and the same.
This assumption should be relaxed.

\todo The code does not keep track of where each model object was created.  IModel objects are deleted as if nothing 
outside of the ModelManager points to them.  This is ok now, but could be a problem in the future.

*/
class ModelManager :
	public IModelProvider
{
public:
	ModelManager(IVariableProvider* vp);
	virtual ~ModelManager(void);
	virtual IModel* get(std::string name);
	IModel* addModel(IModel* model);
	IModel* addModel(std::string model_name, const char* file);
	void readModelDefinitions(const char* dir, const char* ext = "*.est");
	void readModelDefinitions(const char* dir, std::vector<IModel*>& models_added, const char* ext = "*.est");
	virtual void getAll(std::vector<IModel*> &vec);
		
	/** Delete all loaded models from memory */
	virtual void clearModels();

protected:
	IModel* getModelTemplate(std::string template_name);
	std::map<std::string, IModel*> loaded_models;
	std::map<std::string, IModel*> model_templates;
	IVariableProvider* var_provider;
};

