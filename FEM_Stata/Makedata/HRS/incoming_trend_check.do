/** \file

\bug This file will not run as-is

\todo If this is useful, fix it. If not, delete it.
*/
  
clear
set more off
set mem 200m
set seed 5243212
set maxvar 10000
cap log close

global workdir "//zeno/zeno_a/zyuhui/DOL/Makedata/HRS"
global indata  "//zeno/zeno_a/zyuhui/DOL/Input"
global outdata "//zeno/zeno_a/zyuhui/DOL/Input"
global outdata2 "//zeno/zeno_a/zyuhui/DOL/Indata"
global netdir  "/homer/homer_c/Retire/yuhui/rdata2"

adopath + "//zeno/zeno_a/zyuhui/DOL/PC"
adopath + "//zeno/zeno_a/zyuhui/DOL/Makedata/HRS"

global slist status_quo multi_r shareprev

		global bin hibpe hearte diabe anyhi shlt work wlth_nonzero anydb anydc
		global cont logiearnx loghatotax logdcwlthx logaime logq
		global cont iearnx hatota dcwlthx raime rq
		global ordered wtstate smkstat funcstat rdb_ea_c rdb_na_c
		* For categorical outcomes
		global wtstate_cat overwt obese
		global smkstat_cat smokev smoken 
		global funcstat_cat iadl1 adl1p
	  global rdb_ea_c_cat rdb_ea_2 rdb_ea_3
	  global rdb_na_c_cat rdb_na_2 rdb_na_3 rdb_na_4
	  
	  global baselist cancre lunge stroke $bin $cont $wtstate_cat $smkstat_cat $funcstat_cat $rdb_ea_c_cat $rdb_na_c_cat
	  global keeplist year cancre lunge stroke diabe hearte hibpe iadl1 adl1p overwt obese smokev smoken
	  
	use "$outdata/new51_2004_status_quo.dta"

 *		use "$outdata/new51_2050_shareprev.dta"

	 	* gen adl1p = adl12 | adl3
	mean year $baselist
	matrix mprev = e(b)
	drop _all
	svmat mprev, names(col)
	* keep $keeplist
	gen scr = "status_quo"
	gen order = 1
	save tmp, replace

#d;
local i = 1;
foreach f in 	new51_2050_status_quo new51_2004_multi_r	 
new51_2004_shareprev new51_2050_multi_r	 
new51_2050_shareprev { ;
	 local i = `i' + 1;
	 drop _all;
	 use "$outdata//`f'.dta";
	 * cap drop adl1p;
	 * gen adl1p = adl12 | adl3; 
	 mean year $baselist;
	 matrix m`f' = e(b);
	 drop _all;
	 svmat m`f', names(col);
	 * keep $keeplist;
	gen scr = "`f'" ;
	gen order = `i';
	append using tmp;
	save tmp, replace;
};
erase tmp.dta;

#d cr
sort order, stable

#d;
outsheet order scr $baselist using 
	"$outdata/incoming_trend_scrs.csv", replace comma nol;
#d cr



