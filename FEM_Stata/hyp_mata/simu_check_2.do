clear
capture log close
log using simu_check_2.log, replace
set more off
set mem 100m

set obs 10000
set seed 111139

**Create a normal random variable with mean 5, variance 4**
gen norma = invnorm(uniform())


tempfile temp
save `temp'

quietly{
	foreach theta in 0.1 0.25 0.5 0.75 1{
		foreach omega in 0 0.5{
			clear
			use `temp'
			**Transform our Normal into an Inverse Hyperbolic Sin.**
			egen trans_norma = invgh(norma), theta(`theta') omega(`omega')
			**Estimate Theta and Omega**
			ghreg_ahg2 trans_norma	
			noi disp `theta' "|" `omega' "|" round(e(theta),0.001) "|" round(e(omega),0.001)
		}
	}
}

log close

capt log close
