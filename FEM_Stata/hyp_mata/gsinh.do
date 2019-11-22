*! version 1.0.0  11jun08
version 10.0
mata:
function gsinh(numeric matrix u, theta, omega)
{
	if  (max((sinh(theta:*(u:+omega)) :- sinh(theta:*omega)):/(theta* ( (1+(theta*omega)^2)^(-1/2))) :==.)==1){
		return(u)
	}
	else return(  (sinh(theta:*(u:+omega)) :- sinh(theta:*omega)):/(theta* ( (1+(theta*omega)^2)^(-1/2)))  )
}

end


mata:
function ssr(y, x){
return(colsum((y-x*invsym(x'x)*x'y):^2))
}
end



mata:
void lnll_ahg(todo, p, y, lnf, S, H){

	theta = p[1]
	omega = p[2]	

	lnf = -0.5*log(ssr(gsinh(y[.,1],theta,omega),y[.,2])) :+ 0.5*log(1+(theta*omega)^2) :- 0.5:*log(1:+(theta:*(y[.,1]:+omega)):^2)

}
end

adopath + "C:\ahg\projects\FEM\hyp_v3"

set obs 10000
set seed 111139

**Create a normal random variable with mean 0, variance 1**
gen norma = 1*invnorm(uniform()) + 0

**Transform our Normal into an Inverse Hyperbolic Sin.**
egen trans_norma = invgh(norma), theta(1) omega(0)

gen one = 1


mata:
st_view(y=.,.,("trans_norma","one"))
S = optimize_init()
optimize_init_evaluator(S, &lnll_ahg())
optimize_init_tracelevel(S,"params")
optimize_init_evaluatortype(S,"v0")
optimize_init_params(S, (1,0))
optimize_init_argument(S, 1, y)
optimize_init_technique(S, "nm")
optimize_init_nmsimplexdeltas(S,(0.1,.1))

P = optimize(S)
P
end
