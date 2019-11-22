*! version 1.0.1  07apr2005
*! Change it to expandgroup
*  Yuhui Zheng, May 2007

capture program drop expandgroup
program expandgroup, sortpreserve
	version 9
	gettoken equal : 0, parse("=")
	if "`equal'" != "=" {
		local 0 `"= `0'"'
	}
	syntax =exp [if] [in],		///
		GENerate(name)		///
		CLuster(varlist)

	confirm new variable `generate'

*	marksample touse, novarlist

	tempvar touse 
	mark `touse' `if' `in'

*	tab `touse'	
	
	tempvar vexp oid cid eid

quietly {

	gen `vexp' `exp'

	// generate cluster id variable that contains the contiguous integers
	// 1, ..., `ncl'; where `ncl' is the number of clusters

	sort `touse' `cluster', stable
	capture by `touse' `cluster': ///
		assert int(`vexp') == int(`vexp'[1]) if `touse'
	if c(rc) {
		di as err "expression is not constant within clusters"
		exit 198
	}

	by `touse' `cluster': gen `cid' = _n==1
	replace `cid' = sum(`cid')
	local ncl = `cid'[_N]
	gen `oid' = _n

	noisily expand `exp' if `touse'

	// generate the cluster id variable that is unique between the copies
	// of the original clusters

	sort `touse' `cluster' `oid', stable
	by `touse' `cluster' `oid': gen double `eid' = _n if _n <= `vexp'
	by `touse' `cluster' `oid': replace `eid' = `eid'[_n-`vexp'] if _n > `vexp'
	sort `touse' `cluster' `eid', stable
	drop `oid'
	by `touse' `cluster' `eid': gen double `oid' = _n==1 if `touse'
	replace `eid' = sum(`oid') if `touse'
	replace `eid' = . if `touse' == 0
	rename `eid' `generate'

} // quietly

end

