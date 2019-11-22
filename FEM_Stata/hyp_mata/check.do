adopath + "C:\Documents and Settings\agailey\Desktop\hyp_mata"

clear
set obs 100

gen hi = invnorm(uniform())
egen hello = invgh(hi), theta(1) omega(0)
egen hi2 = gh(hello), theta(1) omega(0)

list in 1/10
