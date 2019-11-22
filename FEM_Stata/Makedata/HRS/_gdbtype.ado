/* Function to Get db type from Shawn's approximation
-----------------------------------------------------*/

program define _gdbtype
	version 9, missing
	gettoken type 0 : 0
	gettoken dbtype 0 : 0
	gettoken eqs 0 : 0			/* "=" */
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	gettoken sex 0 : 0, parse("(), ")
	gettoken era 0 : 0, parse("(), ")
	gettoken nra 0 : 0, parse("(), ")
	gettoken paren 0 : 0, parse("(), ")	/* "(" */
	syntax [if] [in] [, BY(string)]
		marksample touse
		global result `dbtype'
		global sex `sex'
		global era `era'
		global nra `nra'
		global selected `touse'
		qui gen $result = . if $selected
		getdbtype
end

program define typefor
	qui replace $result = `4' if $sex==`1'&$era==`2'&$nra==`3'&$selected
end

program define getdbtype
	typefor	0	45	55	9.588
	typefor	0	45	60	9.021
	typefor	0	45	65	7.568
	typefor	0	50	55	9.244
	typefor	0	50	60	8.913
	typefor	0	50	65	8.490
	typefor	0	55	55	9.094
	typefor	0	55	60	8.887
	typefor	0	60	60	8.798
	typefor	0	60	65	8.269
	typefor	0	55	65	8.341

	typefor	1	45	55	10.131
	typefor	1	45	60	9.712
	typefor	1	45	65	8.937
	typefor	1	50	55	9.834
	typefor	1	50	60	9.494
	typefor	1	50	65	9.184
	typefor	1	55	55	9.676
	typefor	1	55	60	9.386
	typefor	1	60	60	9.344
	typefor	1	60	65	8.886
	typefor     1     55    65    8.944
end
