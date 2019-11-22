* ghk2() 1.4.1  14 July 2012
* Copyright 2008-12 David Roodman. May be distributed free.

* Version history
* 1.4.1 Fixed bug introduced in 1.4.0 in conversion of dfdT to dfdV
* 1.4.0 Added optional pi (prime index) argument to ghk2setup() to control which primes used.
*       For non-generalized Halton sequences, switched from ghalton() to more-exact, non-recursive generation
*       Tightened ghk2setup()
* 1.3.1 Fixed longstanding bug in computing score w.r.t to top-left entry of Cholesky factor of Sigma
* 1.3.0 More precise calculation of normal(U)-normal(L) when U, L large in _ghk_2() and _ghk_2d()
* 1.2.0 Added s argument
* 1.1.2 added ghk2version command
* 1.1.1 Fixed bug in _ghk2_d() and _ghk2_2d() in conversion of df/dT to df/dV
* 1.1.0 Fixed problems in score computation in _ghk2_2d()
* 1.0.3 Fixed bug in computation of scores (X :/ Y / Z != (X :/ Y) / Z  !!)
* 1.0.2 Streamlined ghk2setup() for type=random
* 1.0.1 Added error checking for rows(X) > pts.n

mata
mata clear
mata set matastrict on
mata set mataoptimize on
mata set matalnum off

struct ghk2points {
	real scalar n, m, d
	pointer (pointer (real colvector) colvector) colvector W, Wa  // m-vectors of pointers to d-1-vectors of pointers to n-vectors. Wa is antithetics
}

struct ghk2points scalar ghk2setup(real scalar n, real scalar m, real scalar d, string scalar type, | real scalar pi) {
	real scalar itype, j, k, hammersley
	real rowvector primes
	real matrix U, S
	pointer (real colvector) colvector W2, W2a
	struct ghk2points scalar pts

	primes = 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97

	if (d<=0 | floor(d)!=d) {
		errprintf("ghk2: dimension must be a positive integer.\n")
		exit(3300)
	}
	if (n<=0 | floor(n)!=n) {
		errprintf("ghk2: number of observations must be a postitive integer.\n")
		exit(3300)
	}
	if (m<=0 | floor(m)!=m) {
		errprintf("ghk2: draws/observation must be a postitive integer.\n") 
		exit(3300)
	}

	itype = cross( (strtrim(strlower(type)) :== ("random"\"halton"\"hammersley"\"ghalton")), 1::4 ) - 1
	if (itype == -1) {
		errprintf("ghk2: point set type must be random, halton, hammersley, or ghalton.\n")
		exit(3300)
	}
	hammersley = itype == 2

	if (itype) {
		if (pi == .) pi = 1
		else if (pi<=0 | floor(pi)!=pi) {
			errprintf("ghk2: prime index must be a positive integer.\n")
			exit(3300)
		}
	
		if (d > length(primes) - hammersley + pi) {
			errprintf("ghk2: maximum dimension is %g.", length(primes) - hammersley + pi)
			exit(3300)
		}

		primes = primes[|pi\.|]
	}

	pts.d=d; pts.m=m; pts.n=n; pts.W=pts.Wa=J(m, 1, NULL)

