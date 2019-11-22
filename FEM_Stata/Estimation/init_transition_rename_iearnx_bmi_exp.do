
*** RENAME LIST FOR EARNINGS AND WEALTH EQUATION

global allvars_iearnx_r 
dis "$allvars_iearnx"
foreach x in $allvars_iearnx { 
	if "`x'" == "male_hsless" {
          ren `x' mhs
          global allvars_iearnx_r $allvars_iearnx_r mhs
        }
        if "`x'" == "male_black" {
          ren `x' mbl
          global allvars_iearnx_r $allvars_iearnx_r mbl
        }
        if "`x'" == "male_hispan" {
          ren `x' mhp
          global allvars_iearnx_r $allvars_iearnx_r mhp
        }	
	if "`x'" == "black" {
		ren `x' bl
		global allvars_iearnx_r $allvars_iearnx_r bl
	}
	if "`x'" == "lhearte" {
		ren `x' lh
		global allvars_iearnx_r $allvars_iearnx_r lh
	}
	if "`x'" == "lstroke" {
		ren `x' ls
		global allvars_iearnx_r $allvars_iearnx_r ls
	}
	if "`x'" == "lcancre" {
		ren `x' lc
		global allvars_iearnx_r $allvars_iearnx_r lc
	}
	if "`x'" == "obese_1" {
		ren `x' o1
		global allvars_hatotax_r $allvars_hatotax_r ll
	}
	if "`x'" == "obese_2" {
		ren `x' o2
		global allvars_hatotax_r $allvars_hatotax_r ll
	}
	if "`x'" == "obese_3" {
		ren `x' o3
		global allvars_hatotax_r $allvars_hatotax_r ll
	}
	if "`x'" == "lhibpe" {
		ren `x' lhi
		global allvars_iearnx_r $allvars_iearnx_r lhi
	}
	if "`x'" == "ldiabe" {
		ren `x' ld
		global allvars_iearnx_r $allvars_iearnx_r ld
	}
	if "`x'" == "llunge" {
		ren `x' ll
		global allvars_iearnx_r $allvars_iearnx_r ll
	}
	if "`x'" == "lanyhi" {
		ren `x' la
		global allvars_iearnx_r $allvars_iearnx_r la
	}
	if "`x'" == "ldiclaim" {
		ren `x' ldi
		global allvars_iearnx_r $allvars_iearnx_r ldi
	}
	if "`x'" == "lssiclaim" {
		ren `x' lss
		global allvars_iearnx_r $allvars_iearnx_r lss
	}
	if "`x'" == "lssclaim" {
		ren `x' lssc
		global allvars_iearnx_r $allvars_iearnx_r lssc
	}
	if "`x'" == "ldbclaim" {
		ren `x' ldb
		global allvars_iearnx_r $allvars_iearnx_r ldb
	}
	if "`x'" == "lsmoken" {
		ren `x' lsm
		global allvars_iearnx_r $allvars_iearnx_r lsm
	}
	if "`x'" == "liadl1" {
		ren `x' li1
		global allvars_iearnx_r $allvars_iearnx_r li1
	}
	if "`x'" == "liadl2p" {
		ren `x' li2
		global allvars_iearnx_r $allvars_iearnx_r li2
	}
	if "`x'" == "ladl1" {
		ren `x' la1
		global allvars_iearnx_r $allvars_iearnx_r la1
	}
	if "`x'" == "ladl2" {
		ren `x' la2
		global allvars_iearnx_r $allvars_iearnx_r la2
	}
	if "`x'" == "ladl3p" {
		ren `x' la3
		global allvars_iearnx_r $allvars_iearnx_r la3
	}
	if "`x'" == "lwork" {
		ren `x' lw
		global allvars_iearnx_r $allvars_iearnx_r lw
	}
	if "`x'" == "llogiearnx" {
		ren `x' llo
		global allvars_iearnx_r $allvars_iearnx_r llo
	}
	if "`x'" == "flogiearnx" {
		ren `x' fe
		global allvars_iearnx_r $allvars_iearnx_r fe
	}
	if "`x'" == "fhearte" {
		ren `x' fh
		global allvars_iearnx_r $allvars_iearnx_r fh
	}
	if "`x'" == "fstroke" {
		ren `x' fs
		global allvars_iearnx_r $allvars_iearnx_r fs
	}
	if "`x'" == "fcancre" {
		ren `x' fc
		global allvars_iearnx_r $allvars_iearnx_r fc
	}
	if "`x'" == "fhibpe" {
		ren `x' fhi
		global allvars_iearnx_r $allvars_iearnx_r fhi
	}
	if "`x'" == "fdiabe" {
		ren `x' fd
		global allvars_iearnx_r $allvars_iearnx_r fd
	}
	if "`x'" == "flunge" {
		ren `x' fl
		global allvars_iearnx_r $allvars_iearnx_r fl
	}
	if "`x'" == "fanyhi" {
		ren `x' fa
		global allvars_iearnx_r $allvars_iearnx_r fa
	}
	if "`x'" == "fsmokev" {
		ren `x' fsm
		global allvars_iearnx_r $allvars_iearnx_r fsm
	}
	if "`x'" == "fsmoken" {
		ren `x' fsmo
		global allvars_iearnx_r $allvars_iearnx_r fsmo
	}
	if "`x'" == "fiadl1" {
		ren `x' fi1
		global allvars_iearnx_r $allvars_iearnx_r fi1
	}
	if "`x'" == "fiadl2p" {
		ren `x' fi2
		global allvars_iearnx_r $allvars_iearnx_r fi2
	}
	if "`x'" == "fadl1" {
		ren `x' fa1
		global allvars_iearnx_r $allvars_iearnx_r fa1
	}
	if "`x'" == "fadl2" {
		ren `x' fa2
		global allvars_iearnx_r $allvars_iearnx_r fa2
	}
	if "`x'" == "fadl3p" {
		ren `x' fa3
		global allvars_iearnx_r $allvars_iearnx_r fa3
	}
	if "`x'" == "fwork" {
		ren `x' fw
		global allvars_iearnx_r $allvars_iearnx_r fw
	}
	if "`x'" == "fwlth_nonzero" {
		ren `x' fwl
		global allvars_iearnx_r $allvars_iearnx_r fwl
	}
	if "`x'" == "floghatotax" {
		ren `x' flo
		global allvars_iearnx_r $allvars_iearnx_r flo
	}
	if "`x'" == "lloghatotax" {
		ren `x' lha
		global allvars_iearnx_r $allvars_iearnx_r lha
	}
	if "`x'" == "lwlth_nonzero" {
		ren `x' lwo
		global allvars_iearnx_r $allvars_iearnx_r lwo
	}
	if "`x'" == "lage75l" {
		ren `x' lag
		global allvars_iearnx_r $allvars_iearnx_r lag
	}
	if "`x'" == "lwidowed" {
		ren `x' lwi
		global allvars_iearnx_r $allvars_iearnx_r lwi
	}
	if "`x'" == "hispan" {
		ren `x' hi
		global allvars_iearnx_r $allvars_iearnx_r hi
	}
	if "`x'" == "hsless" {
		ren `x' hs
		global allvars_iearnx_r $allvars_iearnx_r hs
	}
        if "`x'" == "somecol" {
          ren `x' sc
          global allvars_iearnx_r $allvars_iearnx_r sc
        }
	if "`x'" == "college" {
		ren `x' co
		global allvars_iearnx_r $allvars_iearnx_r co
	}
        if "`x'" == "collgrad" {
          ren `x' cg
          global allvars_iearnx_r $allvars_iearnx_r cg
        }
	if "`x'" == "male" {
		ren `x' ma
		global allvars_iearnx_r $allvars_iearnx_r ma
	}
	if "`x'" == "fwidowed" {
		ren `x' fwi
		global allvars_iearnx_r $allvars_iearnx_r fwi
	}
	if "`x'" == "fsingle" {
		ren `x' fsi
		global allvars_iearnx_r $allvars_iearnx_r fsi
	}
	if "`x'" == "flogaime" {
		ren `x' flog
		global allvars_iearnx_r $allvars_iearnx_r flog
	}
	if "`x'" == "flogq" {
		**ren `x' flogq
		global allvars_iearnx_r $allvars_iearnx_r flogq
	}
	if "`x'" == "fshlt" {
		ren `x' fsh
		global allvars_iearnx_r $allvars_iearnx_r fsh
	}
	if "`x'" == "fanydb" {
		ren `x' fan
		global allvars_iearnx_r $allvars_iearnx_r fan
	}
	if "`x'" == "frdb_na_2" {
		ren `x' f2
		global allvars_iearnx_r $allvars_iearnx_r f2
	}
	if "`x'" == "frdb_na_3" {
		ren `x' f3
		global allvars_iearnx_r $allvars_iearnx_r f3
	}
	if "`x'" == "frdb_na_4" {
		ren `x' f4
		global allvars_iearnx_r $allvars_iearnx_r f4
	}	
	if "`x'" == "fanydc" {
		ren `x' fany
		global allvars_iearnx_r $allvars_iearnx_r fany
	}
	if "`x'" == "flogdcwlthx" {
		ren `x' flogd
		global allvars_iearnx_r $allvars_iearnx_r flogd
	}
	if "`x'" == "lage65l" {
		ren `x' l1
		global allvars_iearnx_r $allvars_iearnx_r l1
	}
	if "`x'" == "lage6574" {
		ren `x' l2
		global allvars_iearnx_r $allvars_iearnx_r l2
	}
	if "`x'" == "lage75p" {
		ren `x' l3
		global allvars_iearnx_r $allvars_iearnx_r l3
	}
	if "`x'" == "logdeltaage" {
		ren `x' lda
		global allvars_iearnx_r $allvars_iearnx_r lda
	}

}

