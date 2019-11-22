/** \file
Main file of using HRS to generate analytic and simulation datasets for FEM.

- Apr 8, 2008
- Input data files:
- rndhrs_g.dta
- Apr 12, 2008, be run on ZENO
- Should connect to HOMER after logging into ZENO

\bug This file will not run as-is

\bug This file doesn't actually do anything.

*/
clear
set more off
set mem 800m
set seed 5243212
set maxvar 10000
cap log close

global workdir "/zeno/d/zeno_a/zyuhui/DOL/Makedata/HRS"
global indata  "/zeno/d/zeno_a/zyuhui/DOL/Input"
global outdata "/zeno/d/zeno_a/zyuhui/DOL/Input"
global outdata2 "/zeno/d/zeno_a/zyuhui/DOL/Indata"
global netdir  "/homer/c/Retire/yuhui/rdata2"

adopath + "/zeno/d/zeno_a/zyuhui/DOL/PC"
adopath + "/zeno/d/zeno_a/zyuhui/DOL/Makedata/HRS"

*** APPLY EUROPEAN TREND TO THE US
global netdir  "/homer/c/Retire/yuhui/rdata2"

use "$outdata/new51_2004_status_quo.dta", clear
/*
obese	0.320	0.152	0.474
ever smoked	0.572	0.549	0.959
current smoker	0.241	0.309	1.279
heart disease	0.102	0.032	0.310
diabetes	0.115	0.046	0.399
stroke	0.023	0.010	0.436
lung disease	0.052	0.024	0.456
cancer	0.048	0.030	0.619
hypertension	0.333	0.162	0.487
disability (at least one ADL)	0.091	0.056	0.612
*/

matrix share_us = (0.474, 1.279, 0.310, 0.399, 0.436, 0.456, 0.619, 0.333, 0.612)
matrix colnames share_us = obese smoken hearte diabe stroke lunge cancre hibpe adl1p