	for (U=J(n*m,k=d-1,0); k; k--)
		U[,k] = itype? (itype==3? ghalton(n*m, primes[k], uniform(1,1)) : hammersley & k==1? J(n,1,1)#(0.5::m)/m : halton2(n*m, primes[k-hammersley])) : uniform(n*m,1)

	S = (1::n)*m 
	for (j=m; j; j--) {
		for (W2=W2a=J(k=d-1,1,NULL); k; k--) 
			W2a[k] = &(1 :- *( W2[k] = &U[S,k] ) )
		pts.W [j] = ghk2_clone(W2)
		pts.Wa[j] = ghk2_clone(W2a)
		S = S :- 1
	}
	return(pts)
}

// exact Halton sequence of length n for base p, to avoid bug in halton() pre-Stata 12.1 
real colvector halton2(real scalar n, real scalar p) {
	real scalar i, p2i, p2Dmi; real colvector retval, one2p
	for (retval = J(p2Dmi=p^(i=floor(ln(n)/ln(p)+1e-6)), 1, p2i=1) # (one2p=(0::p-1)/p); i; i--)
		retval = retval + J(p2Dmi=p2Dmi/p, 1, 1) # (one2p=one2p/p) # J(p2i=p2i*p, 1, 1)
	return (retval[|2\n+1|])
}

// derivative of vech(V) w.r.t vech(cholesky(V)). Transposed, i.e., one row for each T_ij.
real matrix ghk2_dTdV(real matrix T) {
	real scalar d; real colvector vK, vL; real matrix t
	d = cols(T)
	vK = vech(t = rowshape(1::d^2,d))
	vL = vech(t')
	return ( qrinv((T#I(d))[vL,vL]+(I(d)#T)[vL,vK]) )
}

pointer (transmorphic matrix) scalar ghk2_clone(transmorphic matrix X) {
	transmorphic matrix Y
	return(&(Y = X))
}

real colvector ghk2(struct ghk2points scalar pts, real matrix X, real matrix a3, real matrix a4, 
		| real matrix a5, real matrix a6, real matrix a7, real matrix a8, real matrix a9) {
	real scalar na, anti, s
	pointer (real matrix) pXu, pV, pdfdxu, pdfdx, pdfdv

	if (pts.m <= 0) {
		errprintf("ghk2: invalid points structure: number of integration points must be greater than 0.\n")
		exit(3300)
	}
	if (pts.n <= 0) {
		errprintf("ghk2: invalid points structure: length of the structure must be greater than 0.\n")
		exit(3300)
	}
	if (pts.d<=0 | pts.d>20) {
		errprintf("ghk2: invalid points structure: dimension must be between 1 and 20.\n")
		exit(3200)
	}
	if (rows(pts.W) != pts.m) {
		errprintf("ghk2: invalid points structure: vector of pointers to sequence matrices is the wrong length.\n")
		exit(3200)
	}
	if (rows(*pts.W[1]) != pts.d-1) {
		errprintf("ghk2: invalid points structure: point set has the wrong dimension.\n")
		exit(3200)
	}
	if (rows(*(*pts.W[1])[1]) != pts.n) {
		errprintf("ghk2: invalid points structure: point set has the wrong length.\n")
		exit(3200)
	}
	
	if ((na = args()) == 5) {
		pV = &a3; anti = a4; s = a5
	} else if (na == 6) {
		pXu = &a3; pV = &a4; anti = a5; s = a6
	} else if (na == 7) {
		pV = &a3; anti = a4; s = a5; pdfdx = &a6; pdfdv = &a7
	} else if (na == 9) {
		pXu = &a3; pV = &a4; anti = a5; s = a6; pdfdx = &a7; pdfdxu = &a8; pdfdv = &a9
	} else {
		errprintf("ghk2: Wrong number of arguments for ghk2. Expected 5, 6, 7, or 9.\n")
		exit(3000)
	}

	if (rows(*pV)>pts.d | cols(*pV)>pts.d | rows(*pV)!= cols(*pV)) {
		errprintf("V must be square with dimension at most %g.\n", pts.d)
		exit(3200)
	}
	if (missing(*pV)) {
		errprintf("matrix V has missing values.\n")
		exit(3351)
	}

	if (s==.) s = 1

	if (na==5 | na==7) {
		if (cols(X) > pts.d) {
			errprintf("ghk2: number of columns of X, %g, cannot exceed the dimension of the points structure, %g.\n", cols(X), pts.d)
			exit(3200)
		}
		if (s - 1 + rows(X) > pts.n) {
			errprintf("ghk2: number of rows of X, %g, plus starting point, %g, cannot exceed the dimension of the points structure, %g.\n", rows(X), s, pts.n)
			exit(3200)
		}
		if (cols(*pV) != cols(X)) {
			errprintf("ghk2: number of columns in X, %g, does not equal the dimension of V, %g.\n", cols(X), cols(*pV))
			exit(3200) 
		}
		return (na==5? _ghk2(pts, X, *pV, anti, s) : _ghk2_d(pts, X, *pV, anti, s, *pdfdx, *pdfdv))
	}
	if (cols(X) > pts.d) {
		errprintf("ghk2: number of columns of Xl, %g, cannot exceed the dimension of the points structure, %g.\n", cols(X), pts.d)
		exit(3200)
	}
	if (cols(*pXu) > pts.d) {
		errprintf("ghk2: number of columns of Xu, %g, cannot exceed the dimension of the points structure, %g.\n", cols(*pXu), pts.d)
		exit(3200)
	}
	if (cols(*pV) != cols(X)) {
		errprintf("ghk2: number of columns in Xl, %g, does not equal the dimension of V, %g.\n", cols(X), cols(*pV))
		exit(3200) 
	}
	if (cols(*pV) != cols(*pXu)) {
		errprintf("ghk2: number of columns in Xu, %g, does not equal the dimension of V, %g.\n", cols(*pXu), cols(*pV))
		exit(3200) 
	}
	if (cols(X) != cols(*pXu) | rows(X) != rows(*pXu) ) {
		errprintf("ghk2: Xl and Xu must have the same dimensions.\n")
		exit(3200) 
	}
	if (s - 1 + rows(X) > pts.n) {
		errprintf("ghk2: number of rows of Xl and Xu, %g, plus starting point, %g, cannot exceed the dimension of the points structure, %g.\n", rows(X), s, pts.n)
		exit(3200)
	}

	return (na == 6?  _ghk2_2(pts, X, *pXu, *pV, anti, s) : _ghk2_2d(pts, X, *pXu, *pV, anti, s, *pdfdx, *pdfdxu, *pdfdv))
}

real colvector _ghk2(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a
	real colvector p, pk, p1, Phib, u
	real matrix T, z, sz, sW
	pointer (real colvector) colvector pW, pT

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	if ((d = rows(V)) == 1) return (editmissing(normal(X/T), 1))

	pT = J(d, 1, NULL); for (j=d; j>1; j--) pT[j] = &((-T[|j,1 \ j,j-1|]' \ 1) / T[j,j])
	p = J(n=rows(X), 1, 0); _editmissing(p1 = normal(X[,1] / T[1,1]), 1)
	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (k = pts.m; k; k--) {
			z = X; pW = *(a? pts.Wa : pts.W)[k]
			u = (*pW[1])[|sW|]
			z[,1] = invnormal(u :* p1)
			for (j=2; j<=d-1; j++) {
				sz[2,2] = j
				_editmissing(Phib = normal(z[|sz|] * *pT[j]), 1)
				pragma unset pk
				pk = j==2? Phib : pk:*Phib
				u = (*pW[j])[|sW|]
				z[,j] = invnormal(u :* Phib)
			}
			_editmissing(Phib = normal(z * *pT[d]), 1)
			p = p + (d==2? Phib : pk:*Phib)
		}
	return (p/(anti? 2*pts.m : pts.m) :* p1)
}

real colvector _ghk2_binorm(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a, rho
	real colvector p, pk, p1, Phib, u, b, bd
	real matrix T, z, sz, sW
	pointer (real colvector) colvector pW, pT
	pragma unset pk

	T = cholesky(V)'
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	if ((d = rows(V)) == 1) return (editmissing(normal(X/T), 1))

	pT = J(d, 1, NULL)
	pT[d] = &((d==2? 0 \ 1 : -T[|.,d \ d-2,.|] \ 0 \ 1) / sqrt(T[d,d-1]^2 + T[d,d]^2)) //d==2 part temporary
	for (j=d-1; j>1; j--) pT[j] = &((-T[|.,j \ j-1,j|] \ 1) / T[j,j])
	rho = T[d-1,d] / sqrt(T[d-1,d]^2 + T[d,d]^2)
	
	p = J(n=rows(X), 1, 0); _editmissing(p1 = normal(b = X[,1] / T[1,1]), 1)
if (d==2) p1 = J(n, 1, 1)
	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (k = pts.m; k; k--) {
			z = X; pW = *(a? pts.Wa : pts.W)[k]
			u = (*pW[1])[|sW|]
			z[,1] = invnormal(u :* p1)
			if (d>3)
				for (j=2; j<=d-2; j++) {
					sz[2,2] = j
					_editmissing(Phib = normal(b = z[|sz|] * *pT[j]), 1)
					pk = j==2? Phib : pk:*Phib
					u = (*pW[j])[|sW|]
					z[,j] = invnormal(u :* Phib)
				}
			else {
				b = z[|.,.\.,2|] * *pT[2]
				Phib = J(n, 1, .)
			}
			bd = z * *pT[d]
			for (j=n; j; j--)
				Phib[j] = binormal(b[j], bd[j], rho)
			_editmissing(Phib, 1)
			p = p + (d>3? pk:*Phib : Phib)
		}
	return (p/(anti? 2*pts.m : pts.m) :* p1)
}

real colvector _ghk2_2(struct ghk2points scalar pts, real matrix Xl, real matrix Xu, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a
	real colvector p, pk, p1, Phib, Phibl, Phibl1, sign, sign1, L, U
	pragma unset pk; pragma unset p1; pragma unset Phib
	real rowvector Td
	real matrix T, z, sz, sW, _Xu, _Xl, t
	pointer (real colvector) colvector pW, pT

	T = cholesky(V)'
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	pT = J(d=rows(V), 1, NULL)
	for (j=d; j>1; j--) pT[j] = &(T[|.,j \ j-1,j|] / -T[j,j])

	Td = diagonal(T)'
	_editmissing(_Xu = z = Xu :/ Td, maxdouble()); _editmissing(_Xl = Xl :/ Td, -maxdouble())
	
	L = _Xl[,1]; U = _Xu[,1]
	sign1 = (L+U:<=0)*2 :- 1
	p1 = normal(sign1:*U) - (Phibl1 = normal(sign1:*L))  // flip signs for precision. normal(9)-normal(8) is less accurate than -(normal(-8)-normal(-9))

	if (d == 1) return (p1)

	p = J(n=rows(Xl), 1, 0)

	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (k = pts.m; k; k--) {
			pW = *(a? pts.Wa : pts.W)[k]
			z[,1] = sign1 :* invnormal(Phibl1 + (*pW[1])[|sW|] :* p1)  // u = (*pW[1])[|sW|]
			sz[2,2] = 1
			for (j=2; j<=d-1; sz[2,2]=j++) {
				t = z[|sz|] * *pT[j]
				L = _Xl[,j] + t; U = _Xu[,j] + t
				Phibl = normal((sign = (L+U:<=0)*2 :- 1) :* L)
				z[,j] = sign :* invnormal(Phibl + (*pW[j])[|sW|] :* (Phib = normal(sign:*U) - Phibl))
				pk = j==2? Phib : pk:*Phib
			}
			t = z[|sz|] * *pT[d]
			L = _Xl[,d] + t; U = _Xu[,d] + t
			sign = (L+U:<=0)*2 :- 1
			Phib = normal(sign:*U) - normal(sign:*L)
			p = p + abs(d==2? Phib : pk:*Phib)
			}

	return (p/(anti? 2*pts.m : pts.m) :* abs(p1))
}

real colvector _ghk2_d(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s, real matrix dfdx, real matrix dfdv) {
	real scalar i, j, k, d, d2, n, g, l, a
	real colvector p, pg, Phib, Phib1, b, b1, phib, phib1, lambdab, u, T2j, Td
	real matrix T, z, sz, sW, nd0, nd20, dlnfdxg, dlnpdtg, dlnfdxg1, dlnpdtg1, dzdb, dbdx, dbdt, t
	pointer (real colvector) colvector pW, pT, pT2, dbdx0
	pointer (real matrix) colvector dzdx, dzdt // vectors of pointers to scores of z's w.r.t. each parameter

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	b1 = X[,1] / T[1,1]
	_editmissing(Phib1 = normal(b1), 1); phib1 = normalden(b1)

	if ((d = rows(V)) == 1) {
		dfdx = phib1 / T
		dfdv = dfdx :* X * ((-.5) / V)
		return (Phib1)
	}
	n = rows(X)
	pT = pT2 = dbdx0 = J(d, 1, NULL)
	for (j=d; j>1; j--) {
		pT[j] = &(*(pT2[j] = &(T[|j,1 \ j,j-1|]' / -T[j,j])) \ 1/T[j,j])
		dbdx0[j] = &J(n, 1, 1/T[j,j])
	}

	sz = J(2, 2, .)
	dfdx = nd0 = J(n, d, 0)
	dfdv = nd20 = J(n, d2 = d*(d+1)*.5, 0)
	p = J(n, 1, 0)
	dlnfdxg1 = nd0; dlnpdtg1 = nd20
	dlnpdtg1[,1] = (dlnfdxg1[,1] = (phib1 :/ Phib1) / T[1,1]) :* -b1

	dzdx = J(d,  1, NULL); for (k=d;  k; k--) dzdx[k] = &J(n, d-1, 0)
	dzdt = J(d2, 1, NULL); for (k=d2; k; k--) dzdt[k] = &J(n, d-1, 0)

	Td = -diagonal(T); Td[1] = -Td[1]

	sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (g = pts.m; g; g--) {
			z = X; pW = *(a? pts.Wa : pts.W)[g]; dlnfdxg = dlnfdxg1; dlnpdtg = dlnpdtg1; dbdx = nd0; dbdt = nd20

			// custom-coded first iteration over dimensions
			u = (*pW[1])[|sW|]
			dzdb = u :* phib1 :/ normalden(z[,1] = invnormal(u :* Phib1))
			(*dzdt[1])[,1] = ( (*dzdx[1])[,1] = dzdb / Td[1] ) :* (-b1) 
			for (j=2; j<=d-1; j++) {
				sz[2,2] = j; l = j*(j+1)*.5; T2j = *pT2[j]
				u = (*pW[j])[|sW|]
				b = z[|sz|] * *pT[j]; _editmissing(Phib = normal(b), 1); phib = normalden(b); lambdab = phib :/ Phib

				pragma unset pg
				pg = j==2? Phib : pg:*Phib
				
				dzdb = u :* phib :/ normalden(z[,j] = invnormal(u :* Phib))
				(*dzdx[j  ])[,j] = dzdb :* (dbdx[,j] = *dbdx0[j])
				(*dzdt[l--])[,j] = dzdb :* (dbdt[,l] = b / Td[j])    // j = i = k
	
				for (k=j-1; k; k--)  // j = i > k
					(*dzdt[l--])[,j] = dzdb :* (dbdt[,l] = z[,k] / Td[j])
	
				for (i=sz[2,2]=j-1; i; i--) {
					(*dzdx[i])[,j] = dzdb :* (dbdx[,i] = (*dzdx[i])[|sz|] * T2j)
	
					for (k=i; k; k--) // j > i >= k
						(*dzdt[l--])[,j] = dzdb :* (dbdt[,l] = (*dzdt[l])[|sz|] * T2j)
				}
				dlnfdxg = dlnfdxg + lambdab :* dbdx
				dlnpdtg = dlnpdtg + lambdab :* dbdt
			}
	
			// custom-coded last iteration
			l = d2; T2j = *pT2[d]
			b = z * *pT[d]; _editmissing(Phib = normal(b), 1); lambdab = normalden(b) :/ Phib
			if (d==2) {
				dbdx = nd0; dbdt = nd20
			}
			p = p + (pg = d==2? Phib : pg:*Phib)
			dbdx[,d] =  *dbdx0[d]
			dbdt[,l--] = b / Td[d]
			dbdt[|.,l-d+2\.,l|] = z[|.,.\.,d-1|] / Td[d]
			l = l - (d - 1)
			for (i=d-1; i; i--) {
				dbdx[,i] = *dzdx[i] * T2j
				for (k=i; k; k--) dbdt[,l--] = *dzdt[l] * T2j
			}
			dfdx = dfdx + (dlnfdxg + lambdab :* dbdx) :* pg
			dfdv = dfdv + (dlnpdtg + lambdab :* dbdt) :* pg
		}

	Phib1 = Phib1 / (anti? 2*pts.m : pts.m)
	dfdx = dfdx :* Phib1
	t = T; for (j=d; j; j--) for(i=j; i; i--) t[j,i] = d2--
	dfdv = (dfdv :* Phib1)[,vech(t)] * ghk2_dTdV(T)
	return (p :* Phib1)
}

real colvector _ghk2_2d(struct ghk2points scalar pts, real matrix Xl, real matrix Xu, real matrix V, real scalar anti, 
				real scalar s, real matrix dfdxl, real matrix dfdxu, real matrix dfdv) {
	real scalar i, j, j2, k, d, d2, n, g, l, a
	real rowvector Td
	real colvector p, pg, Phibu, Phibu1, bu, bu1, phibu, phibu1, Phibl, Phibl1, bl, bl1, phibl, phibl1, u, Tj, p1, pgj, dlnpgjdbu, dlnpgjdbl, dzda, sign, sign1
	real matrix T, z, sz, sW, nd0, nd20, dlnpdxug, dlnpdxlg, dlnpdtg, dlnpdxug1, dlnpdxlg1, dlnpdtg1, dzdbu, dzdb, dbudxu, dbudxl, dbudt, dzdbl, dbldxu,dbldxl, dbldt, t, _Xu, _Xl
	pointer (real colvector) colvector pW, pT, dbdx0
	pointer (real matrix) colvector dzdxu, dzdxl, dzdt // vectors of pointers to scores of z's w.r.t. each parameter

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	n = rows(Xl)
	pT = dbdx0 = J(d=rows(V), 1, NULL)
	for (j=d; j>1; j--) {
		pT[j] = &(T[|j,1 \ j,j-1|]' / -T[j,j])
		dbdx0[j] = &J(n, 1, 1/T[j,j])
	}
	Td = diagonal(T)'
	_editmissing(_Xu = Xu :/ Td, maxdouble()); _editmissing(_Xl = Xl :/ Td, -maxdouble())
	bu1 = _Xu[,1]; bl1 = _Xl[,1]
	sign1 = (bl1+ bu1:<=0)*2 :- 1
	Phibu1 = normal(sign1:*bu1); phibu1 = normalden(bu1)
	Phibl1 = normal(sign1:*bl1); phibl1 = normalden(bl1)

	p1 = abs(Phibu1 - Phibl1)
	if (d == 1) {
		dfdxu = phibu1 / T; dfdxl = phibl1 / -T
		dfdv = (-0.5)/T * (dfdxu  :* bu1  - dfdxl :* bl1)
		return (p1)
	}

	z = J(n, d-1, 0); p = J(n, 1, 0)
	dlnpdxug1 = dlnpdxlg1 = dfdxu = dfdxl = nd0 = J(n, d, 0)
	dlnpdtg1 = dfdv = nd20 = J(n, d2 = d*(d+1)*.5, 0)

	dlnpgjdbu = phibu1 :/ p1; dlnpgjdbl = phibl1 :/ p1     // dlnp_j/dbu_j = phi(bu_j)/(Phi(bu_j)-Phi(bl_j)). abs(dlnp_j/dbu_j) = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))
	dlnpdxug1[,1] = dlnpgjdbu /  T[1,1]
	dlnpdxlg1[,1] = dlnpgjdbl / -T[1,1]
	_editmissing(bu1, 0); _editmissing(bl1, 0)
	dlnpdtg1[,1] = dlnpgjdbl :* bl1  - dlnpgjdbu :* bu1

	dzdxu = dzdxl = J(d, 1, NULL)
	for (k=d; k; k--) {
		dzdxl[k] = &J(n, d-1, 0)
		dzdxu[k] = &J(n, d-1, 0)
	}

	dzdt = J(d2, 1, NULL)
	for (k=d2; k; k--) dzdt[k] = &J(n, d-1, 0)

	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (g = pts.m; g; g--) { // iterate over draws
			pW = *(a? pts.Wa : pts.W)[g]; dlnpdxug = dlnpdxug1; dlnpdxlg = dlnpdxlg1; dlnpdtg = dlnpdtg1; dbudxu = dbudxl = nd0; dbudt = nd20

			// custom-coded first iteration over dimensions
			u = (*pW[1])[|sW|]
			dzda = 1 :/ normalden(z[,1] = sign1 :* invnormal(sign1 :* u :* p1 :+ Phibl1))
			t = u :* dzda; dzdbu = phibu1 :* t; dzdbl = phibl1 :* (dzda :- t)

			(*dzdt[1])[,1] = ( (*dzdxu[1])[,1] = dzdbu / Td[1] ) :* -bu1 - ( (*dzdxl[1])[,1] = dzdbl / Td[1] ):* bl1

			sz[2,2] = j2 = 1
			for (j=2; j<=d-1; sz[2,2]=j++) { // iterate over dimensions
				l = (j2 = j2 + j)

				t = z[|sz|] * (Tj = *pT[j])
				bu = _Xu[,j] + t; bl = _Xl[,j] + t; 
				sign = (bl+ bu:<=0)*2 :- 1
				Phibu = normal(sign:*bu); phibu = normalden(bu)
				Phibl = normal(sign:*bl); phibl = normalden(bl)
				

				pragma unset pg
				pgj = abs(Phibu - Phibl)                                           // probability factor for this dimension
				pg = j==2? pgj : pg:*pgj                                                // cumulative product of probability factors sans first 1
				dlnpgjdbu = phibu :/ pgj                                                // dlnp_j/dbu_j = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))
				dlnpgjdbl = phibl :/ pgj                                                // abs(dlnp_j/dbu_j) = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))

				u = (*pW[j])[|sW|]                                                      // the draws
				dzda = 1:/ normalden(z[,j] = sign:* invnormal(sign :* u :* pgj :+ Phibl))              // z_j = invPhi(a_j). dz_j/da_j = 1/phi(z_j)
				t = u :* dzda; dzdbu = phibu :* t; dzdbl = phibl :* (dzda :- t)         // dz_j/dbu_j = u_j * phi(bu_j)/phi(z_j). dz_j/dbl_j = (1-u_j) * phi(bl_j)/phi(z_j)

				dzdb = dzdbu + dzdbl                                                    // total derivative w.r.t bu and bl useful since in most cases dbu's=dbl's
				for (k=j-1; k; k--)                                                     // case j = i > k
					(*dzdt[l])[,j] = dzdb :*                                         // dz_j/dt_jk = dz_j/dbu_j * dbu_j/dt_jk + dz_j/dbl_j * dbl_j/dt_jk
						(dbudt[,--l] = z[,k] / -Td[j])                            // dbu_j/dt_jk = dbl_j/dt_jk = -z_k/t_jj  
				for (i=j-1; i; i--) {                                                   // case j > i >= k
					(*dzdxu[i])[,j] = dzdb :*                                         // dz_j/dxu_i = dz_j/dbu_j * dbu_j/dxu_i + dz_j/dbl_j * dbl_j/dxu_i 
					            (dbudxu[,i] = (*dzdxu[i])[|sz|] * Tj)                 // dbu_j/dxu_i = dbl_j/dxu_i = -sum_j(t_jk * dz_k/dxu_i) / t_jj     

					(*dzdxl[i])[,j] = dzdb :*                                         // dz_j/dxl_i = dz_j/dbu_j * dbu_j/dxl_i + dz_j/dbl_j * dbl_j/dxl_i
					            (dbudxl[,i] = (*dzdxl[i])[|sz|] * Tj)                 // dbu_j/dxl_i = dbl_j/dxl_i = -sum_j(t_jk * dz_k/dxl_i) / t_jj
	
					for (k=i; k; k--)
						(*dzdt[l])[,j] = dzdb :*                                  // dz_j/dt_ik = dz_j/dbu_j * dbu_j/dt_ik + dz_j/dbl_j * dbl_j/dt_ik
							(dbudt[,l] = (*dzdt[--l])[|sz|] * Tj)              // dbu_j/dt_ik = dbl_j/dt_ik = -sum_h(t_jh * dz_h/dt_ik) / t_jj
				}

				dbldxu = dbudxu; dbldxl = dbudxl; dbldt = dbudt                         // except for next calculations, dbu's = dbl's
				t = dbudxu[,j] = dbldxl[,j] = *dbdx0[j]                                 // dbu_j/dxu_j = dbl_j/dxl_j = 1/t_jj (dbu_j/dxl_j = dbl_j/dxu_j = 0)
				(*dzdxu[j])[,j] = dzdbu :* t                                            // dz_j/dxu_j = dz_j/dbu_j * dbu_j/dxu_j ( + dz_j/dbl_j * dbl_j/dxu_j = 0)
				(*dzdxl[j])[,j] = dzdbl :* t                                            // dz_j/dxl_j = dz_j/dbl_j * dbl_j/dxl_j ( + dz_j/dbu_j * dbu_j/dxu_j = 0)
    
				_editvalue(bu, maxdouble(), 0); _editvalue(bl, -maxdouble(), 0)
				(*dzdt[j2])[,j] = dzdbu :* (dbudt[,j2] = bu / -Td[j]) +                 // case j = i = k.  dbu_j/dt_jj = -bu/t_jj. dbl_j/dt_jj = -bl/t_jj
				                  dzdbl :* (dbldt[,j2] = bl / -Td[j])                   // dz_j/dt_jj = dz_j/dbu_j * dbu_j/dt_jj + dz_j/dbl_j * dbl_j/dt_jj 

				dlnpdxug = dlnpdxug + dlnpgjdbu :* dbudxu - dlnpgjdbl :* dbldxu         // dlnp_j/dxu_(j) = dlnp_j/dbu_j * dbu_j/dxu_(j) - abs(dlnp_j/dbl_j) * dbl_j/dxu_(j)
				dlnpdxlg = dlnpdxlg + dlnpgjdbu :* dbudxl - dlnpgjdbl :* dbldxl         // dlnp_j/dxl_(j) = dlnp_j/dbu_j * dbu_j/dxl_(j) - abs(dlnp_j/dbl_j) * dbl_j/dxl_(j)
				dlnpdtg  = dlnpdtg  + dlnpgjdbu :* dbudt  - dlnpgjdbl :* dbldt          // dlnp_j/dt_(j)  = dlnp_j/dbu_j * dbu_j/dt_(j)  - abs(dlnp_j/dbl_j) * dbl_j/dt_(j)
			}
			// custom-coded last iteration
			t = z * (Tj = *pT[d])
			bu = _Xu[,j] + t; bl = _Xl[,j] + t; 
			sign = (bl+ bu:<=0)*2 :- 1
			pgj = abs(normal(sign:*bu) - normal(sign:*bl))

			dlnpgjdbu = normalden(bu) :/ pgj
			dlnpgjdbl = normalden(bl) :/ pgj

			p = p + (pg = d==2? pgj: pg :* pgj)

			dbudt[|.,d2-d+1\.,d2-1|] = z[|.,.\.,d-1|] / -Td[d]

			l = d2 - d
			for (i=d-1; i; i--) {
				dbudxu[,i] = *dzdxu[i] * Tj
				dbudxl[,i] = *dzdxl[i] * Tj
				for (k=i; k; k--) dbudt[,l--] = *dzdt[l] * Tj
			}
			dbldxu = dbudxu; dbldxl = dbudxl; dbldt = dbudt
			dbudxu[,d] = dbldxl[,d] = *dbdx0[d]
			_editvalue(bu, maxdouble(), 0); _editvalue(bl, -maxdouble(), 0)
			dbudt[,d2] = bu / -Td[d]
			dbldt[,d2] = bl / -Td[d]
			
			dfdxu = dfdxu + (dlnpdxug + dlnpgjdbu :* dbudxu - dlnpgjdbl :* dbldxu) :* pg 
			dfdxl = dfdxl + (dlnpdxlg + dlnpgjdbu :* dbudxl - dlnpgjdbl :* dbldxl) :* pg 
			dfdv  = dfdv  + (dlnpdtg  + dlnpgjdbu :* dbudt  - dlnpgjdbl :* dbldt)  :* pg
		}
	p1 = p1 / (anti? 2*pts.m : pts.m)
	dfdxu = dfdxu :* p1
	dfdxl = dfdxl :* p1
	t = T; for (j=d; j; j--) for(i=j; i; i--) t[j,i] = d2--
	dfdv = (dfdv :* p1)[,vech(t)] * ghk2_dTdV(T)
	return (p :* p1)
}

mata mlib create lghk2, dir(PLUS) replace
mata mlib add lghk2 *(), dir(PLUS)
mata mlib index
end
