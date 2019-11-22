#include <oxstd.h>
#include <oxprob.h>
//#include <simulation.h>


/*POT-POURRI DE FONCTIONS POUR PANEL
ESTIMATION (WITH SIMULATIONS)

1) DISTINCVAL
2) HALTONSEQ
3) HALTDRAWSUNIF
4) HALTDRAWS
5) HALTPANEL
6) SMOOTH RECURSIVE SIMULATOR (GHK)
7) SEQX									*/

// DISTINCVAL ***************************
static distincval(const vX,const OPTIONS)
{
decl N,i,y,vNumwave,rowsvX,x;
y = sortc(vX);
N = y[0]; rowsvX = sizer(vX);
i=1;
while(i<rowsvX)
{
	if(y[i]!=y[i-1])
	{
	N=N|y[i];
	}
	else
	{N=N;}
++i;
}

if(OPTIONS==1)
{
vNumwave = new matrix[rows(N)][1];
i = 0;
while(i < sizer(N))
{
vNumwave[i] = sizer(selectifr(vX, vX .== N[i]));
++i;
}
return N~vNumwave;
}

if(OPTIONS==2)
{
vNumwave = 0; i=0;
while(i < sizer(N)) {
	x = sizer(selectifr(vX, vX .== N[i]));
	vNumwave |= constant(x,x,1);
	++i;
}
vNumwave = dropr(vNumwave,0);
return vNumwave;
}


return N;
} // END FUNCTION ***********************


// HALTON SEQUENCE GENERATOR ************

/*The proc halton generates a sequence of
  number of lenght N for base number s.
  To limit the collinearity between
  multiple sequences, it is recommended to
  limit s to the set of prime numbers.
  the proc discards the first 'w' draws from
  each sequence to prevent high correlation
  amongst multi-dimensional sequences    */

static haltonseq(const N, const s, const w)
{
decl i,j,y,x,k,phi;
k = floor(log(N+1+w)/log(s));
phi = 0;
i=1;
while(i<=k)
{x = phi; j=1;
	while(j<s)
	{
		y = phi+j/(s^i);
		x = x|y;
		++j;
	}
phi = x;
++i;
}
x=phi;
j=1;							 
while(j<s && rows(x) < N+1+w)	  
{
y = phi+(j/s^i);
x = x|y;
++i;
}							  
phi = x[1+w:N+w][0];
return phi;
} // END FUNCTION (FROM BELLEMARE)



// HALTON UNIFORM ***********************
/*The following proc computes R randomized
  uniform Halton draws for N observations
  in each of D dimensions. The results
  are stored in a N by R*D matrix. Several
  randomization options are supported.
  w: Specifies the number of points
  in the Halton sequence that is thrown away
  options: Choses the type of Randomization
  applied to the Halton sequence
           1) Long N*R sequence for each
		   dimension, cut into bits on R
		   elements
		   2) 1-Modulus with uniform draw
		   for each dimension           */

static haltdrawsunif(const R, const N, const D,
					const w, const options)
{
decl prim,d,draws,i,j,mu,s;
prim = <2,3,5,7,11,13,17,19,23,29,31,37,41,43,
47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113>;
d = new matrix[N*R][1]; draws = new matrix[N][R*D];
if(options==1)				
for(i=0;i<D;++i)
{

	draws[][i*R:(i+1)*R-1] = shape(haltonseq(N*R,prim[i],w),R,N)';
}
else if(options==2)			
for(i=0;i<D;++i)
{
mu = ranu(N*R,1);
d = mu+haltonseq(N*R,prim[i],w);
d = d.>1 .? d-1 .: d;
draws[][i*R:(i+1)*R-1] = shape(d,N,R);
}
return draws;
} // END FUNCTION (FROM BELLEMARE)

// HALTON DRAWS FROM DIFFERENT DIST. ****

/*Procedure to draw quantiles from various
continuous distributions based on inverting
  Halton draws derived from the proc
  'haltdraws'. It creates a N by R*D matrix
  of draws where N is the number of
  observations, R the number of draws
  per dimension and D is the
  dimension of the space we draw from.
  
  w: Specifies the number of points in
  the Halton sequence that is thrown away

  options: Choses the type of Randomization
  applied to the Halton sequence
           1) Long N*R sequence for each
		   dimension, cut into bits on R
		   elements
		   2) 1-Modulus with uniform draw
		   for each dimension

  distrib: Specifies the distribution from
  which quantiles should be drawn           
           1) Univariate normal distribution
		   with support [-infinity, +infinity].
           2) Univariate extreme value
		   type 1 Gumbel distribution
           3) Univariate log-normal
		   distribution					*/
static haltdraws(const R, const N, const D, const w,
const options, const distrib)
{
decl x,draws;
draws = new matrix[N][R*D]; x = new matrix[N][R*D];
x = haltdrawsunif(R,N,D,w,options);
if(distrib==1)
{
draws = quann(x);
draws = setbounds(draws,-5,5);
}
else if (distrib==2)
{draws = -log(-log(x));}
else if (distrib==3)
{draws = exp(x);}
return draws;
} //END FUNCTION ************************


