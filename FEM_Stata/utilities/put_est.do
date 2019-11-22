
/*
WRITE MATA mo. files that put and get estimates
DEC 12, 2005
YUHUI ZHENG
*/

*** mo.file to put estimates into files

 version 9.0
 mata:
 mata clear
 void _putestimates(string scalar fname, string scalar sname, string scalar mdl)
 {
	real matrix coeff
	string matrix soeff
	coeff = st_matrix(mdl)
	soeff = st_matrixcolstripe(mdl)
	coeff
	fh = fopen(fname, "w")
	fputmatrix(fh,coeff)
	fclose(fh)
	fh2 = fopen(sname, "w")
	fputmatrix(fh2,soeff)
	fclose(fh2)
}
mata mosave _putestimates(), replace

 void _getestimates(string scalar fname, string scalar sname, string scalar mdl)
 {
 	real matrix coeff
	string matrix soeff
	fh = fopen(fname, "r")
	coeff = fgetmatrix(fh)
	fclose(fh)
	fh2 = fopen(sname, "r")
	soeff = fgetmatrix(fh2)
	fclose(fh2)
	st_matrix(mdl,coeff)
	st_matrixcolstripe(mdl,soeff)
	}
	
mata mosave _getestimates(), replace

end

exit, STATA
