
*** RENAME LIST FOR EARNINGS AND WEALTH EQUATION

global allvars_hatotax_r 
dis "$allvars_hatotax"
foreach x in $allvars_hatotax { 
	
	if "`x'" == "black" {
		ren `x' bl
		global allvars_hatotax_r $allvars_hatotax_r bl
	}
	if "`x'" == "lhearte" {
		ren `x' lh
		global allvars_hatotax_r $allvars_hatotax_r lh
	}
	if "`x'" == "lstroke" {
		ren `x' ls
		global allvars_hatotax_r $allvars_hatotax_r ls
	}
	if "`x'" == "lcancre" {
		ren `x' lc
		global allvars_hatotax_r $allvars_hatotax_r lc
	}
	if "`x'" == "lhibpe" {
		ren `x' lhi
		global allvars_hatotax_r $allvars_hatotax_r lhi
	}
	if "`x'" == "nosmoke_r" {
		ren `x' ld
		global allvars_hatotax_r $allvars_hatotax_r ld
	}
	if "`x'" == "llunge" {
		ren `x' ll
		global allvars_hatotax_r $allvars_hatotax_r ll
	}
	if "`x'" == "lanyhi" {
		ren `x' la
		global allvars_hatotax_r $allvars_hatotax_r la
	}
	if "`x'" == "ldiclaim" {
		ren `x' ldi
		global allvars_hatotax_r $allvars_hatotax_r ldi
	}
	if "`x'" == "lssiclaim" {
		ren `x' lss
		global allvars_hatotax_r $allvars_hatotax_r lss
	}
	if "`x'" == "lssclaim" {
		ren `x' lssc
		global allvars_hatotax_r $allvars_hatotax_r lssc
	}
	if "`x'" == "ldbclaim" {
		ren `x' ldb
		global allvars_hatotax_r $allvars_hatotax_r ldb
	}
	if "`x'" == "lsmoken" {
		ren `x' lsm
		global allvars_hatotax_r $allvars_hatotax_r lsm
	}
	if "`x'" == "liadl1" {
		ren `x' li
		global allvars_hatotax_r $allvars_hatotax_r li
	}
	if "`x'" == "ladl12" {
		ren `x' lad
		global allvars_hatotax_r $allvars_hatotax_r lad
	}
	if "`x'" == "ladl3" {
		ren `x' ladl
		global allvars_hatotax_r $allvars_hatotax_r ladl
	}
	if "`x'" == "ldiabe" {
		ren `x' ld
		global allvars_hatotax_r $allvars_hatotax_r ld
	}
	if "`x'" == "lwork" {
		ren `x' lw
		global allvars_hatotax_r $allvars_hatotax_r lw
	}
	if "`x'" == "llogiearnx" {
		ren `x' llo
		global allvars_hatotax_r $allvars_hatotax_r llo
	}
	if "`x'" == "flogiearnx" {
		ren `x' fe
		global allvars_hatotax_r $allvars_hatotax_r fe
	}
	if "`x'" == "fhearte" {
		ren `x' fh
		global allvars_hatotax_r $allvars_hatotax_r fh
	}
	if "`x'" == "fstroke" {
		ren `x' fs
		global allvars_hatotax_r $allvars_hatotax_r fs
	}
	if "`x'" == "fcancre" {
		ren `x' fc
		global allvars_hatotax_r $allvars_hatotax_r fc
	}
	if "`x'" == "fhibpe" {
		ren `x' fhi
		global allvars_hatotax_r $allvars_hatotax_r fhi
	}
	if "`x'" == "fdiabe" {
		ren `x' fd
		global allvars_hatotax_r $allvars_hatotax_r fd
	}
	if "`x'" == "flunge" {
		ren `x' fl
		global allvars_hatotax_r $allvars_hatotax_r fl
	}
	if "`x'" == "fanyhi" {
		ren `x' fa
		global allvars_hatotax_r $allvars_hatotax_r fa
	}
	if "`x'" == "fsmokev" {
		ren `x' fsm
		global allvars_hatotax_r $allvars_hatotax_r fsm
	}
	if "`x'" == "fsmoken" {
		ren `x' fsmo
		global allvars_hatotax_r $allvars_hatotax_r fsmo
	}
	if "`x'" == "fiadl1" {
		ren `x' fi
		global allvars_hatotax_r $allvars_hatotax_r fi
	}
	if "`x'" == "fadl12" {
		ren `x' fad
		global allvars_hatotax_r $allvars_hatotax_r fad
	}
	if "`x'" == "fadl3" {
		ren `x' fadl
		global allvars_hatotax_r $allvars_hatotax_r fadl
	}
	if "`x'" == "fwork" {
		ren `x' fw
		global allvars_hatotax_r $allvars_hatotax_r fw
	}
	if "`x'" == "fwlth_nonzero" {
		ren `x' fwl
		global allvars_hatotax_r $allvars_hatotax_r fwl
	}
	if "`x'" == "floghatotax" {
		ren `x' flo
		global allvars_hatotax_r $allvars_hatotax_r flo
	}
	if "`x'" == "lloghatotax" {
		ren `x' lha
		global allvars_hatotax_r $allvars_hatotax_r lha
	}
	if "`x'" == "lwlth_nonzero" {
		ren `x' lwo
		global allvars_hatotax_r $allvars_hatotax_r lwo
	}
	if "`x'" == "lage75l" {
		ren `x' lag
		global allvars_hatotax_r $allvars_hatotax_r lag
	}
	if "`x'" == "lwidowed" {
		ren `x' lwi
		global allvars_hatotax_r $allvars_hatotax_r lwi
	}
	if "`x'" == "hispan" {
		ren `x' hi
		global allvars_hatotax_r $allvars_hatotax_r hi
	}
	if "`x'" == "hsless" {
		ren `x' hs
		global allvars_hatotax_r $allvars_hatotax_r hs
	}
	if "`x'" == "college" {
		ren `x' co
		global allvars_hatotax_r $allvars_hatotax_r co
	}
	if "`x'" == "male" {
		ren `x' ma
		global allvars_hatotax_r $allvars_hatotax_r ma
	}
	if "`x'" == "fwidowed" {
		ren `x' fwi
		global allvars_hatotax_r $allvars_hatotax_r fwi
	}
	if "`x'" == "fsingle" {
		ren `x' fsi
		global allvars_hatotax_r $allvars_hatotax_r fsi
	}
	if "`x'" == "flogaime" {
		ren `x' flog
		global allvars_hatotax_r $allvars_hatotax_r flog
	}
	if "`x'" == "flogq" {
		**ren `x' flogq
		global allvars_hatotax_r $allvars_hatotax_r flogq
	}
	if "`x'" == "fshlt" {
		ren `x' fsh
		global allvars_hatotax_r $allvars_hatotax_r fsh
	}
	if "`x'" == "fanydb" {
		ren `x' fan
		global allvars_hatotax_r $allvars_hatotax_r fan
	}
	if "`x'" == "frdb_na_2" {
		ren `x' f2
		global allvars_hatotax_r $allvars_hatotax_r f2
	}
	if "`x'" == "frdb_na_3" {
		ren `x' f3
		global allvars_hatotax_r $allvars_hatotax_r f3
	}
	if "`x'" == "frdb_na_4" {
		ren `x' f4
		global allvars_hatotax_r $allvars_hatotax_r f4
	}	
	if "`x'" == "fanydc" {
		ren `x' fany
		global allvars_hatotax_r $allvars_hatotax_r fany
	}
	if "`x'" == "flogdcwlthx" {
		ren `x' flogd
		global allvars_hatotax_r $allvars_hatotax_r flogd
	}
	if "`x'" == "lage65l" {
		ren `x' l1
		global allvars_hatotax_r $allvars_hatotax_r l1
	}
	if "`x'" == "lage6574" {
		ren `x' l2
		global allvars_hatotax_r $allvars_hatotax_r l2
	}
	if "`x'" == "lage75p" {
		ren `x' l3
		global allvars_hatotax_r $allvars_hatotax_r l3
	}
	if "`x'" == "logdeltaage" {
		ren `x' lda
		global allvars_hatotax_r $allvars_hatotax_r lda
	}
	if inlist("`x'","w3","w4","w5","w6","w7","frbyr")|inlist("`x'","la6","la7","la7p"){
		global allvars_hatotax_r $allvars_hatotax_r `x'
	}
	if "`x'" == "lnhmliv" {
		ren `x' nhm
		global allvars_hatotax_r $allvars_hatotax_r nhm
	}


}
