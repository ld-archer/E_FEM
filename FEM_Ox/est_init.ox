#include <oxstd.h>
#include <oxdraw.h>
#include <oxprob.h>
#include "FEM.ox"


/** FEM Estimation Code for Initial Conditions
   \author Pierre-Carl Michaud and Yuhui Zheng
   \date September 2007	
   
   
   \note run estimation with command mpiexec -machinefile mf -n 48 oxl64 est_init.ox

   \bug Due to an initialization issue, the independent (X_VAR) and dependent (Y_VAR) variables cannot be changed in number or type.
   This means, if you want to use different variables, you have to swap them one-to-one, including having the same number of outcomes
   for any ordered variables.

   \todo update so that this code no longer relies on data resident on homer.

   \todo automate the extraction of the covariance matrix from the ox output to the stata input (currently stored in incoming_vcmatrix.dta)

   \todo automate the extraction of the ordered probit cut points from the ox output to the stata code (currently hand-entered in new51_simulate.do)
   
   \todo automate the extraction of the betas from the ox output to the stata input (currently stored in incoming_means.dta)
*/   
main()
{
  decl args = arglist();
  
	// This is the class we use.
	decl obj = new FEM();
	// this is where we work
	if(sizeof(args) >= 2)
	  obj.SetPath(args[1]);
	else
	  obj.SetPath("~");
	// Estimates the initial condition model
	obj.SetModel(M_INIT);
	// This says to use outer product of gradient formula for standard errors (which we don't need)
	obj.SetStd(OGP);
	// number of draws (few in this, should be higher but sometimes fails)
	obj.SetDraws(5);
	// this is the string that will be appended to file name for results 
	obj.SetName("init92");
	// This is the dataset, it is on /homer/c/Retire/michaud/data/fem
	obj.Load("/homer/c/Retire/michaud/data/fem/age5055_hrs1992r_bmi_exp.csv");
    	obj.Deterministic(TRUE);     		   // create constant
                                    	   // Formulate the model
	// Dependent variables								
	obj.Select(Y_VAR, {"fhibpe",0,0,"fhearte",0,0,"fdiabe",0,0,"fanyhi",0,0,"fshlt",0,0,
			 		   "fwtstate",0,0,"fsmkstat",0,0,"ffuncstat",0,0,
			           "fwork",0,0,"fwlth_nonzero",0,0,					  
			           "flogaime",0,0,"flogq",0,0,
				"floghatotax",0,0,"flogiearnx",0,0,"flogdcwlthx",0,0,
					   "fanydc",0,0, "fanydb",0,0,"frdb_ea_c",0,0,"frdb_na_c",0,0});
	// Type of dep var, will influence choice probabilities, see FEM.ox for types
	obj.SetVarType(BIN|BIN|BIN|BIN|BIN|
				  	ORDER|ORDER|ORDER|
				  	BIN|BIN|
					CONT|CONT|
					CENSOR|CENSOR|CENSOR|
					CENSORBIN|CENSORBIN|CENSORORDER|CENSORORDER);	
	// For each censor vars, these vars (from Y_VAR) are the variables that take value 1 when non-censored, zero if not
	obj.SetSelectionVars({"fwlth_nonzero","fwork","fanydc",
						 "fwork","fwork","fanydb","fanydb"});	
	// These are the covariates used on right hand side of model
	obj.Select(Z_VAR, {"hispan",0,0,"black",0,0,
						"male",0,0,
						"hsless",0,0,"college",0,0,
						"fsingle",0,0,"fwidowed",0,0,"flunge",0,0,"fstroke",0,0,"fcancre",0,0,"Constant",0,0});
	// This prints descriptive statistics
	obj.Info();
	// This defines the ids (in init condition time = 1 and period = 1)
	obj.SetId("hhidpn", "time", "period");
	// Don't touch this
	obj.SetSelSample(-1, 1, -1, 1);  	
	// This launches estimation, go see Estimate function in the code to see how this happens.
	obj.Estimate();
	
}
