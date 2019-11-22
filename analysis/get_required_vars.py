#!/usr/bin/python

# This tool helps determine the necessary set of variables required to run the 
# simulation. It compiles a list of all the RHS variables in the model .est 
# files and all of the RHS variables used in vars.txt.  The LHS variables in 
# vars.txt are then removed from this list. The formula is:
# (Model RHS + Derived RHS) - Derived LHS
# where + is set union and - is set difference.  Each line in the output file
# has a member of this set followed by the variables that depend on the 
# variable.
# This script requires three arguments: 
# 1. the path to the .est files folder
# 2. the path the to the vars.txt file
# 3. the output text file to which the list will be written

# regular expression to match variable names
var_re = "[a-zA-Z_]+\d*[a-zA-Z_\d]*"

def get_estrhs_var(s):
	"""
	Reads a line from an .est file and returns the variable name if the line is 
	variable name-coefficient pair.  If there is not a coefficient value, then
	return "" because the input does not include a variable name.
	Input: s is the line from the .est file
	"""
	res = ""
	r = re.match("(" + var_re + ")(\s+)(-*[\d.]+)",s)
	if r is not None:
		res = r.group(1)
	return res

import os, re, sys

# create a set of all RHS variables in the .est files
est_rhs_vars = dict()

estpath = sys.argv[1]
if estpath[-1] == os.sep:
	estpath = estpath[:-1]
print "Reading models from " + estpath + "\n\n"
estfiles = os.listdir(estpath)
for fname in estfiles:
	if fname[-4:] == ".est":
		fpath = os.path.join(estpath,fname)
		with open(fpath, 'r') as ifile:
			estlines = ifile.readlines()
			lhs_var = estlines[1][:-1]
			x = map(get_estrhs_var, estlines)
			for v in x:
				if v != "":
					if v in est_rhs_vars:
						est_rhs_vars[v].update([lhs_var])
					else:
						est_rhs_vars[v] = set([lhs_var])

print "Model RHS:\n" + str(sorted(est_rhs_vars.keys())) + "\n\n\n"

# create a set of all derived (LHS) variables and RHS variables in the vars.txt file
derived_vars = set()
derived_rhs_vars = dict()
derivedpath = sys.argv[2]
with open(derivedpath, 'r') as ifile:
	derivedlines = ifile.readlines()
	for l in derivedlines:
		r = re.match("(" + var_re + ")(\s*=\s*)([^:]+)(:*.*)",l)
		if r is not None:
			lhs_var = r.group(1)
			derived_vars.update([lhs_var])
			rhs = r.group(3)
			rhs_vars = re.findall("(" + var_re + ")",rhs)
			for v in rhs_vars:
				if v != "":
					if v in derived_rhs_vars:
						derived_rhs_vars[v].update([lhs_var])
					else:
						derived_rhs_vars[v] = set([lhs_var])
		
if "" in derived_vars: derived_vars.remove("")
	
print "Derived RHS:\n" + str(sorted(derived_rhs_vars.keys())) + "\n\n\n"
print "Derived LHS:\n" + str(sorted(derived_vars)) + "\n\n\n"

# combine the RHS variables from .est files and vars.txt
req_vars = est_rhs_vars
for v in derived_rhs_vars:
	if v in req_vars:
		req_vars[v].update(derived_rhs_vars[v])
	else:
		req_vars[v] = derived_rhs_vars[v]

# remove the derived variables and identifiers that are not variables from the RHS variables
notvars = set(["_cut1","_cut2","_cut3","_cut4","_cut5","_cut6","_cut7","_cut8","_rmse","exp","floor","if","inrange","log","max","min","not","omega","ssr","theta","true"])
rmlist = []
for v in req_vars:
	if v in derived_vars | notvars:
		rmlist.append(v)
for v in rmlist:
	del req_vars[v]
		
print "(Model RHS + Derived RHS) - Derived LHS:\n" + str(sorted(req_vars.keys())) + "\n\n\n"

# write output file
outpath = sys.argv[3]
with open(outpath, 'w') as ofile:
	ofile.write("VARIABLE: DEPENDENTS\n")
	for v in sorted(req_vars.keys()):
		outline = v + ": " + ", ".join(sorted(req_vars[v])) + "\n" 
		ofile.write(outline)


