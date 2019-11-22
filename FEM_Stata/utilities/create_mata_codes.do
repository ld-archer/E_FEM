/** \file

\version 1.0.0
\date 11jun08


*/
  
version 10.0
set more off

mata:
function gsinhinv(numeric matrix u)
{
	return( log(u:+sqrt(u:^2:+1)) ) 
}
mata mosave gsinhinv(), replace
end



mata:
function gsinh(numeric matrix u, theta, omega)
{
	if  (max((gsinhinv(theta:*(u:+omega)) :- gsinhinv(theta:*omega)):/(theta* ( (1+(theta*omega)^2)^(-1/2))) :==.)==1){
		return(u)
	}
	else return(  (gsinhinv(theta:*(u:+omega)) :- gsinhinv(theta:*omega)):/(theta* ( (1+(theta*omega)^2)^(-1/2)))  )
}
mata mosave gsinh(), replace
end


mata:
function ssr(y, x){
	_a = invsym(x'x)
	_b = x'y
	_c = _a*_b
	_d = x*_c
	return(colsum((y-_d):^2))
}
mata mosave ssr(), replace
end

mata:
function betas(y,x)
{
return(invsym(x'x)*x'y)
}
mata mosave betas(), replace
end
	

mata:
void lnll_ahg(todo, p, y, lnf, S, H){

	theta = p[1]
	omega = p[2]	

	lnf = -0.5*log(ssr(gsinh(y[.,1],theta,omega),y[1...,2..cols(y)])) :+ 0.5*log(1+(theta*omega)^2) :- 0.5:*log(1:+(theta:*(y[.,1]:+omega)):^2)

}
mata mosave lnll_ahg(), replace
end

mata:
void opti(string scalar varlist, string scalar touse)
{
V = st_varindex(tokens(varlist))
st_view(y=.,.,V,touse)
S = optimize_init()
optimize_init_evaluator(S, &lnll_ahg())
optimize_init_evaluatortype(S,"v0")
optimize_init_params(S, (1,0))
optimize_init_argument(S, 1, y)
optimize_init_technique(S, "nm")
optimize_init_nmsimplexdeltas(S,(0.1,.1))
P = optimize(S)
Beta = betas(gsinh(y[.,1],P[1,1],P[1,2]),y[1...,2..cols(y)])
st_numscalar("r(theta)",P[1,1])
st_numscalar("r(omega)",P[1,2])
st_numscalar("r(ssr)",ssr(gsinh(y[.,1],P[1,1],P[1,2]),y[1...,2..cols(y)]))
st_matrix("r(B)",Beta)
}
mata mosave opti(), replace
end

	

mata:
void lnuncll_ahg(todo, p, y, lnf, S, H){

	theta = p[1]
	omega = p[2]
	sigma = p[3]
	beta = p[4..cols(p)]	
	e2 = (gsinh(y[.,1],theta,omega):-y[1...,2..cols(y)]*beta'):^2
	
	lnf = -0.5*log(2*pi()) :- 0.5*log(sigma) :- 0.5:*e2:/sigma :+ 0.5*log(1+(theta*omega)^2) :- 0.5:*log(1:+(theta:*(y[.,1]:+omega)):^2)

}
mata mosave lnuncll_ahg(), replace
end


mata:
void opti_unc(string scalar varlist, string inits, string scalar touse, string nmval)
{
inits = st_matrix(inits)
nmval = st_matrix(nmval)
V = st_varindex(tokens(varlist))
st_view(y=.,.,V,touse)
S = optimize_init()
optimize_init_evaluator(S, &lnuncll_ahg())
optimize_init_evaluatortype(S,"v0")
optimize_init_conv_ptol(S, .01)
optimize_init_conv_vtol(S, .01)
optimize_init_params(S, inits)
optimize_init_argument(S, 1, y)
optimize_init_technique(S, "nm")

optimize_init_nmsimplexdeltas(S,nmval)
P = optimize(S)
var = optimize_result_V_oim(S)
st_matrix("e(v)",var)
st_numscalar("e(theta)",P[1,1])
st_numscalar("e(omega)",P[1,2])
st_numscalar("e(ssr)",P[1,3])
st_matrix("e(B)",P[1,4..cols(P)])
}
mata mosave opti_unc(), replace
end

exit, STATA
