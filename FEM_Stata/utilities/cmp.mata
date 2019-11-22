mata
mata clear
mata set matastrict on
mata set mataoptimize on
mata set matalnum off

// Copyright David Roodman 2007-12. May be distributed free.
// Mata code for cmp 5.2.3 30 July 2012

struct mprobit_group {
	real scalar d // dimension
	// used in nonhierarchical models for views onto dataset
	real matrix E_in // for each mprobit group, data of eq's of unchosen alternatives and all other eqs
	real matrix E_out // for each mprobit group, eq of chosen alternative
	real matrix E_res // for each mprobit group, view of data in which relative differences are stored
	real rowvector in, out, res // columns of E corresponding to above, used in hierarchical models
	pointer (real matrix) pE_in, pE_out, pE_res
}

struct subview {
	real matrix E, F, G, U, E_cens, F_cens, E_uncens, Yi, Scores, truncreg_lower, truncreg_upper // in nonhierarchical models, views onto dataset
	pointer(real matrix) pE_uncens, pE_cens, pF_cens, ptruncreg_lower, ptruncreg_upper
	real colvector subsample, SubsampleInds, one2N
	real scalar ghk_start, ghk_start_truncreg // starting indexes in ghk2() point structure
	real scalar d_uncens, d_cens, d2_cens, d_two_cens, d_oprobit, d_truncreg, N
	real scalar NumCuts // number of cuts in ordered probit eqs relevant for *these* observations
	real matrix dSig_dLTSig // derivative of Sig w.r.t. its lower triangle
	real scalar bounded // d_oprobit? d_one_cens+1..d_cens:J(1,0,0)
	real scalar N_perm, num_roprobit_groups, num_mprobit_groups
	real colvector cens_LT_inds // indexes of lower triangle of a vectorized square matrix of dimension d_cens
	real colvector lnL
	real rowvector uncens, two_cens, oprobit, cens, truncreg, one2d_truncreg
	real rowvector cens_uncens // one_cens, oprobit, uncens
	real rowvector Sig_inds_uncens // Indexes, within the vectorized upper triangle of Sig, entries for the eqs uncens at these obs
	real rowvector Sig_inds_trunc // Ditto for truncreg obs
	real rowvector Sig_inds_cens_uncens // Permutes vectorized upper triangle of Sig to order corresponding to cens eqs first
	real rowvector CutInds // Indexes, within full list of oprobit cuts, of those relevant for the equations in these observations
	real rowvector vNumCuts // number of cuts per eq for the eq for *these* observations
	real matrix Q_Sig   // correction factor for trial cov matrix reflecting scores of passed "error" (XB,-XB,Y-XB, or XB-Y) w.r.t XB
	real matrix Sig     // Sig, reflecting that correction
	real matrix Q_E     // ditto for matrix D, the scores of Sig w.r.t lnsig's and atanhrho's
	real rowvector ThetaSign     // derivative of errors with respect to theta, factoring in only computations in cmp_lf1
	real scalar d_cens_nonrobase
	real matrix J_N_NumCuts_0, J_N_d_0, J_N_d2_0, J_N_d2_uncens_0, J_N_d2_cens_uncens_0, J_d_uncens_d_cens_0, J_N_d_cens_0, J_d_cens_d_0, J_d2_cens_d2_0

	pointer (real rowvector) colvector roprobit_Q_E // for each roprobit permutation, matrix that effects roprobit differencing of E_cens columns
	pointer (real rowvector) colvector roprobit_Q_Sig // ditto for vech() of Sigma of censored E columns
	struct mprobit_group colvector mprobit
	
	pointer (struct subview scalar) scalar next
}

struct smatrix {
	real matrix X
}

struct RE {
	real matrix E, F, G
	real scalar N // number of groups at this level
	real colvector one2N
	real rowvector one2d, one2R
	real scalar d, d2 // dimension of this random effect, corresponding triangular number
	real scalar ThisDraw
	real matrix Sig
	real matrix D // derivative of vech(Sig) w.r.t lnsigs and atanhrhos
	real matrix dSig_dT // derivative of vech(Sig) w.r.t vech(cholesky(Sig))
	real matrix dlnL_dT // holder for scores w.r.t T
	pointer (real matrix) colvector U // draws/observation-vector of pointers to N_g x d sets of draws
	pointer (real matrix) matrix Uj // draws/observation x d matrix of pointers to N_g-vectors sets of draws--to avoid repeatedly extracting same columns
	struct smatrix colvector UT // draws transformed by transposed Cholesky of trial covariance
	real matrix id // group id var
	real matrix IDRangesGroup // N x 1, max id for each group's subgroups in the next level down
	real matrix lnL, lnLByDraw
	struct smatrix colvector Scores // Score matrices for each draw
	real colvector Weights // weights at this level, one obs per group, renormalized if pweights or aweights
	real colvector WeightProduct // obs-level product of weights at all levels, for weighting scores
	real colvector J_N_1_0
	real matrix J_d_d_0, J_N_NumREDraws_0, J_N_d2_0
	
	// stash here to avoid slow references to externals
	transmorphic ghk2DrawSet
	real scalar ghkAnti, lnsmalldouble, lnmaxdouble, NumCuts
	pointer(real matrix) colvector dSigdParams
}

// insert row vector into a matrix at specified row
real matrix insert(real matrix X, real scalar i, real rowvector newrow)
	return (i==1? newrow\X : (i==rows(X)+1? X\newrow : X[|.,.\i-1,.|] \ newrow \ X[|i,.\.,.|]))

// paste columns into matrix at given starting index, then advance index
void PasteAndAdvance(real matrix A, real scalar i, real matrix B) {
	real scalar t
	t = i + cols(B)
	A[|.,i \ .,t-1|] = B
	i = t
}

