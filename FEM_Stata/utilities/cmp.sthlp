{smcl}
{* *! version 5.2.0 22 April 2012}{...}
{cmd:help cmp}
{hline}{...}

{title:Title}

{pstd}
Conditional (recursive) mixed process estimator{p_end}

{title:Syntax}

{phang}
{cmd:cmp setup}

{phang}
- or -

{phang}
{cmd:cmp} {it:eq} [{it:eq ...}] {ifin} {weight} {cmd:,} {cmdab:ind:icators}({it:{help exp:exp}} [{it:{help exp:exp} ...}])
		[{opt level(#)}
		{opt qui:etly}
		{opt nolr:test}
		{break}{cmdab:red:raws(}# [# ...] ,
		[{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt st:eps(#)}]{cmd:)}
		{opt lf}
		{break}{cmdab:ghkd:raws(}[#]{cmd: , }[{opt anti:thetics} {opt type(string)}]{cmd:)} {opt nodr:op} {opt inter:active} 
		{opt init(vector)} {opt noest:imate} {break} {opt cov:ariance}({it:covopt} [{it:covopt} ...])
		{opt struc:tural} {opt rev:erse} {opt ps:ampling(# #)}
		{it:{help cmp##ml_opts:ml_opts}}
		{opt svy} {it:{help cmp##svy_opts:svy_opts}}]

{phang2}
where {it:covopt} is

{phang3}
{cmdab:un:structured | }{cmdab:ex:changeable | }{cmdab:ind:ependent}

{phang2}
and {it:eq} is

{phang3}
[{it:fe_equation}] [{cmd:||} {it:re_equation}] [{cmd:||} {it:re_equation} ...]

{phang2}
Each {it:fe_equation} is an equation to be estimated, defined largely according to the {help ml model:ml model} {it:eq} syntax. That is, {it:fe_equation} is enclosed in 
parentheses, optionally prefixed with a name for the equation:

{p 12 12 2}
{cmd:(}
	[{it:eqname}{cmd::}]
	{help varname:{it:varname_y}} [{help varname:{it:varname_y2}}] {cmd:=}
	[{it:indepvars}]
	[{cmd:,} {opt nocons:tant} {opth off:set(varname:varname_o)} {opth exp:osure(varname:varname_e)} {opt trunc:points(exp exp)} {opt iia}]
{cmd:)}

{phang2}{it:indepvars} may include factor variables; see {help fvvarlist}.

{phang2}{help varname:{it:varname_y2}} is included only for interval-censored data, in a syntax analogous to that of 
{help intreg:intreg}. {opt trunc:points(exp exp)} is included only for truncated regressions. {opt iia} is meaningful only for
multinomial probit models without alternative-specific regressors.{p_end}

{phang2}
Each {it:exp} in the required {cmdab:ind:icators()} option is an {help exp:expression} that evaluates to a {cmd:cmp} {it:indicator variable}, which communicates required observation-level
information about the dependent variable(s) in the corresponding equation, and can be a constant, a variable name, or a complex mathematical expression. It can contain spaces 
or parentheses if it is double-quoted.
Each {it:exp} must evaluate to 0, 1, 2, 3, 4, 5, 6, 7, 8, or 9, potentially varying by observation. For a multinomial probit equation group with alternative-specific regressors,
the corresponding indicator expressions should all evaluate to 0's and 6's, and should be enclosed in an additional pair of parentheses. The same goes for 
rank-ordered probit groups, except with 9's instead of 6's.

{phang2}
In random effects models, each {it:re_equation} specifies the effects, potentially at multiple levels, according to the syntax 

{p 12 12 2}
{it:{help varname:levelvar}}{cmd::} {weight}

{phang2}
In these models, the {opt red:raws()} option is mandatory.

{pstd}
{cmd:cmp} may be prefixed with {help svy:svy ... :}.

{phang}{cmd:pweight}s, {cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed at all levels; see help {help weights}. Group-level, 
weights, specificed in the {it:re_equation} syntax above, should be constant within groups. Weights for a given level need be specified in just one 
equation.

{pstd}
The syntax of {help predict} following {cmd:cmp} is{p_end}

{phang}{cmd:predict} [{it:type}] {c -(}{it:newvarname}{c |}{it:stub*}{c |}{it:newvarlist}{c )-} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{cmd:,} {it:statistic} {opt eq:uation}{cmd:(}{it:eqno}[{cmd:,}{it:eqno}]{cmd:)}
{opt o:utcome}{cmd:(}{it:outcome}{cmd:)} {opt nooff:set}]

{phang2}where {it:statistic} is {opt xb}, {opt pr}, {opt stdp}, {opt stddp}, {opt lnl}, {opt sc:ores}, {opt re:siduals}, {cmd:e(}{it:a b}{cmd:)}, or {cmd:ystar(}{it:a b}{cmd:)}; and {it:a} and {it:b} 
may be numbers or variables; {it:a} missing ({it:a} {ul:>} {cmd:.}) means minus infinity, and {it:b} missing ({it:b} {ul:>} {cmd:.}) means plus infinity; see {help missing}.

{pstd}{cmd:cmp} shares features of all estimation commands; see help {help estcom}.

{title:Description}

{pstd}
{cmd:cmp} fits a large family of multi-equation, multi-level, conditional recursive mixed-process estimators. Those adjectives are defined as follows:

{p 4 6 0}
* "Multi-equation" means that it can fit Seemingly Unrelated (SUR) and instrumental variables (IV) systems.

{p 4 6 0}
* "Multi-level" means that random effects can be modelled at
various levels in hierarchical fashion, the classic example being a model of education outcomes with unobserved school and class effects. Since the models
can also be multi-equation, random effects at a given level are allowed by default to be correlated across equations. E.g., school and class 
effects may be correlated across outcomes such as math and readings scores. Effects at different levels, however, are assumed uncorrelated
with each other and with the observation-level errors.{p_end}

{p 4 6 0}
* "Mixed process" means that different equations can have different kinds of 
dependent variables (response types). The choices, all generalized linear models with a Gaussian error distribution, are: continuous and unbounded (the classical linear regression 
model), tobit (left-, right-, or bi-censored), interval-censored, truncated (on the left and/or right), probit, ordered probit, multinomial 
probit, and rank-ordered probit. A dependent variable in one equation can appear on the right side of another equation.

{p 4 6 0}
* "Recursive" means, however, that {cmd:cmp} can only fit sets of equations with clearly defined stages, 
not ones with simultaneous causation. {it:A} and {it:B} can be modeled determinants of {it:C} and {it:C} a determinant of {it:D}--but {it:D} cannot be a 
modeled determinant of {it:A}, {it:B}, or {it:C}.

{p 4 6 0}
* "Conditional" means that the model can vary by observation. An equation can be dropped for observations for which it is not relevant--if, say, a worker
retraining program is not offered in a city then the determinants of uptake cannot be modeled there. The type of a dependent variable can even vary by 
observation.

{pstd}
Broadly, {cmd:cmp} is appropriate for two classes of models: 1) those in which a truly recursive data-generating process is posited; and 2) those in which
there is simultaneity, but instruments allow the construction of a recursive set of equations, as in two-stage least squares, that can be used to consistently 
estimate structural parameters in the final stage. In the first case, {cmd:cmp} is a full-information maximum likelihood (FIML) estimator, and all estimated
parameters are structural. In the latter, it is a limited-information (LIML) estimator, and only the final stage's coefficients are structural, the rest
being reduced-form parameters. What matters for the validity of {cmd:cmp} is that the {it:system of equations} is recursive, whether or not the model is.

{pstd}
{cmd:cmp}'s modeling framework embraces those of the official Stata commands {help probit:probit}, {help ivprobit:ivprobit}, {help treatreg:treatreg}, 
{help biprobit:biprobit}, {help tetrachoric:tetrachoric}, {help oprobit:oprobit}, {help mprobit:mprobit}, {help asmprobit:asmprobit}, {help asroprobit:asroprobit}, {help tobit:tobit}, {help ivtobit:ivtobit}, 
{help cnreg:cnreg}, {help intreg:intreg}, {help truncreg:truncreg}, {help heckman:heckman}, {help heckprob:heckprob}, 
{help xtreg:xtreg}, {help xtprobit:xtprobit}, {help xttobit:xttobit}, {help xtinteg:xtintreg}, in principle even {help regress:regress}, 
and {help sureg:sureg}, as well as the user-written {stata findit ssm:ssm}, {stata findit polychoric:polychoric}, {stata findit triprobit:triprobit}, 
{stata findit mvprobit:mvprobit}, {stata findit bitobit:bitobit}, 
{stata findit mvtobit:mvtobit}, {stata findit oheckman:oheckman}, {stata findit switch_probit:switch_probit}, and (in its "non-endogenous" mode) {stata findit bioprobit:bioprobit}. It goes beyond them 
in several ways. Thanks to the flexibility of {help ml:ml}, on which it is built, it accepts coefficient {help constraint:constraints}
as well as all weight types, vce types (robust, cluster, linearized, etc.), and {cmd:svy} settings. And it offers 
more flexibility in model construction. For example, one can regress a continuous variable on two endogenous variables, 
one binary and the other sometimes left-censored, instrumenting each with additional variables. And {cmd:cmp} usually allows the model to vary by observations.
Equations can have different samples, overlapping or non-overlapping. Heckman selection modeling can be incorporated into a wide variety of models through auxilliary
probit equations. In some cases, the gain is consistent estimation where it was difficult before. Sometimes the gain is in efficiency.
For example if {it:C} is continuous, {it:B} is a sometimes-left-censored determinant of {it:C}, and {it:A} is an instrument, then the effect of {it:B} on {it:C} can be
consistently estimated with 2SLS (Kelejian 1971). However, a {cmd:cmp} estimate that uses the information that {it:B} is censored will be more efficient, based as it
is on a more accurate model.

{pstd}
As a matter of algorithm, {cmd:cmp} is an SUR (seemingly unrelated regressions) estimator. It treats the equations as independent from each other except for 
modeling their underlying errors as jointly normally distributed. Mathematically, the likelihood it computes is conditioned on observing {it:all} right-side
variables, including those that also appear on the left side of equations.
However, it can actually fit a much larger class of models. Maximum likelihood (ML) SUR estimators, including {cmd:cmp}, are appropriate for 
many simultaneous equation models, in which endogenous variables appear on the right side of structural equations as well as the 
left. Models of this kind for which ML SUR is  consistent must satisfy two criteria: 

{pin}
1) They are recursive. In other words, the equations can be arranged so that the matrix of coefficients of
the dependent variables in each others' equations is triangular. As emphasized above, this means the models have clearly defined stages, though there can be more than one
equation per stage.

{pin}
2) They are "fully oberved." Dependent 
variables in one stage enter subsequent stages only as observed. Returning to the example in the first paragraph, if {it:C} is a categorical 
variable modeled as ordered probit, then {it:C}, not the latent variable underlying it, call it {it:C*}, must figure in the model for {it:D}. 

{pstd}
As an illustration of the ideas here, some Stata estimation commands have wider applicability than many realize. {cmd:sureg (X=Y) (Y=Z), isure} typically 
matches {cmd:ivregress 2sls X (Y=Z)} exactly even though 
the documentation does not describe {help sureg:sureg} as an instrumental variables (IV) estimator. 
(Iterated SUR is not a true ML estimator, but it converges to the same solution as ML-based SUR, as implemented, for example, in the demonstration command 
{browse "http://www.stata-press.com/data/ml3.html":mysureg}. See Pagan (1979) on the LIML-iterated SUR connection.) And 
{cmd:biprobit (X=Y) (Y=Z)} will consistently estimate an IV model in which {it:X} and {it:Y} are binary.

{pstd}
To inform {cmd:cmp} about the natures of the dependent variables and about which equations apply to which observations, the user must include the 
{cmdab:ind:icators()} option after the comma in the {cmd:cmp} command line. This must contain one expression for each equation. The expression can 
be a constant, a variable name, or a more complicated mathematical formula. Formulas that contain spaces or parentheses should be enclosed in 
quotes. For each observation, each expression must evaluate to one of the following codes, with the meanings shown:

{pin}0 = observation is not in this equation's sample{p_end}
{pin}1 = equation is "continuous" for this observation, i.e., has the OLS likelihood or is an uncensored observation in a tobit equation{p_end}
{pin}2 = observation is left-censored for this (tobit) equation at the value stored in the dependent variable{p_end}
{pin}3 = observation is right-censored at the value stored in the dependent variable{p_end}
{pin}4 = equation is probit for this observation{p_end}
{pin}5 = equation is ordered probit for this observation{p_end}
{pin}6 = equation is multinomial probit for this observation{p_end}
{pin}7 = equation is interval-censored for this observation{p_end}
{pin}8 = equation is truncated on the left and/or right for this observation{p_end}
{pin}9 = equation is rank-ordered probit for this observation{p_end}

{pstd}
For clarity, users can execute the {cmd:cmp setup} subcommand, which defines global macros that can then be used in {cmd:cmp} command lines:

{pin}$cmp_out = 0{p_end}
{pin}$cmp_cont = 1{p_end}
{pin}$cmp_left = 2{p_end}
{pin}$cmp_right = 3{p_end}
{pin}$cmp_probit = 4{p_end}
{pin}$cmp_oprobit = 5{p_end}
{pin}$cmp_mprobit = 6{p_end}
{pin}$cmp_int = 7{p_end}
{pin}$cmp_trunc = 8{p_end}
{pin}$cmp_roprobit = 9{p_end}

{pstd}
Since {cmd:cmp} is a Maximum Likelihood estimator built on {help ml:ml}, equations are specified according to the {cmd:ml model} 
syntax. This means that for instrumented regressions, {cmd:cmp} differs from {help ivregress:ivregress}, {help ivprobit:ivprobit}, 
{help ivtobit:ivtobit}, and similar commands
in not automatically including exogenous regressors (included instruments) from the second stage in the first stage. So you must arrange for this 
yourself. For example, {cmd:ivreg y x1 (x2=z)} corresponds to {cmd:cmp (y=x1 x2) (x2=x1 z), ind($cmp_cont $cmp_cont)}.

{pstd}
In order to model random effects, {cmd:cmp} borrows syntax from {help xtmixed:xtmixed}. It is best explained with examples.
This {it:eq} specifies an equation with two levels of random effects corresponding to groups defined by the variables {cmd:school} and 
{cmd:class}:

{pin}(math = age || school: || class:)

{pstd}
({cmd:school}, coming first, is understood to be "above" {cmd:class} in the hierarchy.) At a given level, random effects can be 
assumed present in some equations and not others. Those in more than one equation at a given level are assumed to be (potentially) correlated
across equations (an assumption that can be overridden through constraints or the {opt cov:ariance()} option). This specifies a school effect only for math but not reading scores,
and potentially correlated class effects for both:

{pin}(math = age || school: || class:) (reading = age || class:){p_end}

{pstd}
Weights of various types may be specified at each level. These should be defined by variables or expressions that are constant within each group
of the given level. Within a given group, {cmd:aweight}s and {cmd:pweight}s are rescaled to sum to the number of groups in the next level 
down (or number of observations if it is the bottom level). {cmd:pweight}s imply {cmd:vce(cluster {it:groupvar})} where 
{it:groupvar} defines the highest level in the hierarchy having 
{cmd:pweight}s. {cmd:iweight}s and {cmd:fweights}s are not rescaled; the latter affect the reported sample size. Since weights must be the same 
across equations, they need be specified only once for each level. So these are equivalent:

{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class:){p_end}
{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class: [pw=weightvar1]){p_end}

{pstd}
and the contradiction here would cause an error:

{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class: [pw=weightvar2]){p_end}

{pstd}
Unlike {help xtreg:xtreg}, {help xtprobit:xtprobit}, {help xttobit:xttobit}, {help xtinteg:xtintreg}, {help xtmixed:xtmixed}, and {stata findit gllamm:gllamm},
which use quadrature to integrate likelihoods over the unobserved random effects (see {manhelp xtmixed R}), {cmd:cmp} uses simulation. This
involves making many draws from the hypothesized normal distributions of the effects, computing the implied likelihood for each set of draws, then averaging 
(Train 2009; Greene 2011, chap 15).
To govern the simulation, random effects models in {cmd:cmp} must include the {cmdab:red:raws()} option. This sets the number of draws per observation
at each level,
the type of sequence (Halton, Hammersley, generalized Halton, pseudorandom), and whether antithetics are also drawn. (See Gates 2006 for more on these concepts.)
For (generalized) Halton and Hammersley sequences, it is preferable to make the number of draws prime, to insure more variable coverage of the
distribution from observation to observation, making coverage more uniform overall. Increasing the 
number of draws increases precision at the expense of time. In a bid for speed, by default, {cmd:cmp} begins by estimating
with just 1 draw per observation and random effect (plus the antithetics if specified). It uses the result of this rough search as the starting point for an
estimate with more draws, then repeats, multiplying by approximately {it:e} each time until reaching the specified number of draws. The {opt st:eps(#)} suboption 
of {cmdab:red:raws()} can override the default number of steps, which is approximately 1+ln(full # of draws). {cmd:redraws(50 50, steps(1))} would 
specify immediate estimation with the full 50
draws per observation in a three-level model (with two levels of random effects). See {help cmp##options:options} below for more. 

{pstd}
Estimation problems with observations that are censored in three or more equations, 
such as a trivariate probit, require calculation of cumulative 
joint normal distributions of dimension three or higher. This is a non-trivial problem. The preferred technique again involves simulation:
the method of
Geweke, Hajivassiliou, and Keane (GHK). (Greene 2011; Cappellari and Jenkins 2003; Gates 2006). {cmd:cmp} accesses the algorithm 
through the separately available Mata function {stata findit ghk2:ghk2()}, which must be installed for {cmd:cmp} to work. 
Modeled on the built-in {help mf_ghk:ghk()} and {help mf_ghkfast:ghkfast()}, {stata findit ghk2:ghk2()} gives users choices about the length and nature of the 
sequences generated for the simulation,
which choices {cmd:cmp} passes on through the optional {cmdab:ghkd:raws()} option, which includes {cmd:type()} and {cmdab:anti:thetics()} 
suboptions. See {help cmp##options:options}
below for more.

{pstd}
For both domains of simulation--random effects and cumulative normal distributions estimated with the GHK algorithm---each observation or group
gets its own sequence of draws. Thus changing the order of the observations in the data set will change the estimation 
results--one hopes only slightly.
If using pseudorandom sequences ({cmd:ghktype(random)}) or generalized Halton ones ({cmd:ghktye(ghalton)}), the state of the 
Stata random number generator also slightly influences the results. For
exact reproducibility of your results with these sequences, initialize the seed to some chosen value with the {help generate:set seed} command each time before 
running {cmd:cmp}. Estimations that require simulation can run much more slowly than those that do not.

{pstd}
{cmd:cmp} starts by fitting each equation separately in order to obtain a good starting point for the full model fit.
Sometimes in this preparatory step, convergence difficulties make a reported parameter covariance matrix singular, yielding missing 
standard errors for some regressors. Or variables are found to be collinear. In order to maximize the chance of convergence, {cmd:cmp} ordinarily 
drops such regressors from the equations in which they cause trouble, reruns the single-equation fit, and then leaves them out for the full model too. The 
{opt nodr:op} option prevents this behavior.

{title:On estimation with interval-censored or truncated equations}

{pstd}
For equations with interval-censored observations, list two variables before the {cmd:=}, somewhat following the syntax of {help intreg:intreg}. For 
example, {cmd:cmp (y1 y2 = x1 x2), ind($cmp_int)} indicates that the dependent variable is censored to intervals whose lower bounds are in y1 and upper
bounds are in y2. Missing values in y1 are treated as -infinity and those in y2 are treated as +infinity. For observations in which y1 and y2 coincide, there
is no censoring, and the likelihood is the same as for {cmd:$cmp_cont}.

{pstd}
For equations with truncated distributions, use the {opt trunc:points(exp exp)} option--within the specification for the 
given equation, not at the end of the command line--to provide truncation points. Like indicator expressions, the truncation points can be constants,
expressions, or variable names, with missing values interpreted the same as above. Observations in which the observed value lies outside the truncation 
range are automatically dropped for that equation. An example is below.

{marker mprobit}{...}
{title:On estimation with multinomial probit equations}

{pstd}
Multinomial probits can be specified with two different syntaxes, roughly corresponding to the Stata commands {help mprobit:mprobit} and 
{help asmprobit:asmprobit}. In
the first syntax, the user lists a single equation, just as for other dependent variable types, and puts a 6 ({cmd:$cmp_mprobit}) in the
{cmdab:ind:icators()} list. The dependent variable holds the choice made in each case. Like 
{help mprobit:mprobit}, {cmd:cmp} treats all regressors as determinants of choice for all alternatives. In particular,
it expands the specified equation to a group with one "utility" equation for each possible choice. All equations in the group include all regressors, except for the first, 
which has none. This one corresponds to the lowest value of the dependent variable, which is taken as the base alternative. The next, corresponding to the 
second-lowest value, is the "scale alternative," meaning that to normalize results, the variance of its error term is fixed. (The value it is fixed at
depends on whether the {opt struc:tural} option is invoked, on which see below.) In the first syntax, 
the single {it:eq} can contain an {opt iia} option after the comma so that {cmd:cmp}, like {help mprobit:mprobit}, will impose the Independence of 
Irrelevant Alternatives assumption. I.e., {cmd:cmp} will assume
that errors in the utility equations are uncorrelated and have unit variance.

{pstd}
Such models, ones without exclusion restrictions and without the IIA assumption, are formally identified as long as at least one regressor varies over 
alternatives (Keane 1992). However, Keane emphasizes that fits for such models tend to be unstable if there are no exclusion 
restrictions. There are two ways to impose exclusion restrictions with {cmd:cmp}. First, as with {help mprobit:mprobit}, you can use {help constraint:constraints}.

{pstd}
Second, you can use {cmd:cmp}'s other multinomial
probit syntax. In this "alternative-specific" syntax, you list one equation in the {cmd:cmp} command line for each alternative, including the base alternative. Different equations may include different
regressors. Unlike {help asmprobit:asmprobit}, {cmd:cmp} does not force regressors that appear in more than one equation 
to have the same coefficient across alternatives, although again this restriction can be imposed through {help constraint:constraints}. When using
the alternative-specific syntax, the dependent variables listed should be a set of {it:dummies}, as can be generated with {help xi:xi, noomit} from the 
underlying choice variable. The first equation is always treated as the base alternative, so here you can control which alternative is the base alternative,
by reordering the equations. In 
general, regressors that appear in all other equations should be excluded from the base alternative. Otherwise, unless a constraint is imposed to reduce the degrees
of freedom, the model will not be identified. ({cmd:cmp} automatically excludes the constant from the base alternative equation.) Variables that are specific 
to the base alternative, however, or to a strict subset of alternatives, can be included in the base alternative equation.  In the second syntax, the IIA is not 
assumed, nor available through an option. It can still be imposed through constraints.

{pstd}
To specify an alternative-specific multinomial probit group, include expressions in the {cmdab:ind:icators()} that evaluate to 0 or 6 
({cmd:$cmp_out} or {cmd:$cmp_mprobit}) for each equation (0 indicating that the choice is not available for given observations). You must enclose the 
whole list in 
an additional set of parentheses. Note that unlike with {help asmprobit:asmprobit}, there should be still be one row in the data set per case, not per case and
alternative. So instead of variables that vary by alternative, there must be a version of that variable for each
alternative--not a single travel time variable that varies by mode of travel, but an air travel time variable, a bus travel time variable, and so 
on. An alternative-specific multinomial example is also below.

{pstd}
In a multinomial probit model with J choices, each possible choice has its own structural equation, including an error term. These error terms have some 
covariance structure. It is impossible, however, to estimate all the entries of the JxJ covariance matrix (Train 2003; 
{browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)}). What is used
in the computation of the likelihood is the (J-1)x(J-1) covariance matrix of the differences of the non-base-alternative errors from the base-alternative error. So by 
default, {cmd:cmp}, much like {help asmprobit:asmprobit}, interprets the sigma and rho parameters relating to these equations as characterizing these 
{it:differenced} errors. To eliminate an excessive degree of scaling freedom, it constrains
the error variance of the first non-base-alternative equation (the "scaling alternative") to 2, which it would be anyway if the errors for the first two 
structural equations were i.i.d. standard normal (so that their difference has variance 2). 

{pstd}
The disadvantage of this parameterization is that it is hard to think about if you want to impose additional constraints on it. As an alternative,
{cmd:cmp}, like {help asmprobit:asmprobit}, offers a {opt struc:tural} option. When this is included, {cmd:cmp} creates a full set of parameters
to describe the covariance of the J structural errors. To remove the excessive degrees of freedom, it then constrains the base alternative error to have 
variance 1 and no correlation with the other errors; and constrains the error for the second, scaling alternative to also have variance 1. To impose the
IIA under this option, one would then constrain various "atanhrho" and "lnsig" parameters to 0. An example below shows how to estimate the same IIA model
with and without the structural parameterization.

{pstd}
The intuitiveness of the structural parameterization comes at a real cost, however (Bunch (1991); 
{browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)}, pp. 325-29). Though the particular set of 
constraints imposed seems innocent, it actually results in a mapping from the space of allowed structural covariances to the space of possible 
covariance matrices for the relative-differenced errors that is not {it:onto}. That is, there are positive definite (J-1)x(J-1) matrices,
valid candidates for the covariance of the relative-differenced errors, which are not compatible with the assumptions that the first two alternatives'
structural errors have variance one {it:and} that the first, base alternative's error is uncorrelated with all other structural errors. So the {opt struc:tural}
option can prevent {cmd:cmp} from reaching the maximum-likelihood 
fit. {browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)} describe how changing which 
alternatives are the base and scaling alternatives, by reording the equations, can sometimes free an estimator to find the true maximum within the {opt struc:tural}
parametrization.

{marker roprobit}{...}
{title:On estimation with rank-ordered probit equations}

{pstd}
Specification and treatment of rank-ordered probit equations is nearly identical to that in the second syntax for multinomial probits described just
above. Equations must be listed for every alternative. Indicators for these equations must be either 0 or 9 ({cmd:$cmp_out} or {cmd:$cmp_roprobit}) for 
each observation, and grouped in an extra set of parentheses. Constraints defining the base and scale alternatives are automatically imposed in the same way. The {cmd:structural} option too
works identically. One option relating specifically to rank-ordered probit is {cmd:reverse}. It instructs {cmd:cmp} to interpret lower-numbered
rankings as higher instead of lower.

{marker tips}{...}
{title:Tips for achieving and speeding convergence}

{pstd}
If you are having trouble achieving (or waiting for) convergence with {cmd:cmp}, these techniques might help:

{phang2}1. Changing the search techniques using {cmd:ml}'s {help ml##model_options:technique()} option, or perhaps the search parameters, through its
{help ml##ml_maxopts:maximization options}. {cmd:cmp} accepts all these and passes them on to {cmd:ml}. The default Newton-Raphson search method 
usually works very well once {cmd:ml} has found a concave region. The DFP algorithm ({cmd:tech(dfp)}) often works better before then, and the two
can be mixed, as with {cmd:tech(dfp nr)}. See the details of the {cmd:technique()} option at {help ml}.{p_end}
{phang2}2. If the estimation problem requires the GHK algorithm (see above), change the number of draws per observation in the simulation sequence using 
the {opt ghkd:raws()} option. By default, {cmd:cmp} uses twice the square root of the number of observations for which the 
GHK algorithm
is needed, i.e., the number of observations that are censored in at least three equations. Raising simulation accuracy by increasing the number of 
draws is 
sometimes necessary for convergence and can even speed it by improving search precision. On the other hand, especially when the number of observations is
high, convergence can be achieved, at some loss in precision, with remarkably few draws per observations--as few as 5 when the sample size is 10,000 (Cappellari and Jenkins
2003). And taking more draws can also greatly extend execution time.{p_end}
{phang2}3. If getting many "(not concave)" messages, try the {opt diff:icult} option, which instructs {cmd:ml} to 
use a different search algorithm in non-concave regions.{p_end}
{phang2}4. If the search appears to be converging in likelihood--if the log likelihood is hardly changing in each iteration--and yet fails to converge, try 
adding a {opt nrtol:erance(#)} or {opt nonrtol:erance} option to the command line after the comma. These are {cmd:ml} options that control when convergence is declared. (See
{help cmp##ml_opts:ml_opts}, below.) By default, {cmd:ml} declares convergence when the log likelihood is changing very little with successive iterations (within
tolerances adjustable with the {opt tol:erance(#)} and {opt ltol:erance(#)} options) {it:and} when the calculated gradient vector is close enough to zero. 
In some difficult problems, such as ones with nearly collinear regressors, the imprecision of floating point numbers prevents {cmd:ml} from quite satisfying the second criterion. 
It can be loosened by using the {opt nrtol:erance(#)} to set the scaled gradient tolerance to a value larger than its default of 1e-5, or eliminated altogether
with {opt nonrtol:erance}. Because of the risks of collinearity, {cmd:cmp} warns when the condition number of an equation's regressor matrix exceeds 20 (Greene 2000, p. 40).{p_end}
{phang2}5. Try {cmd:cmp}'s interactive mode, via the {opt inter:active} option. This
allows the user to interrupt maximization by hitting Ctrl-Break or its equivalent, investigate and adjust the current solution, and then restart
maximization by typing {help ml:ml max}. Techniques for exploring and changing the current solution include displaying the current coefficient and gradient vectors 
(with {cmd:mat list $ML_b} or {cmd:mat list $ML_g}) and running {help ml:ml plot}. See {help ml:help ml}, {bf:[R] ml}, and 
{browse "http://books.google.com/books?id=tNhbjQIOKVYC&printsec=frontcover":Gould, Pitblado, and Sribney (2006)} for
details. {cmd:cmp} is slower in interactive mode.
 

{marker options}{...}
{title:Options}

{phang}{cmdab:ind:icators}({it:{help exp:exp}} [{it:{help exp:exp} ...}]) is required. It should pass a list of expressions that evaluate to 0, 1, 2, 3, 
4, 5, 6, 7, 8, or 9 for every 
observation, with one expression for each equation and in the same order. Expressions can be constants, variable names, or 
formulas. Individual formulas that contain spaces or parentheses should be enclosed in quotes.

{phang}{opt level(#)} specifies the confidence level, in percent,
for confidence intervals of the coefficients; see {help level:help level}. The default is 95.

{phang}{opt qui:etly} suppresses most output: the results from any single-equation initial fits and the iteration log during the full model fit.

{phang}{opt nolr:test} suppresses calculation and reporting of the likelihood ratio (LR) test of overall model fit, relative to
a constant(s)-only model. This has no effect if data are {cmd:pweight}ed or errors are {cmd:robust} or {cmd:cluster}ed.
In those cases, the likelihood function does not reflect the non-sphericity of the errors, and so is a pseudolikelihood. The
LR test is then invalid and is not run anyway.

{phang}{cmdab:red:raws(}# [# ...] , [{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt st:eps(#)}]{cmd:)} is required for random effects models.
It governs the simulation-based estimation of them. The option should begin with one number (#) for each level of the model above the base (e.g., two numbers
in a three-level model); these specify the number of draws per observation from the simulated distributions of the random effects. The optional 
{opt type()} suboption sets the sequence type; the default is halton. The optional {opt anti:thetics} suboption doubles the number of draws
at all levels by including antithetics. For more on these concepts, see See Drukker and Gates (2006). The optional {opt st:eps(#)} 
suboption set the number of times to fit the model as the number of draws
at each level is geometrically increased to the specified final values. The preliminary runs all use the Newton-Raphson search algorithm
and {help ml:ml}'s {cmd:nonrtolerance tolerance(0.1)} options in order to accept coarse fits. This stepping is meant 
only to increase speed by using fewer draws until the search is close to the maximum. It can be disabled with {cmd:steps(1)}.

{phang}{opt lf} makes {cmd:cmp} use its lf-method evaluator instead of its d2-method one (for Stata 10 or earlier) or lf1-method one (Stata 11 or
later). This forces {cmd:cmp} to compute first derivatives of the likelihood numerically instead of analytically, which substantially
slows estimation but occassionally improves convergence.

{phang}{cmdab:ghkd:raws(}[#]{cmd: , }[{opt anti:thetics} {opt type(halton | hammersley | ghalton | random)}]{cmd:)} governs the draws used in GHK simulation of 
higher-dimensional cumulative multivariate normal distributions. It is similar to the {opt red:raws} option. However, it takes at most one number;
if it, or the entire option, is omitted, the number of draws is set rather arbitrarily to twice the square root of the number of observations 
for which the simulation is needed. (Simulated maximum likelihood is consistent as long as the number of draws rises with the square root of the 
number of observations. In practice, a higher number of observations often reduces the number of draws per observation needed
for reliable results. Train 2009, p. 252.) The {opt anti:thetics} requests antithetic draws, which effectively doubles the number of draws.
The {opt type(string)} suboption specifies the type of sequence in the GHK simulation, {cmd:halton} being the default.

{phang}{opt nodr:op} prevents the dropping of regressors from equations in which they receive missing standard errors in initial single-equation 
fits. It also prevents the removal of collinear variables.

{phang}{opt cov:ariance}({it:covopt} [{it:covopt} ...]) offers shorthand ways to constrain the correlation structure of the errors at each 
level--shorthand, that is, compared to using {help constraint:constraint}. There should be one {it:covopt} for each level in the model,
and each can be {cmdab:un:structured}, {cmdab:ex:changeable}, or {cmdab:ind:ependent}. {cmdab:un:structured}, the default, imposes no 
constraint. {cmdab:ex:changeable} specifies that all pairwise correlations at a given level are the same. {cmdab:ind:ependent} 
sets them to zero.

{phang}{opt inter:active} makes {cmd:cmp} fit the full model in {help ml:ml}'s interactive mode.
This allows the user to interrupt the model fit with Ctrl-Break or its equivalent, view and adjust the trial solution with such 
commands as {help ml:ml plot}, then restart optimization by typing {help ml:ml max}. See {help ml:help ml}, {bf:[R] ml}, and 
{browse "http://books.google.com/books?id=tNhbjQIOKVYC&printsec=frontcover":Gould, Pitblado, and Sribney (2006)} for 
details. {cmd:cmp} runs more slowly in interactive mode.

{phang}{opt init(vector)} passes a row vector of user-chosen starting values for the full model fit, in the manner of the {help ml: ml init, copy} 
command. The vector must contain exactly one element for each parameter {cmd:cmp} will estimate, and in the same order as {cmd:cmp} reports the parameter estimates
in the output. Thus, at the end will be the initial guesses for the lnsig_{it:i} parameters, then those for the atanhrho_{it:ij}, then those
for any ordered-probit cuts. ({cmd:cmp} normally also 
reports sig_{it:i}'s and rho_{it:ij}'s, but these are not additional parameters, merely transformed versions of underlying ones, and should be ignored in building
the vector of starting values.) The names of the row and columns of the vector do
not matter.

{phang}{opt noest:imate} simplifies the job of constructing an initial vector for the {opt init()} option. It instructs {cmd:cmp} to stop before fitting the full model and
leave behind an e(b) return vector with one labeled entry for each free parameter. To view this vector, type {stata "mat list e(b)"}. You can copy or edit this vector, such as 
with "mat b=e(b)", then pass it back to {cmd:cmp} with the {opt init()} option.

{phang}{opt struc:tural} forces the structural covariance parameterization for all multinomial and rank-ordered equation groups. See {help cmp##mprobit:above} for more.

{phang}{opt rev:erse} instructs {cmd:cmp} to interpret lower-numbered ranks in rank-ordered probit equations as being higher.

{phang}{opt ps:ampling(# #)} makes {cmd:cmp} perform "progressive sampling," which can speed estimation on large data sets. First it estimates on 
a small subsample, then a larger one, etc., until reaching the full sample. Each iteration uses the previous one's estimates as a starting point.
The first argument in the option sets the initial sample size, either in absolute terms (if it is at least 1) or as a fraction of 
the full sample (if it is less than 1). The second argument is the factor by which the sample should grow in each iteration. This process is 
analogous to but distinct from the stepping that occurs by default in simulating random effects.

{marker ml_opts}{...}
{phang}{it:ml_opts}: {cmd:cmp} accepts the following standard {help ml:ml} options: {opt tr:ace}
	{opt grad:ient}
	{opt hess:ian}
	{cmd:showstep}
	{opt tech:nique(algorithm_specs)}
	{cmd:vce(}{cmd:oim}|{cmdab:o:pg}|{cmdab:r:obust}|{cmdab:cl:uster}{cmd:)}
	{opt iter:ate(#)}
	{opt tol:erance(#)}
	{opt ltol:erance(#)}
	{opt gtol:erance(#)}
	{opt nrtol:erance(#)}
	{opt nonrtol:erance}
	{opt shownrt:olerance}
	{cmdab:dif:ficult}
	{opt const:raints(clist)}
	{cmdab:sc:ore:(}{it:newvarlist}|{it:stub}*{cmd:)}

{marker ml_opts}{...}
{phang}{opt svy} indicates that {cmd:ml} is to pick up the {opt svy} settings set
by {cmd:svyset} and use the robust variance estimator. This option
requires the data to be {helpb svyset}. {opt svy} may
not be specified with {cmd:vce()} or {help weight}s. See {help svy estat:help svy estat}.

{phang}{it:svy_opts}: Along with {cmd:svy}, users may also specify any of these related {help ml:ml} options, which affect how the svy-based
variance is estimated:
	{cmdab:nosvy:adjust}
	{cmdab:sub:pop:(}{it:subpop_spec}{cmd:)}
	{cmdab:srs:subpop}. And users may specify any of these {help ml:ml} options, which affect output display: {cmd:deff}
	{cmd:deft}
	{cmd:meff}
	{cmd:meft}
	{cmdab:ef:orm}
	{cmdab:p:rob}
	{cmd:ci}. See {help svy estat:help svy estat}. 

{title:On {help predict:predict} and {help mfx:mfx} after cmp}

{pstd}Options for {cmd:predict} after {cmd:cmp} are:

{synoptset 25 tabbed}{...}
{synopt :{opt eq:uation}{cmd:(}{it:eqno}[{cmd:,}{it:eqno}]{cmd:)}}specify equation(s){p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt stdp}}standard error of linear prediction{p_end}
{synopt :{opt stddp}}standard error of difference in linear predictions{p_end}
{synopt :{opt lnl}}observation-level log likelihood (in hierarchical models, averaged over groups){p_end}
{synopt :{opt sc:ores}}derivative of the log likelihood with respect to xb or parameter{p_end}
{synopt :{opt re:siduals}}calculate the residuals{p_end}
{synopt :{opt pr}}probability of a positive outcome (meant for probit equations){p_end}
{synopt :{opt e(# #)}}censored expected value (see {help regress postestimation##predict:help regress postestimation}){p_end}
{synopt :{opt y:star(# #)}}truncated expected value (see {help regress postestimation##predict:help regress postestimation}){p_end}
{synopt :{opt o:utcome}{cmd:(}{it:outcome}{cmd:)}}specify outcome(s), for ordered probit only{p_end}
{synopt :{opt nooff:set}}ignore any {opt offset()} or {opt exposure()} variable{p_end}

{pstd}
Note that the {opt e(# #)} and {opt y:star(# #)} options should not include a comma between the two bounds.

{pstd}
{it:eqno} can be an equation name (if not set explicitly, an equation's name is that of its dependent variable). Or it can be an equation number preceded by a 
{cmd:#}. The default equation is #1, unless the provided variable list has one entry for each equation, or takes the form {it:stub*}. These request 
prediction variables for all equations, with names as given or as automatically generated beginning with {it:stub}. 

{pstd}
In contrast, for ordered probit equations, if {cmd:pr} is specified, {cmd:predict} will by default compute probability variables for all outcomes. The
names for these variables will be automatically generated using a provided variable name as a stub. This stub may be directly provided in the command line--in which case
it should {it:not} include a {cmd:*}--or may itself be automatically generated by a cross-equation {it:stub*}. Thus it is possible to generate probabilities
for all outcomes in all ordered probit equations with a single, terse command. Alternatively, the {opt o:utcome}{cmd:(}{it:outcome}{cmd:)}
option can be used to request probabilities for just one outcome. {it:outcome} can be a value for the dependent variable, or a category number preceded by a {cmd:#}. 
For example, if the categorical dependent variable takes the values 0, 3, and 4, then {cmd:outcome(4)} and {cmd:outcome(#3)} are synonyms. ({cmd:outcome()}
also implies {cmd:pr}.)

{pstd}
In explaining the multi-equation and -outcome behavior of {help predict:predict} after {cmd:cmp}, {help cmp##predict_egs:examples} are worth a thousand words.

{pstd}
The flexibility of {cmd:cmp} affects the use of {help predict:predict} and {help mfx:mfx} after estimation. Because the censoring type (probit, tobit, etc.) can technically
vary by observation, the default statistic for {help predict:predict} is always {cmd:xb}, linear fitted values. This is unlike for {help probit:probit} and {help oprobit:oprobit}, after which
the default is {cmd:pr}, predicted probabilities of outcomes. So to obtain probilities predicted by (ordered) probit equations, remember to include the 
{cmd:pr} option in the {help predict:predict} command line or {cmd:predict(pr)} in the {help mfx:mfx} command line. (For ordered probit equations, 
an {cmd:outcome()} option will also imply {cmd:pr}.)

{pstd}
To maintain a consistent mathematical structure and simplify the code, {cmd:cmp} sometimes retains a superfluous parameter but constrains it to 0. Such a parameter looks
to {help mfx:mfx} like an "equation with all zero coefficients". To make {help mfx:mfx} work correctly in such situations, include the {cmd:nonlinear} option.
At times, users running pre-January 22, 2008 versions of {cmd:mfx} may also need to include the {cmd:force} option. Since marginal effects should depend only on the estimated
coefficients and the right-hand-side variables, as a preliminary diagnostic, old versions of {cmd:mfx} temporarily destroy the left-side variables of {it:all} equations to confirm that this
has no effect on predicted outcomes. But if any of those varibles also appear on the {it:right} side of the equation of interest, overwriting the variable will indeed
affect predictions. This causes {cmd:mfx} to refuse to estimate standard errors. {cmd:force} may be needed when running old versions of {cmd:mfx} to stop this behavior.

{pstd}
Examples of {help predict:predict} and {help mfx:mfx} after {cmd:cmp} are below.

{title:Citation}

{p 4 8 2}{cmd:cmp} is not an official Stata command. It is a free contribution to the research community.
Please cite it as such: {p_end}
{p 8 8 2}Roodman, D. 2011. Estimating fully observed recursive mixed-process models with cmp. {it:Stata Journal} 11(2): 159-206.{p_end}

{title:Published examples}
See {browse "http://scholar.google.com/scholar?oi=bibs&hl=en&cites=1278092567509554980":Google Scholar}.

{title:Introductory examples}

{pstd}The purpose of {cmd:cmp} is not to match standard commands, but to fit models otherwise beyond easy estimation in Stata. But replications 
illustrate how {cmd:cmp} works (colored text is clickable):

{phang}{cmd:* Define indicator macros for clarity.}{p_end}
{phang}. {stata cmp setup}{p_end}

{phang}. {stata webuse laborsup}{p_end}

{phang}{cmd:* Make censoring level 0 for fem_inc since pre-Oct '07 ivtobit assumes it is because of bug.}{p_end}
{phang}. {stata replace fem_inc = fem_inc - 10}

{phang}. {stata reg kids fem_inc male_educ}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_cont) quietly}{p_end}

{phang}. {stata sureg (kids = fem_inc male_educ) (fem_work = male_educ), isure}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ) (fem_work = male_educ), ind($cmp_cont $cmp_cont) quietly}{p_end}

{phang}. {stata mvreg  fem_educ male_educ = kids other_inc fem_inc}{p_end}
{phang}. {stata cmp (fem_educ = kids other_inc fem_inc) (male_educ = kids other_inc fem_inc), ind(1 1) qui}{p_end}

{phang}. {stata ivreg fem_work fem_inc (kids = male_educ), first}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ) (fem_work = kids fem_inc), ind($cmp_cont $cmp_cont) qui}{p_end}

{phang}. {stata ivregress liml fem_work fem_inc (kids = male_educ  other_inc)}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ other_inc) (fem_work = kids fem_inc), ind($cmp_cont $cmp_cont) qui}}{p_end}

{phang}. {stata probit kids fem_inc male_educ}{p_end}
{phang}. {stata predict p}{p_end}
{phang}. {stata mfx}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_probit) qui}{p_end}
{phang}. {stata predict p2, pr}{p_end}
{phang}. {stata mfx, predict(pr) nonlinear}{p_end}

{phang}. {stata oprobit kids fem_inc male_educ}{p_end}
{phang}. {stata mfx, predict(outcome(#2))}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_oprobit) qui}{p_end}
{phang}. {stata mfx, predict(pr outcome(#2)) nonlinear}{p_end}

{phang}. {stata gen byte anykids = kids > 0}{p_end}
{phang}. {stata biprobit (anykids = fem_inc male_educ) (fem_work = male_educ)}{p_end}
{phang}. {stata mfx, predict(pmarg2)}{p_end}
{phang}. {stata cmp (anykids = fem_inc male_educ) (fem_work = male_educ), ind($cmp_probit $cmp_probit)}{p_end}
{phang}. {stata mfx, predict(pr eq(fem_work))}{p_end}

{phang}. {stata tetrachoric anykids fem_work}{p_end}
{phang}. {stata cmp (anykids = ) (fem_work = ), ind($cmp_probit $cmp_probit) nolr qui}{p_end}

{phang}. {stata ivprobit fem_work fem_educ kids (other_inc = male_educ), first}{p_end}
{phang}. {stata mfx, force predict(pr)}{p_end}
{phang}. {stata cmp (fem_work = other_inc fem_educ kids) (other_inc = fem_educ kids male_educ), ind($cmp_probit $cmp_cont)}{p_end}
{phang}. {stata mfx, force predict(pr)}{p_end}

{phang}. {stata treatreg other_inc fem_educ kids, treat(fem_work  = male_educ)}{p_end}
{phang}. {stata cmp (other_inc = fem_educ kids fem_work) (fem_work  = male_educ), ind($cmp_cont $cmp_probit) qui}{p_end}

{phang}. {stata tobit fem_inc kids male_educ, ll}{p_end}
{phang}. {stata cmp (fem_inc = kids male_educ), ind("cond(fem_inc, $cmp_cont, $cmp_left)") qui}{p_end}

{phang}. {stata ivtobit fem_inc kids (male_educ = other_inc), ll first}{p_end}
{phang}. {stata cmp (fem_inc=kids male_educ) (male_educ=kids other_inc), ind("cond(fem_inc,$cmp_cont,$cmp_left)" $cmp_cont)}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse intregxmpl, clear}{p_end}
{phang}. {stata intreg wage1 wage2 age age2 nev_mar rural school tenure}{p_end}
{phang}. {stata cmp (wage1 wage2 = age age2 nev_mar rural school tenure), ind($cmp_int) qui}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse laborsub, clear}{p_end}
{phang}. {stata truncreg whrs kl6 k618 wa we, ll(0)}{p_end}
{phang}. {stata cmp (whrs = kl6 k618 wa we, trunc(0 .)), ind($cmp_trunc) qui}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse sysdsn3, clear}{p_end}
{phang}. {stata mprobit insure age male nonwhite site2 site3}{p_end}
{phang}. {stata cmp (insure = age male nonwhite site2 site3, iia), nolr ind($cmp_mprobit) qui}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse travel, clear}{p_end}
{phang}. {stata asmprobit choice travelcost termtime, casevars(income) case(id) alternatives(mode) struct}{p_end}
{phang}. {stata drop invehiclecost traveltime partysize}{p_end}
{phang}. {stata reshape wide choice termtime travelcost, i(id) j(mode)}{p_end}
{phang}. {stata constraint 1 [air]termtime1 = [train]termtime2}{p_end}
{phang}. {stata constraint 2 [train]termtime2 = [bus]termtime3}{p_end}
{phang}. {stata constraint 3 [bus]termtime3 = [car]termtime4}{p_end}
{phang}. {stata constraint 4 [air]travelcost1 = [train]travelcost2}{p_end}
{phang}. {stata constraint 5 [train]travelcost2 = [bus]travelcost3}{p_end}
{phang}. {stata constraint 6 [bus]travelcost3 = [car]travelcost4}{p_end}
{phang}. {stata "cmp (air:choice1=t*1) (train: choice2=income t*2) (bus: choice3=income t*3) (car: choice4=income t*4), ind((6 6 6 6)) constr(1/6) nodrop struct tech(dfp)"}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse wlsrank, clear}{p_end}
{phang}. {stata asroprobit rank high low if noties, casevars(female score) case(id) alternatives(jobchar) reverse}{p_end}
{phang}. {stata reshape wide rank high low, i(id) j(jobchar)}{p_end}
{phang}. {stata constraint 1 [esteem]high1=[variety]high2}{p_end}
{phang}. {stata constraint 2 [esteem]high1=[autonomy]high3}{p_end}
{phang}. {stata constraint 3 [esteem]high1=[security]high4}{p_end}
{phang}. {stata constraint 4 [esteem]low1=[variety]low2}{p_end}
{phang}. {stata constraint 5 [esteem]low1=[autonomy]low3}{p_end}
{phang}. {stata constraint 6 [esteem]low1=[security]low4}{p_end}
{phang}. {stata "cmp (esteem:rank1=high1 low1)(variety:rank2=female score high2 low2)(autonomy:rank3=female score high3 low3)(security:rank4=female score high4 low4) if noties,ind((9 9 9 9)) tech(dfp) ghkd(200, type(hammersley)) rev constr(1/6)"}
{p_end}
{phang}. {stata restore}{p_end}

{pstd}{hilite:* Heckman selection models.}

{phang}. {stata preserve}{p_end}

{phang}. {stata webuse womenwk, clear}{p_end}
{phang}. {stata heckman wage education age, select(married children education age) mills(heckman_mills)}{p_end}
{phang}. {stata gen selectvar = wage<.}{p_end}
{phang}. {stata cmp (wage = education age) (selectvar = married children education age), ind(selectvar $cmp_probit) nolr qui}{p_end}
{phang}. {stata predict cmp_mills, eq(selectvar)}{p_end}
{phang}. {stata replace cmp_mills = normalden(cmp_mills)/normal(cmp_mills)}{p_end}

{phang}. {stata gen wage2 = wage > 20 if wage < .}{p_end}
{phang}. {stata heckprob wage2 education age, select(married children education age)}{p_end}
{phang}. {stata cmp (wage2 = education age) (selectvar = married children education age), ind(selectvar*$cmp_probit $cmp_probit) qui}{p_end}

{phang}. {stata restore}{p_end}

{pstd}{hilite:* Hierarchical/random effects models}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse union, clear}{p_end}
{phang}. {stata gen double south_year = south * year}{p_end}
{phang}. {stata "xtprobit union age grade not_smsa south year south_year"}{p_end}
{phang}. {stata "cmp (union = age grade not_smsa south year south_year || idcode:), ind($cmp_probit) nolr redraws(51, anti)"}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse nlswork3, clear}{p_end}
{phang}. {stata gen double south_year = south * year}{p_end}
{phang}. {stata xttobit ln_wage union age grade not_smsa south year south_year, ul(1.9)}{p_end}
{phang}. {stata replace ln_wage = 1.9 if ln_wage > 1.9}{p_end}
{phang}. {stata `"cmp (ln_wage = union age grade not_smsa south year south_year || idcode:), ind("cond(ln_wage<1.899999, $cmp_cont, $cmp_right)") nolr redraws(101)"'}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse nlswork5, clear}{p_end}
{phang}. {stata gen double south_year = south * year}{p_end}
{phang}. {stata xtintreg ln_wage1 ln_wage2 union age grade south year south_year occ_code}{p_end}
{phang}. {stata "cmp (ln_wage1 ln_wage2 = union age grade south year south_year occ_code || idcode:), ind($cmp_int) nolr redraws(101, type(hammersley))"}{p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata preserve}{p_end}
{phang}. {stata webuse productivity, clear}{p_end}
{phang}. {stata "xtmixed gsp private emp hwy water other unemp || region: || state:"}{p_end}
{phang}. {stata "cmp (gsp = private emp hwy water other unemp || region: || state:), nolr ind($cmp_cont) redraws(47 47, anti) tech(dfp)"}{p_end}
{phang}. {stata restore}{p_end}

{pstd}These examples go beyond standard commands:

{phang}. {stata webuse laborsup}{p_end}

{phang}{cmd:* Regress an unbounded, continuous variable on an instrumented, binary one. 2SLS is consistent but less efficient.}{p_end}
{phang}. {stata cmp (other_inc = fem_work) (fem_work = kids), ind($cmp_cont $cmp_probit) qui robust}{p_end}
{phang}. {stata ivreg other_inc (fem_work = kids), robust}{p_end}

{phang}{hilite:* Now regress it on a left-censored one, female income, which is only modeled for observations in which the woman works.}{p_end}
{phang}. {stata gen byte ind2 = cond(fem_work, cond(fem_inc, $cmp_cont, $cmp_left), $cmp_out)}{p_end}
{phang}. {stata cmp (other_inc=fem_inc kids) (fem_inc=fem_edu), ind($cmp_cont ind2)}{p_end}

{phang}{hilite:* "IV-oprobit"}{p_end}
{phang}. {stata cmp (kids = fem_educ) (fem_educ = fem_work), ind($cmp_oprobit $cmp_cont) tech(dfp) nolr}{p_end}

{phang}{hilite:* Ordered probit with Heckman selection modeling}{p_end}
{phang}. {stata preserve}{p_end}
{phang}. {stata webuse womenwk, clear}{p_end}
{phang}. {stata gen selectvar = wage<.}{p_end}
{phang}. {stata gen wage3 = (wage > 10)+(wage > 30) if wage < .}{p_end}
{phang}. {stata cmp (wage3 = education age) (selectvar = married children education age), ind(selectvar*$cmp_oprobit $cmp_probit) qui}{p_end}
{phang}. {stata restore}{p_end}

{phang}{hilite:* Multinomial probit with heterogeneous preferences (random effects by individual)}{p_end}
{phang}. {stata preserve}{p_end}
{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/j/jspmix.dta, clear"}{p_end}
{phang}. {stata "cmp (tby = sex, iia || scy3:), ind($cmp_mprobit) nolr redraws(47, anti) tech(dfp)"}{p_end}
{phang}. {stata restore}{p_end}

{marker predict_egs}{...}
{pstd}These illustrate subtleties of {help predict:predict} after {cmd:cmp}:

{phang}. {stata webuse laborsup}{p_end}

{phang}{hilite:* Bivariate seemingly unrelated ordered probit}{p_end}
{phang}. {stata gen byte kids2 = kids + int(uniform()*3)}{p_end}
{phang}. {stata cmp (kids=fem_educ) (kids2=fem_educ), ind($cmp_oprobit $cmp_oprobit) nolr tech(dfp) qui}{p_end}
{phang}{hilite:* Predict fitted values. Fitted values are always the default, as is equation #1}{p_end}
{phang}. {stata predict xbA}{p_end}
{phang}{hilite:* Two ways to predict fitted values for all equations}{p_end}
{phang}. {stata predict xbB*}{p_end}
{phang}. {stata predict xbC xbD}{p_end}
{phang}{hilite:* Predict scores for all equations and parameters}{p_end}
{phang}. {stata predict sc*, score}{p_end}
{phang}{hilite:* Two ways to predict kids=0, using (default) first equation}{p_end}
{phang}. {stata predict prA, pr outcome(0)}{p_end}
{phang}. {stata predict prB, outcome(#1)}{p_end}
{phang}{hilite:* Predict kids2=4, using second equation}{p_end}
{phang}. {stata predict prC, outcome(4) eq(kids2)}{p_end}
{phang}{hilite:* Predict all outcomes, all equations.}{p_end}
{phang}. {stata predict prD*, pr}{p_end}
{phang}{hilite:* Same but result variable names for the two equations start with prE and prF respectively.}{p_end}
{phang}. {stata predict prE prF, pr}{p_end}
{phang}{hilite:* Predict all outcomes, equation 2. Generates variables prG_Y where Y is outcome number (not outcome value).}{p_end}
{phang}. {stata predict prG, eq(#2) pr}{p_end}

{title:References}

{p 4 8 2}Bunch, D.S. 1991. Estimability in the multinomial probit model. Transportation Research. 25B(1): 1-12.{p_end}
{p 4 8 2}Cappellari, L., and S. Jenkins. 2003. Multivariate probit regression using simulated maximum likelihood.
{it:Stata Journal} 3(3): 278-94.{p_end}
{p 4 8 2}Drukker, D.M., and R. Gates. 2006. Generating Halton sequences using Mata. {it:Stata Journal} 6(2): 214-28. {browse "http://www.stata-journal.com/article.html?article=st0103"}{p_end}
{p 4 8 2}Gates, R. 2006. A Mata Geweke-Hajivassiliou-Keane multivariate normal simulator. {it:Stata Journal} 6(2): 190-213. {browse "http://www.stata-journal.com/article.html?article=st0102"}{p_end}
{p 4 8 2}Gould, W., J. Pitblado, and W. Sribney. 2006. Maximum Likelihood Estimation with Stata. 3rd ed. College Station: Stata Press.{p_end}
{p 4 8 2}Greene, W.H. 2002. {it:Econometric Analysis}, 5th ed. Prentice-Hall.{p_end}
{p 4 8 2}Greene, W.H. 2011. {it:Econometric Analysis}, 7th ed. Prentice-Hall.
{browse "http://pages.stern.nyu.edu/~wgreene/DiscreteChoice/Readings/Greene-Chapter-17.pdf":Chapter 15}{p_end}
{p 4 8 2}Keane, M.P. 1992. A note on identification in the multinomial probit model. {it:Journal of Business and Economics Statistics} 10(2), pp. 193-200.{p_end}
{p 4 8 2}Kelejian, H.H. 1971. Two-stage least squares and econometric systems linear in parameters but nonlinear in the endogenous variables. 
{it:Journal of the American Statistical Association} 66(334): 373-74.{p_end}
{p 4 8 2}Long, J. S., and J. Freese. 2006. Regression models for categorical dependent variables using Stata. 2nd ed. College Station, TX: Stata Press.{p_end}
{p 4 8 2}Pagan. A. 1979. Some consequences of viewing LIML as an iterated Aiken estimator. Economics Letters 3:369-372.{p_end}
{p 4 8 2}Pitt, M.M., and S. R. Khandker. 1998. The impact of group-based credit programs on poor households in Bangladesh: Does the gender of participants matter?
{it:Journal of Political Economy} 106(5): 958-96.{p_end}
{p 4 8 2}Rivers, D., and Q. Vuong. 1988. Limited information estimators and exogeneity tests for simultaneous probit models.
{it:Journal of Econometrics} 39: 347-66.{p_end}
{p 4 8 2}Roodman, D. 2011. Estimating fully observed recursive mixed-process models with cmp. {it:Stata Journal} 11(2): 159-206.{p_end}
{p 4 8 2}Smith, R.J., and R.W. Blundell. 1986. An exogeneity test for a simultaneous equation tobit model with an application
to labor supply. {it:Econometrica} 54(3): 679-85.{p_end}
{p 4 8 2}Train, K. 2009. {it:Discrete Choice Methods with Simulation.} 2nd ed. Cambridge University Press. {browse "http://elsa.berkeley.edu/books/choice2.html"}

{title:Author}

{p 4}David Roodman{p_end}
{p 4}Senior Fellow{p_end}
{p 4}Center for Global Development{p_end}
{p 4}Washington, DC{p_end}
{p 4}droodman@cgdev.org{p_end}

{title:Acknowledgements}

{pstd}Thanks to Kit Baum, David Drukker, Arne Hole, Stanislaw Kolenikov, and Mead Over for comments.

{title:Also see}

{psee}
{manhelp ml R},
{manhelp biprobit R},
{manhelp probit R},
{manhelp oprobit R},
{manhelp sureg R},
{manhelp ivreg R},
{manhelp tobit R},
{manhelp cnreg R},
{manhelp intreg R},
{manhelp truncreg R},
{manhelp ivtobit R},
{manhelp ivprobit R},
{manhelp heckman R},
{manhelp heckprob R},
{manhelp svy_estimation SVY:svy estimation}.
{p_end}
