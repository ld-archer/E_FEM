clear
set obs 5000
set seed 111139
set more off

**Create a normal random variable with mean 0, variance 1**
gen norma = 1*invnorm(uniform()) + 0

**Transform our Normal into an Inverse Hyperbolic Sin.**
egen trans_norma = invgh(norma), theta(0.5) omega(0.5)

ghreg_ahg2 trans_norma