// given a vector of 0's and 1's, return indices of the 1's
// if v = 0 (and can't tell if row or col vector), returns rowvector J(1, 0, 0) 
real vector OneInds(real vector v) {
	real colvector i, t; real matrix w
	pragma unset i; pragma unset w
	maxindex((cols(v)==1? v \ 0 : v, 0), 1, i, w)
	t = rows(i)>length(v)? J(0, 1, 0) : i
	return (cols(v)==1 & rows(v)!=1? t : t')
}

// remove top row of matrix
real matrix cdr(real matrix X)
	return (rows(X)>1? X[|2,.\.,.|] : J(0, cols(X), 0))

// Given ranking potentially with ties, return matrix of all un-tied rankings consistent with it, one per row
real matrix PermuteTies(real vector v) {
	real colvector Indexes; real matrix  TiedRanges
	pragma unset   Indexes; pragma unset TiedRanges
	minindex(v, ., Indexes, TiedRanges)
	TiedRanges[,2] = rowsum(TiedRanges) :- 1
	return (_PermuteTies(Indexes, TiedRanges', rows(TiedRanges))')
}
real matrix _PermuteTies(real colvector Indexes, real matrix TiedRanges, real scalar ThisRank) {
	real colvector info, p, t; real matrix RetVal
	RetVal = J(rows(Indexes), 0, .)
	info = cvpermutesetup(Indexes[| p = TiedRanges[,ThisRank] |], 0)
	while (rows(t = cvpermute(info))) {
		Indexes[|p|] = t
		RetVal = RetVal, ( ThisRank==1? Indexes : _PermuteTies(Indexes, TiedRanges, ThisRank-1) )
	}
	return (RetVal)
}

// given indexes for variables, and dimension of variance matrix, return corresponding indexes in vectorized variance matrix
// e.g., (1,3) ->((1,1), (3,1), (3,3)) -> (1, 3, 6)
real rowvector vSigInds(real rowvector inds, real scalar d)
	return (vech(invvech(1::d*(d+1)*0.5)[inds,inds])')

// Given transformation matrix for errors, return transformation matrix for vech(covar)
real matrix QE2QSig(real matrix Q_E) {
	real scalar i, j, l, d; real matrix Q_Sig
	d = rows(Q_E); l = d*(d+1)*.5
	Q_Sig = J(cols(Q_E)*(cols(Q_E)+1)*.5, l, 0)
	for (j=d; j; j--) {
		for (i=d; i>j; i--)
			Q_Sig[,l--] = vech(cross(Q_E[i,], Q_E[j,]) + cross(Q_E[j,], Q_E[i,]))
		Q_Sig[,l--] = vech(cross(Q_E[j,], Q_E[j,]))
	}
	return (Q_Sig)
}

// compute normal(F) - normal(E) while maximizing precision
// In Mata, 1 - normal(10) should = normal(-10) but the former = 0 because normal(10) is close to 1
// Ergo the best way to compute the former is to do the latter
// F = . means +infinity. E = . means -infinity
real colvector normal2(real colvector E, real colvector F) {
	real colvector sign, _E, _F
	_E = editmissing(E, -maxdouble()); _F = editmissing(F, maxdouble())
	sign = (_F+_E:<0) * 2 :- 1
	return (abs(normal(sign:*_F) - normal(sign:*_E)))
}

// apply binormal() to columns of values. Accepts general covariance matrix, not just rho parameter
// infsign flags indicate whether to interpret . as + or - infinity. 1=+, 0=-
// optionally computes scores
real colvector vecbinormal(real matrix X, real matrix Sig, real scalar infsign1, real scalar infsign2, real colvector one2N, real scalar todo, real matrix dPhi_dX, real matrix dPhi_dSig) {
	real colvector Phi, Xhat, X_2
	real matrix dPhi_dSigdiag, phi, X_
	real scalar rho
	real rowvector Sigdiag, sqrtSigdiag

	Xhat = X :/ (sqrtSigdiag = sqrt(Sigdiag = diagonal(Sig)'))
	rho = Sig[1,2]/(sqrtSigdiag[1]*sqrtSigdiag[2])
	Phi = binormal(editmissing(Xhat[one2N,1], infsign1? maxdouble() : -maxdouble()), 
	               editmissing(Xhat[one2N,2], infsign2? maxdouble() : -maxdouble()), rho)

	if (todo) {
		phi = editmissing(normalden(Xhat), 0)
		X_ = Xhat * ((1,-rho \ -rho,1) / sqrt(1-rho*rho)) // each X_ with the other partialled out, then renormalized to s.d. 1
		dPhi_dSig = phi[one2N,1] :* editmissing(normalden(X_2=X_[one2N,2]),0) / sqrt(det(Sig))
		dPhi_dX = phi :* (editmissing(normal(X_2), infsign2), editmissing(normal(X_[one2N,1]), infsign1)) :/ sqrtSigdiag
		dPhi_dSigdiag = (editmissing(X, 0):*dPhi_dX :+ (Sig[1,2]*dPhi_dSig)) :/ (-2 * Sigdiag) 
		dPhi_dSig = dPhi_dSigdiag[one2N,1], dPhi_dSig, dPhi_dSigdiag[one2N,2]
	}
	return (Phi)
}

// neg_half_E_Dinvsym_E() -- compute -0.5 * inner product of given errors weighting by derivative of inverse of a symmetric matrix 
// Passed +/- E times the inverse of X. Returns a matrix with one column for each of the N(N+1)/2 entries in X.
real matrix neg_half_E_Dinvsym_E(real matrix E_invX, real colvector one2N, real matrix EDE) {
	real colvector E_invX_j; real scalar N, j, l
	if (N = cols(E_invX)) {
		l = cols(EDE)
		E_invX_j = E_invX[one2N,N]
		EDE[,l--] = E_invX_j :* E_invX_j * .5
		for (j=N-1; j; j--) {
			E_invX_j = E_invX[one2N,j]	
			EDE[|.,l-N+j+1 \ .,l|] = E_invX[|.,j+1 \ .,N|] :* E_invX_j // effectively double off-diagonal entries since symmetric
			l = l - N + j
			EDE[one2N,l--] = E_invX_j:*E_invX_j * .5
		}
	}
	return (EDE)
}

// Compute product of derivative of Phi w.r.t. partialled-out errors (provided) and derivative of partialled-out errors w.r.t. 
// original covariance matrix. Used as part of an application of the chain rule to transform the initial scores for Phi
// w.r.t. the partialled-out errors and covariance matrix into scores w.r.t. the un-partialled ones.
// Returns a score matrix with one row for each observation and one column for each element of the lower triangle of
// Var[in | out], ordered by the lists in parameters "in" and "out". E.g. if in=(1,3) and out=(2), then the column 
// order corresponds to (1,1),(1,3),(1,2),(3,3),(3,2),(2,2)
real matrix dPhi_dpE_dSig(real matrix E_out, real scalar N, real colvector one2N, real matrix beta, real matrix invSig_out, real matrix Sig_out_in, 
					real matrix dPhi_dpE, real scalar lin, real scalar lout, real matrix scores, real matrix J_d_uncens_d_cens_0) {
	real matrix neg_dbeta_dSig; real rowvector beta_j; real colvector invSig_out_j; real scalar i, j, l

	l = lin + lout
	for(l=j=1; j<=lin; j++) {
		// scores w.r.t. sig_ij where both i,j are in are 0, so skip those columns in score matrix
		l = l + lin - j + 1
		// scores w.r.t. sig_ij where i out and j in 
		for(i=1; i<=lout; i++) {
			(neg_dbeta_dSig = J_d_uncens_d_cens_0)[,j] = -invSig_out[,i]
			scores[one2N,l++] = quadrowsum(dPhi_dpE :* (E_out * neg_dbeta_dSig))
		}
	}
	// scores w.r.t. sig_ij where both i,j out
	for(j=1; j<=lout; j++) {
		beta_j = beta[j,]; invSig_out_j = invSig_out[,j]
		neg_dbeta_dSig = invSig_out_j * quadcross(invSig_out_j, Sig_out_in)
		scores[one2N,l++] = quadrowsum(dPhi_dpE :* (E_out * neg_dbeta_dSig))
		for(i=j+1; i<=lout; i++) {
			neg_dbeta_dSig = invSig_out[,i] * beta_j + invSig_out_j * beta[i,]
			scores[one2N,l++] = quadrowsum(dPhi_dpE :* (E_out * neg_dbeta_dSig))
		}
	}
	return (scores)
}

// (log) likelihood and scores for cumulative multivariate normal for a vector of observations of upper bounds and optional lower bounds
// i.e., computes multivariate normal cdf over L_1<=x_1<=U_1, L_2<=x_2<=U_2, ..., where some L_i's can be negative infinity
// Arguments -unbounded- and  -bounded- indicate which dimensions have lower bounds. Argument E should still have 2d columns with the 
// left half holding upper bounds and the right optional lower bounds.
// If argument N_perm>1, then returns Phi, not log Phi
// returns scores if requested in dPhi_dE, dPhi_dF, dPhi_dSig
real colvector vecmultinormal(real matrix E, real matrix F, real matrix Sig, real scalar d, real rowvector bounded, real colvector one2N, real scalar todo, 
						real matrix dPhi_dE, real matrix dPhi_dF, real matrix dPhi_dSig, transmorphic ghk2DrawSet, real scalar ghkAnti, real scalar ghk_start, real scalar N_perm, real matrix J_N_d_cens_0) {
	real matrix dPhi_dE2, dPhi_dSig2
	pragma unset dPhi_dE2; pragma unset dPhi_dSig2
	real colvector Phi

	if (d == 1) {
		real scalar sqrtSig
		sqrtSig = sqrt(Sig)
		if (cols(bounded)) {
			Phi = normal2(F/sqrtSig, E/sqrtSig)
			if (todo) { // Compute partial deriv w.r.t. sig^2 in 1/sqrt(sig^2) term in normal dist
				if (N_perm == 1) {
					dPhi_dE =  editmissing(normalden(E, 0, sqrtSig), 0) :/ Phi
					dPhi_dF = -editmissing(normalden(F, 0, sqrtSig), 0) :/ Phi
				}
				dPhi_dSig = (rowsum(dPhi_dE :* E) + rowsum(dPhi_dF :* F)) / (-2 * Sig)
			}
		} else {
			Phi = normal(E / sqrtSig)
			if (todo) {
				if (N_perm == 1) dPhi_dE = editmissing(normalden(E, 0, sqrtSig), 0) :/ Phi
				dPhi_dSig = dPhi_dE :* E / (-2 * Sig)
			}
		}
		return (N_perm==1? ln(Phi) : Phi)
	}
	if (d == 2) {
		Phi = vecbinormal(E, Sig, 1, 1, one2N, todo, dPhi_dE, dPhi_dSig)
		if (cols(bounded)) {
			if (todo) dPhi_dF = J_N_d_cens_0
			if (anyof(bounded,1)) {
				Phi = Phi - vecbinormal((F[one2N,1],E[one2N,2]), Sig, 0, 1, one2N, todo, dPhi_dE2, dPhi_dSig2)
				if (todo) {
					dPhi_dE[one2N,2] = dPhi_dE[one2N,2] - dPhi_dE2[one2N,2]
					dPhi_dF[one2N,1] = dPhi_dF[one2N,1] - dPhi_dE2[one2N,1]
					dPhi_dSig = dPhi_dSig - dPhi_dSig2
				}
			}
			if (anyof(bounded,2)) {
				Phi = Phi - vecbinormal((E[one2N,1],F[one2N,2]), Sig, 1, 0, one2N, todo, dPhi_dE2, dPhi_dSig2)
				if (todo) {
					dPhi_dE[one2N,1] = dPhi_dE[one2N,1] - dPhi_dE2[one2N,1]
					dPhi_dF[one2N,2] = dPhi_dF[one2N,2] - dPhi_dE2[one2N,2]
					dPhi_dSig = dPhi_dSig - dPhi_dSig2
				}
			}
			if (rowsum(bounded) == 3) {
				Phi = Phi + vecbinormal(F, Sig, 0, 0, one2N, todo, dPhi_dE2, dPhi_dSig2)
				if (todo) {
					dPhi_dF   = dPhi_dF   + dPhi_dE2
					dPhi_dSig = dPhi_dSig + dPhi_dSig2
				}
			}
		}
	} else 
		Phi = cols(bounded)? (todo? _ghk2_2d(ghk2DrawSet, F, E, Sig, ghkAnti, ghk_start, dPhi_dF, dPhi_dE, dPhi_dSig) :
	                                _ghk2_2 (ghk2DrawSet, F, E, Sig, ghkAnti, ghk_start)) :
	                         (todo? _ghk2_d (ghk2DrawSet,    E, Sig, ghkAnti, ghk_start,          dPhi_dE, dPhi_dSig) :
	                                _ghk2   (ghk2DrawSet,    E, Sig, ghkAnti, ghk_start))

	if (todo & N_perm==1) {
		dPhi_dE = dPhi_dE :/ Phi
		dPhi_dSig = dPhi_dSig :/ Phi
		if (cols(bounded)) dPhi_dF = dPhi_dF :/ Phi
	}
	return (N_perm==1? ln(Phi) : Phi)
}

// compute the log likelihood associated with a given error data matrix, for "continuous" variables
// Sig is the assumed covariance for the full error set and inds marks the observed variables assumed to have a joint normal distribution,
// i.e., the ones not censored
real colvector cmp_lnL_continuous(pointer(struct subview scalar) scalar v, pointer (struct RE colvector) pREs, real scalar d, real scalar d2, real scalar todo, real matrix dphi_dE, real matrix dphi_dSig) {
	real matrix C, t, dPhi_dF, dPhi_dG, lnL, Sig_, invSig, dPhi_dSig_trunc; real rowvector in, truncreg; real scalar d_truncreg
	pragma unset t; pragma unset dPhi_dF; pragma unset dPhi_dG; pragma unset dPhi_dSig_trunc

	in = v->uncens; truncreg = v->truncreg; d_truncreg = v->d_truncreg; Sig_ = v->Sig[in, in]
	C = luinv(cholesky(Sig_))
	lnL = quadrowsum(lnnormalden(*(v->pE_uncens)* C')) :+ ln(dettriangular(C))

	if (d_truncreg)
		lnL = lnL - vecmultinormal(*(v->ptruncreg_upper), *(v->ptruncreg_lower),
								    v->Sig[truncreg,truncreg], d_truncreg, v->one2d_truncreg, v->one2N, todo, 
						            dPhi_dF, dPhi_dG, dPhi_dSig_trunc, pREs->ghk2DrawSet, pREs->ghkAnti, v->ghk_start_truncreg, 1, v->J_N_d_cens_0)

	if (todo) {
		t = *(v->pE_uncens) * -(invSig = cholinv(Sig_))
		(dphi_dE = v->J_N_d_0)[v->one2N, in] = t

		(dphi_dSig = v->J_N_d2_0)[v->one2N, v->Sig_inds_uncens] = neg_half_E_Dinvsym_E(t, v->one2N, v->J_N_d2_uncens_0) :- vech(invSig - diag(invSig)*.5)'
		if (d_truncreg) {
			dphi_dE[v->one2N, truncreg] = dphi_dE[v->one2N, truncreg] - (dPhi_dF +  dPhi_dG) 
			dphi_dSig[v->one2N, v->Sig_inds_trunc] = dphi_dSig[v->one2N, v->Sig_inds_trunc] - dPhi_dSig_trunc
		}
	}
	return (lnL)
}

// log likelihood and scores for cumulative normal
// returns scores in the optional arguments dPhi_dE, dPhi_dSig
real colvector cmp_lnL_censored(pointer(struct subview scalar) scalar v, pointer (struct RE colvector) pREs, real scalar L, real scalar d, real scalar d2, real scalar todo,
						 real matrix dPhi_dE, real matrix dPhi_dSig, real matrix dPhi_dcuts) {
	real matrix t, pSig, this_pSig, beta, dPhi_dpE, dPhi_dpF, dPhi_dpSig, invSig_uncens, Sig_uncens_cens, S_dPhi_dpE, S_dPhi_dpSig
	real scalar ThisNumCuts, N, d_cens, d_two_cens, N_perm, ThisPerm
	real colvector Phi, i, j, S_Phi
	real rowvector uncens, cens, oprobit
	pointer (real matrix) pE, this_pE, pF, pQ_E
	pragma unset dPhi_dpE; pragma unset dPhi_dpF; pragma unset dPhi_dpSig
	
	N = v->N; uncens=v->uncens; oprobit=v->oprobit; cens=v->cens; d_cens=v->d_cens; d_two_cens=v->d_two_cens; N_perm=v->N_perm; ThisNumCuts=v->NumCuts
	for (i=v->num_mprobit_groups; i; i--) // relative-difference mprobit errors
		if (v->mprobit[i].d)
			if (L==1)
				(v->mprobit[i].E_res)[,] = v->mprobit[i].E_in :- v->mprobit[i].E_out
			else
				*(v->pE_cens)[v->one2N,v->mprobit[i].res] = (*pREs)[L].E[v->SubsampleInds,v->mprobit[i].in] :- (*pREs)[L].E[v->SubsampleInds,v->mprobit[i].out]

	// Partial continuous variables out of the censored ones
	if (v->d_uncens) {
		beta = (invSig_uncens = cholinv(v->Sig[uncens,uncens])) * (Sig_uncens_cens = v->Sig[uncens, cens])
		t = *(v->pE_uncens) * beta
		this_pE = pE = &(*(v->pE_cens) - t)                   // partial out errors from upper bounds
		pF = &(d_two_cens? *(v->pF_cens) - t : J(0,0,0))              // partial out errors from lower bounds
		this_pSig = pSig = v->Sig[cens, cens] - quadcross(Sig_uncens_cens, beta) // corresponding covariance
	} else {
		this_pE = pE = v->pE_cens
		pF = d_two_cens? v->pF_cens : &J(0,0,0)
		this_pSig = pSig = v->Sig[cens, cens]
	}

	for (ThisPerm = N_perm; ThisPerm; ThisPerm--) {  
		if (v->num_roprobit_groups) {
			pQ_E = v->roprobit_Q_E[ThisPerm]
			this_pE = &(*pE * *pQ_E)
			this_pSig = cross(*pQ_E, pSig) * *pQ_E
		}

		Phi = vecmultinormal(*this_pE, *pF, this_pSig, v->d_cens_nonrobase, v->two_cens, v->one2N, todo, dPhi_dpE, dPhi_dpF, dPhi_dpSig, 
		                            pREs->ghk2DrawSet, pREs->ghkAnti, v->ghk_start, N_perm, v->J_N_d_cens_0)

		if (todo & v->num_roprobit_groups) {
			dPhi_dpE = dPhi_dpE * *pQ_E'
			dPhi_dpSig = dPhi_dpSig * *v->roprobit_Q_Sig[ThisPerm]
		}
		
		if (N_perm > 1)
			if (ThisPerm == N_perm) {
				S_Phi = Phi
				if (todo) {
					S_dPhi_dpE = dPhi_dpE
					S_dPhi_dpSig = dPhi_dpSig
				}
			} else {
				S_Phi = S_Phi + Phi
				if (todo) {
					S_dPhi_dpE = S_dPhi_dpE + dPhi_dpE
					S_dPhi_dpSig = S_dPhi_dpSig + dPhi_dpSig
				}
			}
	}

	if (N_perm > 1) {
		Phi = ln(S_Phi)
		if (todo) {
			dPhi_dpE = S_dPhi_dpE :/ S_Phi
			dPhi_dpSig = S_dPhi_dpSig :/ S_Phi
		}
	}

	if (todo) {
		real matrix dpE_dE, dpSig_dSig, dPhi_dpE_dSig, dPhi_dpF_dSig, dPhi_dF; real scalar lcut, lcat
		pointer (real colvector) pYi_lcat, pYi_lcatm1

		// Translate scores w.r.t. partialled errors and variance to ones w.r.t. unpartialled ones
		if (v->d_uncens) {
			t = I(cols(beta)), -beta'
			(dpE_dE = v->J_d_cens_d_0)[, v->cens_uncens] = t
			dPhi_dE = dPhi_dpE * dpE_dE
			(dpSig_dSig = v->J_d2_cens_d2_0)[, v->Sig_inds_cens_uncens] = (t#t)[v->cens_LT_inds,] * v->dSig_dLTSig
			(dPhi_dpE_dSig = v->J_N_d2_0)[v->one2N, v->Sig_inds_cens_uncens] = 
					dPhi_dpE_dSig(*(v->pE_uncens), N, v->one2N, beta, invSig_uncens, Sig_uncens_cens, dPhi_dpE, d_cens, v->d_uncens, 
										v->J_N_d2_cens_uncens_0, v->J_d_uncens_d_cens_0)
			dPhi_dSig = dPhi_dpSig * dpSig_dSig + dPhi_dpE_dSig
		} else {
			(dPhi_dE   = v->J_N_d_0 )[v->one2N, v->cens_uncens         ] = dPhi_dpE
			(dPhi_dSig = v->J_N_d2_0)[v->one2N, v->Sig_inds_cens_uncens] = dPhi_dpSig
		}

		dPhi_dcuts = v->J_N_NumCuts_0
		if (d_two_cens) {
			if (v->d_uncens) {
				dPhi_dF = dPhi_dpF * dpE_dE
				(dPhi_dpF_dSig = v->J_N_d2_0)[v->one2N, v->Sig_inds_cens_uncens] = 
						dPhi_dpE_dSig(*(v->pE_uncens), N, v->one2N, beta, invSig_uncens, Sig_uncens_cens, dPhi_dpF, d_cens, v->d_uncens, 
											v->J_N_d2_cens_uncens_0, v->J_d_uncens_d_cens_0)
				dPhi_dSig = dPhi_dSig + dPhi_dpF_dSig
			} else
				(dPhi_dF = v->J_N_d_0)[v->one2N, v->cens_uncens] = dPhi_dpF
				
			if (ThisNumCuts) {
				lcat = (lcut = ThisNumCuts) + (i = v->d_oprobit) + 1
				for (; i; i--) { // for each oprobit eq
					pYi_lcat = &(v->Yi[v->one2N, --lcat])
					for (j = (v->vNumCuts)[i]; j; j--) {
						pYi_lcatm1 = &(v->Yi[v->one2N, --lcat])
						dPhi_dcuts[v->one2N, (v->CutInds)[lcut--]] = dPhi_dE[v->one2N, oprobit[i]] :* *pYi_lcatm1 + dPhi_dF[v->one2N, oprobit[i]] :* *pYi_lcat
						pYi_lcat = pYi_lcatm1
					}
				}
			}
			dPhi_dE = dPhi_dE + dPhi_dF // add lower- and upper-bound Phi scores
		}
	}
	return (Phi)
}

// return value indicates whether parameters feasible. .=infeasible
// lf indicates lf or lf1 estimator:  name of variable to receive log likelihoods (otherwise stored in var _cmp_lnfi)
// ScoreVars indicates pseudo-d2 or lf1 estimate: contains names of variables to store scores in








































real scalar cmp_lnL(real scalar todo, string scalar lf, | string scalar ScoreVars) {
	real matrix Sig, t, dphi_dE, dphi_dSig, dPhi_dE, dPhi_dSig, dPhi_dcuts, D, UT, L_g
	real scalar i, j, l, l2, r, d, d2, L, NumScores
	real rowvector sig, atanhrho, one2d, one2NumScores
	real colvector this_lnL, shift, NumREDraws
	string rowvector signames, atanhrhonames 
	pointer(struct subview scalar) scalar v
	pointer(real matrix) scalar pdlnL_dtheta, pdlnL_dSig, pScores
	external pointer(struct subview scalar) scalar _subviews
	pointer(struct subview scalar) scalar subviews
	external real scalar _first_call, _interactive, _NumCuts, _NumScores, _L, _REAnti
	external real colvector _vNumCuts, _NumREDraws
	external pointer(real matrix) colvector _Eqs, _dSigdParams
	pointer(real matrix) colvector Eqs
	external struct RE colvector _REs
	pointer (struct RE colvector) pREs
	pragma unset this_lnL; pragma unset dphi_dE; pragma unset dphi_dSig; pragma unset dPhi_dE; pragma unset dPhi_dSig; pragma unset dPhi_dcuts

	L = _L
	signames = tokens(st_local("sigs"))
	atanhrhonames = tokens(st_local("rhos"))
	one2d = 1.. (d = cols(st_matrix(signames[L]))); d2 = d*(d+1)*.5
	pREs=&_REs; Eqs=_Eqs; one2NumScores=1..(NumScores = _NumScores) // for speed, minimize direct references to externals
	
	if (_first_call | _interactive) {
		external real scalar _ghkDraws, _ghkAnti, _num_mprobit_groups, _mprobit_ind_base, _num_roprobit_groups, _roprobit_ind_base, _intreg, _truncreg, _reverse
		external real matrix _mprobit_group_inds, _roprobit_group_inds, _nonbase_cases
		external string scalar _ghkType, _REType
		real scalar N, ghk_nobs, k, d_one_cens_nonrobase, d_cens_nonrobase, d_two_cens, d_oprobit, d_mprobit, d_roprobit, d_cens, d_uncens, d_truncreg, start, stop, PrimeIndex
		real scalar Hammersley, NumDraws
		real matrix Yi, indicators, U, T
		real colvector ML_samp, left, S
		real rowvector TheseInds, oprobit, one_cens, one_cens_nonrobase, cens, uncens, intreg, truncreg, mprobit, cens_nonrobase, Primes, out, in, res
		pointer(struct subview scalar) scalar next
		string scalar Yinames
		pragma unset indicators; pragma unset Yi; pragma unset ML_samp
		
		pREs = &(_REs = RE(L, 1))
		NumREDraws = _NumREDraws
		pREs->ghkAnti = _ghkAnti
		pREs->NumCuts = _NumCuts
		pREs->lnsmalldouble = ln(smallestdouble()) + 1
		pREs->lnmaxdouble = ln(maxdouble()) - 1

		st_view(indicators, ., "_cmp_rev_ind" :+ strofreal(one2d)) // already revised to combine probit, tobit cases
		st_view(ML_samp, ., st_global("ML_samp"))
		st_view(pREs->E, ., "_cmp_e" :+ strofreal(one2d))
		if (pREs->NumCuts | _intreg | _truncreg) st_view(pREs->F, ., "_cmp_f" :+ strofreal(one2d))
		if (_truncreg)                           st_view(pREs->G, ., "_cmp_g" :+ strofreal(one2d))
		
		(*pREs)[L].one2N = 1 :: (N = rows(pREs->E))
		
		if (L > 1)
			(*pREs)[L].lnL = J(N, 1, 0)
		else if (strlen(lf) == 0)
			st_view((*pREs)[L].lnL, ., "_cmp_lnfi")

		Primes = 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97
		if (_REType != "random" & length(Primes) < sum(st_matrix("cmp_levels")) + d - 1 - (_ghkType=="hammersley" || _REType=="hammersley")) {
			errprintf("Number of unobserved variables to simulate too high for Halton-based simulation. Try {cmd retype(random)}.\n")
			return (.) 
		}
		PrimeIndex = 1

		pREs->dSigdParams = _dSigdParams
		for (l=L; l; l--) {
			(*pREs)[l].ThisDraw = 1
			(*pREs)[l].d = cols(st_matrix(signames[l]))
			(*pREs)[l].d2 = (*pREs)[l].d * ((*pREs)[l].d + 1) * .5
			(*pREs)[l].one2R = 1..NumREDraws[l]
			(*pREs)[l].J_d_d_0 = J((*pREs)[l].d, (*pREs)[l].d, 0)
			(*pREs)[l].J_N_d2_0 = J(N, (*pREs)[l].d2, 0)
		}

		pREs->Scores = smatrix()
		st_view(pREs->Scores.X, ., tokens(ScoreVars))
		for (l=L-1; l; l--) {
			st_view((*pREs)[l].id, ., "_cmp_id" + strofreal(l))
			(*pREs)[l].one2N = 1 :: ( (*pREs)[l].N = (*pREs)[l].id[N] )
			(*pREs)[l].J_N_NumREDraws_0 = J((*pREs)[l].N, NumREDraws[l+1], 0)
			(*pREs)[l].J_N_1_0 = J((*pREs)[l].N, 1, 0)
			
			(*pREs)[l+1].Scores = smatrix(NumREDraws[l+1], 1)
			for (r=NumREDraws[l+1]; r; r--)
				(*pREs)[l+1].Scores[r].X = J(N, NumScores, 0)
			
			(*pREs)[l].IDRangesGroup = panelsetup(l==L-1? (*pREs)[l].id : (*pREs)[l].id[(*pREs)[l+1].IDRangesGroup[1,]], 1) '

			(*pREs)[l].one2d = 1..(*pREs)[l].d

			Hammersley = _REType=="hammersley" & l==1
			if (_first_call) {
				printf("{res}Random effects for level %f simulated.\n", l)
				printf("    Sequence type = %s\n    Number of draws per observation = %f\n    Include antithetic draws = %s\n"', _REType, NumREDraws[l+1]/_REAnti, _REAnti==2? "yes" : "no")
				if ((_REType=="halton" | _REType=="ghalton") | (Hammersley & (*pREs)[l].d>1))
					printf("    Prime base%s = %s\n", (*pREs)[l].d>1+Hammersley? "s" : "", invtokens(strofreal(Primes[PrimeIndex..PrimeIndex-1+(*pREs)[l].d-Hammersley])))
				printf(`"Each observation gets different draws, so changing the order of observations in the data set would change the results.\n\n"')
			}

			NumDraws = NumREDraws[l+1] / _REAnti
			if (_REType=="random")
				U = invnormal(uniform((*pREs)[l].N * NumDraws / _REAnti, (*pREs)[l].d))
			else if (_REType=="halton" | Hammersley) {
				U = J((*pREs)[l].N * NumDraws, (*pREs)[l].d, 0)
				if (Hammersley)
					U[,1] = invnormal(J((*pREs)[l].N,1,1) # (0.5::NumDraws)/NumDraws)
				for (r=1+Hammersley; r<=cols(U); r++)
					U[,r] = invnormal(halton2(rows(U), Primes[PrimeIndex++]))
			} else if (_REType=="ghalton") {
				U = J((*pREs)[l].N * NumDraws, (*pREs)[l].d, 0)
				for (r=1; r<=cols(U); r++)
					U[,r] = invnormal(ghalton(rows(U), Primes[PrimeIndex++], uniform(1,1)))
			} else {
//				U = invnormal( ScrHalton((*pREs)[l].N * NumREDraws[l+1], (*pREs)[l].d, &SqrtScrambler(), ., 0.5))
				PrimeIndex = PrimeIndex + cols(U)
			}
			(*pREs)[l].U = J(NumREDraws[l+1], 1, NULL)
			(*pREs)[l].Uj = J(NumREDraws[l+1], (*pREs)[l].d, NULL)
			(*pREs)[l].UT = smatrix(NumREDraws[l+1], 1)
			S = ((1::(*pREs)[l].N) * NumDraws)[(*pREs)[l].id]
			for (r=NumDraws; r; r--) {
				((*pREs)[l].U)[r]   = &U[S, (*pREs)[l].one2d]
				 (*pREs)[l].UT[r].X = J(N, d, 0)
				if (_REAnti == 2) {
					((*pREs)[l].U)[r+NumREDraws[l+1]/2]   = & (1 :- *((*pREs)[l].U)[r])
					 (*pREs)[l].UT[r+NumREDraws[l+1]/2].X = J(N, d, 0)
				}
				S = S :- 1
			}
			for (r=NumREDraws[l+1]; r; r--) // pre-compute extraction of individual columns from seed matrices
				for (j=(*pREs)[l].d; j; j--)
					((*pREs)[l].Uj)[r,j] = &(*((*pREs)[l].U[r]))[,j]
		}

		if (L > 1)
			for (l=L; l; l--)
				if (st_global("parse_wexp"+strofreal(l)) != "") {
					st_view((*pREs)[l].Weights, ., "_cmp_weight"+strofreal(l))
					(*pREs)[l].Weights = l==L? (*pREs)[l].Weights : ((*pREs)[l].Weights)[panelsetup((*pREs)[l].id, 1)[,1]] // get one instance of each group's weight
					if (sum( st_global("parse_wtype"+strofreal(l)) :== ("pweight", "aweight") )) // normalize pweights, aweights to sum to # of groups
						if (l == 1)
							pREs->Weights = (*pREs)[l].Weights / mean((*pREs)[l].Weights)
						else
							for (j=(*pREs)[l-1].N; j; j--) {
								S = (*pREs)[l-1].IDRangesGroup[,j], (.\.)
								((*pREs)[l].Weights)[|S|] = ((*pREs)[l].Weights)[|S|] / mean(((*pREs)[l].Weights)[|S|])
							}
					t = l==L? (*pREs)[l].Weights : ((*pREs)[l].Weights)[(*pREs)[l].id]
					pREs->WeightProduct = rows(pREs->WeightProduct)? pREs->WeightProduct :* t : t
				}

		for (l=L-1; l; l--)
			(*pREs)[l].IDRangesGroup = (*pREs)[l].IDRangesGroup[2,]'
			
		ghk_nobs = 0; v = NULL

		left = (1::N) :* ML_samp
		while (t = max(left)) {
			next = v; (*(v = &(subview()))).next = next  // add new subview to linked list
			left = left :* !(v->subsample = rowmin(indicators :== (TheseInds = indicators[t,])) :& ML_samp)
			if (L > 1)
				v->SubsampleInds = OneInds(v->subsample)
			else
				st_select(v->E, pREs->E, v->subsample)

			if (strlen(lf)==0) st_select(v->lnL, (*pREs)[L].lnL, v->subsample)

			v->Q_E = diag(v->ThetaSign = 2*(TheseInds:==3) :- 1)

			v->one2N = 1:: (v->N = colsum(v->subsample))
			v->J_N_d_0 = J(v->N, d, 0)
			v->J_N_d2_0 = J(v->N, d2, 0)
			if (pREs->NumCuts) v->J_N_NumCuts_0 = J(v->N, pREs->NumCuts, 0)
			
			v->d_uncens = d_uncens = cols(uncens = v->uncens = OneInds(TheseInds:==1 :| TheseInds:==8))
			d_oprobit = cols(oprobit = v->oprobit = OneInds(TheseInds:==5))
			intreg = OneInds(TheseInds:==7)
			v->d_two_cens = d_two_cens = cols(oprobit) + cols(intreg)
			v->d_truncreg = d_truncreg = cols(truncreg = v->truncreg = OneInds(TheseInds:==8))

			one_cens = OneInds(TheseInds:==2 :| TheseInds:==3 :| TheseInds:==6 :| TheseInds:>=_roprobit_ind_base)
			d_one_cens_nonrobase = cols(one_cens_nonrobase = OneInds(_nonbase_cases :* (TheseInds:==2 :| TheseInds:==3 :| TheseInds:==6 :| TheseInds:>=_roprobit_ind_base)))
			v->d_cens           = d_cens           = cols(v->cens = cens = (one_cens          , oprobit, intreg))
			v->d_cens_nonrobase = d_cens_nonrobase = cols(cens_nonrobase   = (one_cens_nonrobase, oprobit, intreg))
			v->two_cens = d_two_cens ? d_one_cens_nonrobase+1 .. d_cens_nonrobase : J(1,0,0)
			
			if (d_cens > 2) {
				v->ghk_start = ghk_nobs + 1
				ghk_nobs = ghk_nobs + v->N
			}

			if (d_oprobit) {
				l = 1
				if (oprobit[1]>1) l = l + colsum(_vNumCuts[1::oprobit[1]-1])
				v->CutInds = l .. l+_vNumCuts[oprobit[1]]-1
				for (k=2; k<=d_oprobit; k++) {
					l = l + colsum(_vNumCuts[oprobit[k-1]::oprobit[k]-1])
					v->CutInds = v->CutInds, l .. l+_vNumCuts[oprobit[k]]-1
				}
				v->vNumCuts = _vNumCuts[oprobit]

 				v->NumCuts = cols(v->CutInds)
			} else
				v->NumCuts = 0

			if (v->num_mprobit_groups = _num_mprobit_groups) {
				v->mprobit = mprobit_group(v->num_mprobit_groups)

				for (k=v->num_mprobit_groups; k; k--) {
					start = _mprobit_group_inds[k, 1]; stop = _mprobit_group_inds[k, 2]

					v->mprobit[k].d = d_mprobit = cols( mprobit = OneInds(TheseInds :& one2d:>=start :& one2d:<=stop) )

					if (d_mprobit) {
						out = TheseInds[start] - _mprobit_ind_base
						in =  OneInds(TheseInds :& one2d:>=start :& one2d:<=stop :& one2d:!=out)
						res = TheseInds :& one2d:>start :& one2d:<=stop
						(v->Q_E)[mprobit, mprobit] = J(d_mprobit, 1, 0), insert(-I(d_mprobit-1), out-start+1, J(1, d_mprobit-1, 1))
						if (L==1) {
							st_subview(v->mprobit[k].E_out, v->E, ., out)
							st_subview(v->mprobit[k].E_in , v->E, ., in)
							st_subview(v->mprobit[k].E_res, v->E, ., OneInds(res))
						} else {
							v->mprobit[k].in =  in
							v->mprobit[k].out = out
							v->mprobit[k].res = OneInds(res[cens])
						}
					}
				}
			}

			v->N_perm = 1
			if (v->num_roprobit_groups = _num_roprobit_groups) {
				pointer(real rowvector) colvector roprobit
				real rowvector this_roprobit
				pointer (real matrix) colvector perms
				pointer(real matrix) ThesePerms
				real scalar ThisPerm
				
				perms = roprobit = J(v->num_roprobit_groups, 1, NULL)
				v->d_cens_nonrobase = cols(cens)
				v->d2_cens = d_cens * (d_cens + 1)*.5

				for (k=v->num_roprobit_groups; k; k--)
					if (cols(this_roprobit=*(roprobit[k] = &OneInds(TheseInds :& one2d:>=_roprobit_group_inds[k,1] :& one2d:<=_roprobit_group_inds[k,2]))))
						v->N_perm = v->N_perm * (rows(*(perms[k] = &PermuteTies(_reverse? TheseInds[this_roprobit] : -TheseInds[this_roprobit]))))
				
				v->roprobit_Q_E = v->roprobit_Q_Sig = J(i=v->N_perm, 1, NULL)
				for (; i; i--) { // combinations of perms across multiple roprobit groups
					j = i - 1
					t = I(d)
					for (k = v->num_roprobit_groups; k; k--) 
						if (d_roprobit = cols(this_roprobit = *roprobit[k])) {
							ThisPerm = mod(j, rows(*(ThesePerms=perms[k]))) + 1
							t[this_roprobit, this_roprobit] = 
								J(d_roprobit, 1, 0), (I(d_roprobit)[,(*ThesePerms)[|ThisPerm, 2 \ ThisPerm, .           |]] - 
								                      I(d_roprobit)[,(*ThesePerms)[|ThisPerm, 1 \ ThisPerm, d_roprobit-1|]] )
							j = (j - ThisPerm + 1) / rows(*ThesePerms)
						}
					(v->roprobit_Q_Sig)[i] = &QE2QSig(*((v->roprobit_Q_E)[i] = &t[cens, cens_nonrobase]))
				}
			}

			if (L==1) {
				st_subview(v->E_uncens, v->E, ., uncens)
				st_subview(v->E_cens, v->E, ., cens)
			}
			if (d_two_cens | d_truncreg) {
				if (L==1) st_select(v->F, pREs->F, v->subsample)
				if (d_two_cens & L==1)
					st_subview(v->F_cens, v->F, ., cens)
				if (d_truncreg) {
					v->one2d_truncreg = 1..d_truncreg
					v->Sig_inds_trunc = vSigInds(truncreg, d)

					if (L==1) {
						st_select(v->G, pREs->G, v->subsample)
						st_subview(v->truncreg_lower, v->F, ., truncreg)
						st_subview(v->truncreg_upper, v->G, ., truncreg)
					}
					
					if (d_truncreg > 2) {
						v->ghk_start_truncreg = ghk_nobs + 1
						ghk_nobs = ghk_nobs + v->N
					}
				}
			}

			if (strlen(ScoreVars[1])) { // pre-compute stuff for scores
				if (L==1) st_select(v->Scores, pREs->Scores.X, v->subsample)

				v->Sig_inds_uncens = vSigInds(uncens, d)
				v->d_oprobit = d_oprobit
				v->cens_uncens = cens, uncens
				v->J_N_d2_uncens_0 = J(v->N, d_uncens*(d_uncens+1)*.5, 0)
				v->J_N_d2_cens_uncens_0 = J(v->N, (d_cens+d_uncens)*(d_cens+d_uncens+1)*.5, 0)
				v->J_d_uncens_d_cens_0 = J(d_uncens, d_cens, 0)
				v->J_N_d_cens_0 = J(v->N, d_cens, 0)
				v->J_d_cens_d_0 = J(d_cens, d, 0)
				v->J_d2_cens_d2_0 = J(d_cens*(d_cens+1)*0.5, d2, 0)				
				
				if (d_cens)
					v->cens_LT_inds = vech(colshape(1..d_cens*d_cens, d_cens)')

				if (d_oprobit) {
					Yinames = ""
					for (k=1; k<=d_oprobit; k++) {
						stata("unab yis: _cmp_y" + strofreal(oprobit[k]) + "_*")
						Yinames = Yinames + " " + st_local("yis")
					}
					st_view(Yi, ., tokens(Yinames))
					st_select(v->Yi, Yi, v->subsample)
				}

				v->Q_Sig = QE2QSig(v->Q_E)
				v->Sig_inds_cens_uncens = vSigInds(v->cens_uncens, d)
				v->dSig_dLTSig = Dmatrix(d_cens + d_uncens)
			}
		}
		_subviews = v

		if (ghk_nobs) {
			// by default, make # draws at least sqrt(N) (Cappellari and Jenkins 2003)
			if (_ghkDraws == 0) _ghkDraws = ceil(2 * sqrt(ghk_nobs+1))

			if (_first_call) {
				printf("{res}Likelihoods for %f observations involve cumulative normal distributions above dimension 2.\n", ghk_nobs)
				printf(`"Using {stata "help ghk2" :ghk2()} to simulate them. Settings:\n"')
				printf( "    Sequence type = %s\n    Number of draws per observation = %f\n    Include antithetic draws = %s\n"', _ghkType, _ghkDraws, _ghkAnti? "yes" : "no")
				printf("    Prime bases = %s\n", invtokens(strofreal(Primes[PrimeIndex..PrimeIndex-2+d])))
				if (_ghkType=="random" | _ghkType=="ghalton")
					printf(`"    Initial {stata "help mf_uniform" :seed string} = %s\n"', uniformseed())
				printf(`"Each observation gets different draws, so changing the order of observations in the data set would change the results.\n\n"')
			}
			pREs->ghk2DrawSet = ghk2setup(ghk_nobs, _ghkDraws, d, _ghkType, PrimeIndex)
		}
		_first_call = 0
	} else {
		N = rows(pREs->E)
		NumREDraws = _NumREDraws
	}
	
	subviews = _subviews
	
	if (strlen(lf)) st_view((*pREs)[L].lnL, ., lf)
	for (l=1; l<=L; l++) {
		sig = st_matrix(signames[l])
		if ((*pREs)[l].d == 1)
			(*pREs)[l].Sig = (T = sig) * sig
		else {
			atanhrho = st_matrix(atanhrhonames[l])
			Sig = I((*pREs)[l].d)
			for (k=j=1; j<=(*pREs)[l].d; j++)
				for (i=j+1; i<=(*pREs)[l].d; i++) {
					Sig[i,j] = atanhrho[k]>100? 1 : (atanhrho[k]<-100? -1 : tanh(atanhrho[k]))
					k++
				}
			_makesymmetric(Sig)
			T = cholesky(Sig)' :* sig
			if (T[1,1] == .) return (.)
			(*pREs)[l].Sig = sig :* Sig :* sig'
		}

		if (todo) {
			// prepare matrix D to transform scores w.r.t. elements of Sigma to ones w.r.t. lnsig's and atanhrho's
			D = I((*pREs)[l].d2)
			for (k=1; k<=(*pREs)[l].d; k++) {  // derivatives of Sigma w.r.t. lnsig's
				(t = (*pREs)[l].J_d_d_0)[,k] = (*pREs)[l].Sig[,k]
				t[k,] = t[k,] + (*pREs)[l].Sig[k,]
				D[,k] = vech(t)
			}
			if ((*pREs)[l].d > 1) {  // derivatives of Sigma w.r.t. atanhrho's
				for (j=1; j<=(*pREs)[l].d; j++)
					for (i=j+1; i<=(*pREs)[l].d; i++) {
						(t = (*pREs)[l].J_d_d_0)[i,j] = sig[i] * sig[j]
						D[,k++] = vech(t)
					}
				D[|.,(*pREs)[l].d+1 \ .,.|] = D[|.,(*pREs)[l].d+1 \ .,.|] :/ cosh(atanhrho):^2
			}
			(*pREs)[l].D = D * *(pREs->dSigdParams)[l]
		}

		if (l < L) {
			(*pREs)[l].lnLByDraw = (*pREs)[l].J_N_NumREDraws_0

			for (r=NumREDraws[l+1]; r; r--) {
				UT = *((*pREs)[l].U)[r] * T
				for (v = subviews; v!=NULL; v = v->next)
					((*pREs)[l].UT[r].X)[v->SubsampleInds,*Eqs[l]] = UT[v->SubsampleInds,(*pREs)[l].one2d] :* v->ThetaSign[*Eqs[l]]
			}

			if (todo) {
				(*pREs)[l].D = ghk2_dTdV(T') * (*pREs)[l].D
				(*pREs)[l].dlnL_dT = (*pREs)[l].J_N_d2_0
			}

			(*pREs)[l+1].E = (*pREs)[l].E + (*pREs)[l].UT.X
			if (cols(pREs->F)) {
				(*pREs)[l+1].F = (*pREs)[l].F + (*pREs)[l].UT.X
				if (cols(pREs->G))
					(*pREs)[l+1].G = (*pREs)[l].G + (*pREs)[l].UT.X
			}
		}
	}

	// adjust for sign flips in cmp_lf1 and mprobit relative differencing
	for (v = subviews; v!=NULL; v = v->next)
		v->Sig = quadcross(v->Q_E, (*pREs)[L].Sig) * v->Q_E

	do { // for each combination of draws
		if (todo & L > 1)
			pScores = & ((*pREs)[L].Scores[(*pREs)[L-1].ThisDraw].X)

		for (v = subviews; v!=NULL; v = v->next) {
			if (L > 1) { //if using classes, this would be hidden in class def
				if (v->d_uncens)                 v->pE_uncens = &( (*pREs)[L].E[v->SubsampleInds, v->uncens] )
				if (v->d_cens  )                 v->pE_cens   = &( (*pREs)[L].E[v->SubsampleInds, v->cens  ] )
				if (v->d_two_cens | v->d_truncreg) v->pF_cens = &( (*pREs)[L].F[v->SubsampleInds, v->cens  ] )
				if (v->d_truncreg) {
				                           v->ptruncreg_upper = &( (*pREs)[L].G[v->SubsampleInds, v->truncreg] )
				                           v->ptruncreg_lower = &( (*pREs)[L].F[v->SubsampleInds, v->truncreg] )
				}
			} else {
				if (v->d_uncens)                 v->pE_uncens = &( v->E_uncens )
				if (v->d_cens  )                   v->pE_cens = &( v->E_cens )
				if (v->d_two_cens | v->d_truncreg) v->pF_cens = &( v->F_cens )
				if (v->d_truncreg) {
				                           v->ptruncreg_upper = &( v->truncreg_upper )
				                           v->ptruncreg_lower = &( v->truncreg_lower )
				}
			}

			t = v->d_cens?
					(v->d_uncens?
						cmp_lnL_continuous  (v, pREs,    d, d2, todo, dphi_dE, dphi_dSig) + 
							cmp_lnL_censored(v, pREs, L, d, d2, todo, dPhi_dE, dPhi_dSig, dPhi_dcuts) :
						cmp_lnL_censored    (v, pREs, L, d, d2, todo, dPhi_dE, dPhi_dSig, dPhi_dcuts)) :
					cmp_lnL_continuous      (v, pREs,    d, d2, todo, dphi_dE, dphi_dSig)

			if (strlen(lf)) {
				st_select(this_lnL, (*pREs)[L].lnL, v->subsample)
				this_lnL[,] = t
			} else if (L > 1)
				((*pREs)[L].lnL)[v->SubsampleInds] = t
			else
				(v->lnL)[,] = t

			if (todo) {
				if (v->d_cens)
					if (v->d_uncens) {
						pdlnL_dtheta = &(dphi_dE + dPhi_dE) 
						pdlnL_dSig =  &(dphi_dSig + dPhi_dSig)
					} else {
						pdlnL_dtheta = &dPhi_dE
						pdlnL_dSig =  &dPhi_dSig
					}
				else {
					pdlnL_dtheta = &dphi_dE
					pdlnL_dSig = &dphi_dSig
				}

				if (L == 1)
					(v->Scores)[.,.] = pREs->NumCuts?
							(v->d_cens?
								*pdlnL_dtheta * v->Q_E',       dPhi_dcuts, (*pdlnL_dSig * (v->Q_Sig * (*pREs)[L].D)) :
								*pdlnL_dtheta * v->Q_E', v->J_N_NumCuts_0, (*pdlnL_dSig * (v->Q_Sig * (*pREs)[L].D))) :
							*pdlnL_dtheta * v->Q_E'    ,                   (*pdlnL_dSig * (v->Q_Sig * (*pREs)[L].D))
				else {
					                   (*pScores)[v->SubsampleInds,   1..d        ] = *pdlnL_dtheta * v->Q_E'
					if (pREs->NumCuts) (*pScores)[v->SubsampleInds, d+1..d+pREs->NumCuts] = v->d_cens? dPhi_dcuts : v->J_N_NumCuts_0
					if (cols(*(pREs->dSigdParams)[L]))
					             (*pScores)[v->SubsampleInds, NumScores-cols(*(pREs->dSigdParams)[L])+1..NumScores] = *pdlnL_dSig * (v->Q_Sig * (*pREs)[L].D)
				}
			}
		}

		if (todo) { // scores of covariance of random effects
			if (L > 1) _editmissing(*pScores, 0)
			i = d + pREs->NumCuts + 1
			for (l=1; l<L; l++) {
				for (k=j=1; j<=(*pREs)[l].d; j++) // dlnLdSig = dlnL/dE^ * dE^/dE * dE/dT * dT/dSig = dlnL/dE * Q_E * {U} * dT/dSig
					PasteAndAdvance((*pREs)[l].dlnL_dT, k,
						 *(((*pREs)[l].Uj)[(*pREs)[l].ThisDraw, j]) :* (*pScores)[(*pREs)[L].one2N, (*Eqs[l])[|j \ .|]] )
				PasteAndAdvance(*pScores, i, (*pREs)[l].dlnL_dT * (*pREs)[l].D)
			}
		}

		for (l=L-1; l; l--) { // make next iteration of RE draw sets
			 // clever, efficient way to sum lnL by group
			_quadrunningsum((*pREs)[l+1].lnL, rows((*pREs)[l+1].Weights)? (*pREs)[l+1].lnL :* (*pREs)[l+1].Weights : (*pREs)[l+1].lnL, 1)
			t = (*pREs)[l+1].lnL[(*pREs)[l].IDRangesGroup]
			((*pREs)[l].lnLByDraw)[(*pREs)[l].one2N, (*pREs)[l].ThisDraw] = t - (0 \ t[|.\rows(t)-1|])

			(*pREs)[l].ThisDraw = mod((*pREs)[l].ThisDraw, NumREDraws[l+1]) + 1

			if ((*pREs)[l].ThisDraw > 1) { // no more carrying? propagate draw changes down the tree
				for (l2=l; l2<L; l2++) {
					(*pREs)[l2+1].E         = (*pREs)[l2].E + (*pREs)[l2].UT[(*pREs)[l2].ThisDraw].X
					if (cols(pREs->F)) {
						(*pREs)[l2+1].F     = (*pREs)[l2].F + (*pREs)[l2].UT[(*pREs)[l2].ThisDraw].X
						if (cols(pREs->G))
							(*pREs)[l2+1].G = (*pREs)[l2].G + (*pREs)[l2].UT[(*pREs)[l2].ThisDraw].X
					}
				}
				break
			}

			// shift just enough to prevent underflow in exp(), but even less if that would cause overflow()
			shift = rowmin( (rowmax(((*pREs)[l].J_N_1_0, pREs->lnsmalldouble :- rowmin((*pREs)[l].lnLByDraw))),
			                 (pREs->lnmaxdouble - ln(NumREDraws[l+1])) :- rowmax((*pREs)[l].lnLByDraw)) )

			_editmissing( L_g = exp((*pREs)[l].lnLByDraw :+ shift), 0 ) // un-log likelihood for each group & draw; lnL=. => L=0
			(*pREs)[l].lnL = quadrowsum(L_g) // sum rather than average of likelihoods across draws

			if (todo) { // obs-level score for next level up is avg of scores over this level's draws, weighted by group's L for each draw
				_editmissing(L_g = L_g :/ (*pREs)[l].lnL, 0) // if group's L=0 for all draws, scores should be too, so weights won't matter
				L_g = L_g[(*pREs)[l].id, (*pREs)[l+1].one2R]
				t = L_g[(*pREs)[L].one2N, 1] :* ((*pREs)[l+1].Scores.X)
				for (r = NumREDraws[l+1]; r>1; r--)
					t = t + L_g[(*pREs)[L].one2N, r] :* ((*pREs)[l+1].Scores[r].X)
				if (l==1)
					pREs->Scores.X[(*pREs)[L].one2N, one2NumScores] = rows(pREs->WeightProduct)? t:*pREs->WeightProduct : t // final scores
				else
					(*pREs)[l].Scores[(*pREs)[l-1].ThisDraw].X = t 
			}
			(*pREs)[l].lnL = ln((*pREs)[l].lnL) - shift :- ln(NumREDraws[l+1])
		}
	} while (l) // exit when adding one more draw causes carrying all the way accross the draw counters, back to 1, 1, 1...

	if (L > 1)
		st_numscalar(st_local("lnfi"), quadcolsum(rows(pREs->Weights)? pREs->Weights:*pREs->lnL : pREs->lnL , 1))
	return (0)
}

void cmpSaveSigsAndObs() {
	external struct RE colvector _REs; external real scalar _L; real scalar l
	if (_L == 1)
		st_matrix("e(Sigma)", _REs.Sig)
	else {
		for (l=_L; l; l--)
			st_matrix("e(Sigma" + strofreal(l)+")", _REs[l].Sig)
		if (rows(_REs.WeightProduct))
			st_numscalar("e(N)", quadcolsum(_REs.WeightProduct))
	}
}

mata mlib create lcmp, dir(PLUS) replace
mata mlib add lcmp *(), dir(PLUS)
mata mlib index
end