// HALTON DRAWS FOR PANEL ***************
/*The following proc computes R randomized
Halton draws for N observations and blows
them up to be used for unbalanced individual
random effects integration. Each individual
participates in a 'Numwave' number of periods.
The proc calls 'haltdraws' to generate
R*D number of draws for this individual.
This row is then vertically concatenated
'Numwave' number of times according to a N by
1 vector 'Numwave' which contains excatly
the number of waves this individual
will be in the panel.This corresponds
to the eps[i] defined in the following
equation

  	y[i][t] = x[i][t]'beta + eps[i];
	t=1,...Numwave[i].                   */

static haltpanel(const R, const N, const D,
 	const w, const options, const distrib,
 	const numwave)
{
decl x,draws,i,j,count;
x = haltdraws(R,N,D,w,options,distrib);
draws = new matrix[sumc(numwave)][R*D];
count = 0;

for (decl i = 0; i<N;++i) {
	draws[count:count+numwave[i]-1][] = ones(numwave[i],1)*x[i][];
	count += numwave[i];
}
return draws; 
} // END FUNCTION ***********************


// GHK SIMULATOR ************************
/* --------------------------------------
GHK Simulator for Multivariate Prob.
(Geweke-Hajivassiliou-Keane) 
	- DEF: 	Simulate a Multivariate Normal
	probability with mean vector mV
	and covariance matrix mS which is J
	dimensional. Using Halton draws is
	advised for variance reduction and
	improved coverage.	
	- SPEC: mP = GHK( mV , A , B , mS ,
	mL , mD , R )
 			mV: Vector of index	(JX1)
			A: Lower Boundary of Integral
			(JX1) SET A=0 if Y=1, else -1.e+100
			B: Upper Boundary of Integral
			(1XJ) SET B=0 if Y=0, else +1.e+100
			mS: (JXJ) Covariance Matrix
			mL: (JXJ) Choleski Decomposition
			of mS
			mD: (1XJR) vector of uniform
			draws
			R: Number of replications
			(suggestion R>20) */

static GHK(const mV, const A, const B, const mS,
	const mL, const mD, const R)
{
decl j,mU,GB,GA,mProb;
mU = new matrix [rows(mS)][R];
GB = GA =  new matrix[1][R];
mU[0][] = quann(mD[][0:R-1].*probn((B[0]-mV[0])
		/(mL[0][0]+1.e-100).*ones(1,R))
		+(1-mD[][0:R-1]).*probn((A[0]-mV[0])
		/(mL[0][0]+1.e-100).*ones(1,R)));
mProb = probn((B[0]-mV[0])/(mL[0][0]+1.e-100)
		.*ones(1,R))-probn((A[0]-mV[0])/
		(mL[0][0]+1.e-100).*ones(1,R));
for (j=1;j<columns(mS);++j)
{
GB = probn((B[j]-mV[j]-mL[j][0:j-1]*mU[0:j-1][])
							./(mL[j][j]+1.e-100));
GA = probn((A[j]-mV[j]-mL[j][0:j-1]*mU[0:j-1][])
							./(mL[j][j]+1.e-100));
mU[j][] = quann(mD[][j*R:(j+1)*R-1].*GB
				+ (1-mD[][j*R:(j+1)*R-1]).*GA);
mProb = mProb.*(GB-GA);
}
return meanr(mProb);
}


// SEQ TABLES ************************

static seqt(const mY)
{
decl T,N,i,j,mU,m;
N = rows(mY);
T = columns(mY);
mU = mY[0][];
for(decl i=1;i<N; ++i)
{
decl m = 0;
	for(decl j = 0; j < rows(mU); ++j)
	{
		if(mY[i][] == mU[j][])
		{
		m = 1;
		break;
		}
	}
	if(m == 0)
	{
		mU = mU|mY[i][];
	}
}
decl vF = new matrix[rows(mU)][1];
	for(decl k = 0; k < rows(mU); ++k)
	{
	decl dI = 0;
	decl dC = 0;
		for(decl l = 0; l < N; ++l)
		{
		dI = (mU[k][] == mY[l][]);
		dC = dC + dI;
		}
	vF[k] = dC;
	}
return vF~mU;
} // END FUNCTION ***********************

// SEQ INDICATORS ***********************
static seqi(const mY, const mU)
{
decl T,N,i,vS,vM;
N = rows(mY);
T = columns(mY);
vS = new matrix[N][1];
vM = new matrix[N][1];
	for(decl i = 0; i < N; ++i)
	{
		vS[i] = selectifr(mU[][0], mU .== mY[i][]);
		vM[i] = sumr(mY[i][]);
	}

return vS~vM;
} // END FUNCTION ***********************



// FUNCTION: LAG/LEAD FOR PANEL

static lagp(const vX, const vI, const cL)
{
decl vIndex = distincval(vI,1);
decl N = sizer(vIndex);
decl vX_L = 0;
for (decl i=0;i<N;++i)
{
decl x;
x = lag0(selectifr(vX,vI.==vIndex[i][0]),cL);
vX_L = vX_L|x[1:];
}
return vX_L[1:];
}
