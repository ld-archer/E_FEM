/** \file

This file parses all of the environment variables established in the Makefile and makes them available to Stata in the appropriate macros.
*/

local local_root : env ROOT

* Define Local Path, where code and local changes are
global local_path 			"`local_root'/FEM_Stata"

* Define path to base data to create FEM cohorts
global indata   			"`local_root'/base_data"

* Define input data for FEM, such as incoming cohorts, etc
global outdata 				"`local_root'/input_data"

global output_dir 			"`local_root'/output"
