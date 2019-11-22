#include <oxstd.h>												  
#include <oxfloat.h>
#include <oxprob.h>
#import <modelbasempi>
#include <oxdraw.h>
#import <packages/maxsa/maxsa>
#include "simulation.ox"
#import <OxCECtb>

/* ------------------------------------------------------
			    FEM Project Library (Class)

The program contains all functions used in the FEM under
a class.

Uses ModelBaseMPI, which is ModelBase class where I loaded
MPI and used it for optimization. Here each processor
computes a numerical gradient (with respect to one parameter)
and sends back result to master

To install on another machine oxmpi will need to be reinstalled

 by Pierre-Carl Michaud and Yuhui Zheng
 Last version: September 2008				
 ------------------------------------------------------*/

// These are model types, only M_INIT should be of interest			
enum{M_INIT,M_TRANS,M_HYPER}
// These are the group of variables, see est_init.ox to understand
enum{Y_VAR,W_VAR,Z_VAR,L_VAR,F_VAR,G_VAR}
// Types of variables
enum{BIN,CONT,ORDER,CENSOR,CENSORBIN,CENSORORDER}
// Type of standard errors
enum{HESSIAN,OGP}
// various stats that can be compiled from data
enum{MEAN,SUM,MEDIAN,VAR,PROD}
// Type of duration model (for transition model
enum{PH,NORMAL,LOGIT}

/*------------------ FEM : ModelBaseMPI ------------------*/

// Class definition
class FEM : ModelBaseMPI
{
	// vectors and identifiers
	decl m_vI,m_vT,m_vN,m_vPer;	     //  ids vectors
	decl m_sI,m_sT,m_sPer;
					     // Names if Ids
	decl m_cN,m_cNT,m_cPmax,m_cPmin;
				   // # obs and max # periods
	decl m_cE,m_cD,m_cJ,m_cPer,m_cR;
				        // # dimension if MPH
	decl m_iModel,m_iResultm_sName,m_asSelect;
				
				  // Tag for Model Selection
	decl m_mY,m_mX,m_mZ,m_mL,m_mF,m_mW,m_mG,m_vS;
					// data of ys and xs
	decl m_asX,m_asY,m_asL,m_asZ,m_asF,m_asW,
			m_asG,m_asC,m_vType,m_vThres;
					      // Names of Xs
	decl m_cX,m_cY,m_cL,m_cF,m_cZ,m_cW,m_cPar,m_cG,m_vM;
	decl m_mCholeski;
	decl m_cFactor;
					      // Dim of data
	
	decl m_iStdErr,m_iH;
	decl m_mU;
	decl m_asParTypes;
	decl m_asRestrictions,m_cRestrictions,m_iName;
					 //matrices of draws
	
	FEM();                              	// constructor

	// ------------- Estimation Functions ----------------
	ClearEstimation();
	ClearModel();
	GetcT();
	GetModel();  
	GetPackageName();
	GetPackageVersion();
	GetParNames();
    	SetId(const sI, const sT, const sP);                
    	SetModel(const iModel);
	SetDraws(const cR);
	SetVarType(const vType);
	SetPath(const spath);
	SetHazard(const iHazard);
	GetHazard(const vX);
	fMapFreetoPar(const vFreePar);
	SetVerbose(const iVerbose);
	OutputMax(const sMethod, const iResult,
		const vPstart, const bNumerical);
	OutputPar();
	OutputLogLik();
	OutputHeader(const sTitle);
	Output();
	SavePar(const vFreePar);
	CalcDraws();
	fnGradient(const fnF,const vX0, vF0);
	SetSelectionVars(const asNames);
	DropVars(const asY) ;
	Collapse(const vX, const vI, const iStat, const iLong);
	SetName(const iName);
	SetFactor(const num);
	// ModelBase modified functions	 (for Estimation)
    	InitPar();                     // initialize parameters
	InitData();			     // initialize data
	Estimate();				  // Estimation
    	DoEstimation(vStart);              // do the maximation
    	Covar();          // compute variance-covariance matrix
	SetStd(const is);
	// Likelihoods

    fm_init(const vP, const adFunc, const avScore,
					const amHess);
	fm_trans(const vP, const adFunc, const avScore,
					const amHess);
	// Individual Likelihoods
	fm_initi(const vP, const adFunc, const avScore, const amHess);
	fm_transi(const vP, const adFunc, const avScore,
					const amHess);	

};
/*----------------- END FEM : ModelBaseMPI ------------------*/


FEM::FEM() // Constructor Function
{
    ModelBaseMPI();                   // initialize base class
	// Set defaults here
	m_cN = m_cNT = m_cPmax = .NaN;
	m_asRestrictions = new array[50];
	m_cRestrictions = 0;
	m_mCholeski = 0;
	SetPath("~");
}

/*************************************************************/
/*--------------- ESTIMATION FUNCTIONS ----------------------*/
/*************************************************************/

FEM::ClearModel()
{
    ModelBaseMPI::ClearModel();
}

FEM::ClearEstimation()
{
    ModelBaseMPI::ClearEstimation();   
}

FEM::GetPackageName()
{ 
return "Future Elderly Model: Estimation";
}
FEM::GetPackageVersion()
{ 
return "1.0";
}

FEM::SetPath(const spath) {

	chdir(spath);
}

FEM::SetName(const iName) {
	m_iName = iName;
}

FEM::SetFactor(const num) {

	m_cFactor = num;
}


FEM::SetId(const sI, const sT, const sP)
{
	m_sI = sI;
		m_vI = GetVar(m_sI);
		m_cNT = sizer(m_vI);
		m_vN = distincval(m_vI,0);
		m_cN = sizer(m_vN);

	m_sT = sT;
		m_vT = GetVar(m_sT);
		
	m_sPer = sP;
		m_vPer = GetVar(m_sPer);
	
		m_cPmax = maxc(m_vPer);
		m_cPmin = minc(m_vPer);
	m_cPmax = 1;
	m_cPer = range(1,m_cPmax,1)';

		
}

FEM::SetDraws(const cR) {
	m_cR = cR;
}

FEM::SetVarType(const vType)
{
	m_vType = vType;
	m_vM = new matrix[6][1];
	m_vM[0] = sumc(m_vType.==BIN);
	m_vM[1] = sumc(m_vType.==CONT);
	m_vM[2] = sumc(m_vType.==ORDER);
	m_vM[3] = sumc(m_vType.==CENSOR);
	m_vM[4] = sumc(m_vType.==CENSORBIN);
	m_vM[5] = sumc(m_vType.==CENSORORDER);			
}
FEM::SetStd(const is) {

	m_iStdErr = is;
}

FEM:: SetHazard(const iHazard) {
	  m_iH = iHazard;
}

FEM:: GetHazard(const vX) {
	  if (m_iH==NORMAL) return probn(vX);
	  if (m_iH==PH) return 1-exp(-exp(vX));
	  if (m_iH==LOGIT) return (1+exp(-vX)).^-1;	  
}


FEM::SetModel(const iModel)
{
    ClearModel();
	m_iModel = iModel;
	if (GetModelStatus()>MS_DATA)  SetModelStatus(MS_DATA);
}

FEM::GetModel()
{	
	if (m_iModel==M_INIT) {
		return "Initial Condition Model";
		}
	if (m_iModel==M_TRANS) {
		return "Transition Model";
	}		
}

FEM:: fnGradient(const fnF,const vX0, vF0) { 
    decl dEps,vF1,vF2,dN,vE,vEi,mG,dh,
         bUseTwoSided=FALSE;
    dEps = 1e-7;
    dN   = rows(vX0);
    vE   = zeros(dN,1);
    if (vF0==0)
        fnF(vX0,&vF0,0,0);                     /* Compute function only if not supplied in argument */

    mG   = zeros(sizerc(vF0),dN);               /* Create a matrix of zeros to store */
                                                /*   the first derivatives df(x0)/dx_i */

    for (decl i=0;i<dN;++i){                    /* Loop i from 1 to n=rows(vX) */
        vEi   = vE; vEi[i]= 1;                  /* Construct e_i */
        dh    = max((fabs(vX0[i])*dEps),dEps);  /* Calculate perturbation factor h */
        if (!fnF(vX0+vEi*dh,&vF2,0,0))
            println("Gradient evaluation failed."),exit(1);
        if (bUseTwoSided){                      /* Calculate two-sided finite difference */
            if (!fnF(vX0-vEi*dh,&vF1,0,0))
                println("Gradient evaluation failed."),exit(1);
            mG[][i] = (vF2-vF1)/(2*dh);
        }
        else{                                   /* Calculate one-sided finite difference */
            vF1     = vF0;
            mG[][i] = (vF2-vF1)/ dh;
        }

    }                                 /* Next i */
    return mG;                         /* Return matrix of individual gradients */
}

FEM::SetSelectionVars(const asNames)
{
	m_asSelect = asNames;
}

FEM::DropVars(const asY) {
	m_asRestrictions[m_cRestrictions] = asY;
	m_cRestrictions +=1;
}

FEM::Collapse(const vX, const vI, const iStat, const iLong) {

	decl vN,N,vXm = 0,data;

	vN = distincval(vI,0);
	N = sizer(vN);

	
	if (iStat==MEAN) {

		if (iLong==TRUE) {
		
			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= ones(sizer(data),1).*meanc(deleter(data));
				} else {
				    vXm |= constant(0,sizer(data),1); 
				}
	
			}
		}
		else {

			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= meanc(deleter(data));
				} else {
				    vXm |= constant(0,1,1); 
				}
	
			}
		}

	}
	if (iStat==SUM) {

		if (iLong==TRUE) {
		
			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= ones(sizer(data),1).*sumc(deleter(data));
				} else {
				    vXm |= constant(0,sizer(data),1); 
				}
	
			}
		}
		else {

			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= sumc(deleter(data));
				} else {
				    vXm |= constant(0,1,1); 
				}
	
			}
		}

	}
	if (iStat==PROD) {

		if (iLong==TRUE) {
		
			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= ones(sizer(data),1).*prodc(deleter(data));
				} else {
				    vXm |= constant(1,sizer(data),1); 
				}
	
			}
		}
		else {

			for (decl i = 0 ; i < N; ++i) {
				
				data = 	selectifr(vX,vI.==vN[i]);
				if (deleter(data)!=<>)	{			
					vXm |= prodc(deleter(data));
				} else {
				    vXm |= constant(1,1,1); 
				}
	
			}
		}

	}	
	return dropr(vXm,0);
}

FEM::InitData()  
{
	println("Initialize Data ...");
	SetSelSample(-1, 1, -1, 1);   // full sample	
	GetGroupNames(Y_VAR,&m_asY);	
	m_mY = GetGroup(Y_VAR);	
	m_cY = sizec(m_mY);
	//println("sizer(m_mY) = ",sizer(m_mY));
	
	if (sumc(m_vM[3:5])!=0) {
		m_vS = strfind(m_asY,m_asSelect)';
		m_vS = constant(-1,m_cY-sumc(m_vM[3:5]),1)|m_vS;	
	}	

		
		m_vThres = new matrix[m_cY][1];
		
		for (decl m = 0; m<m_cY;++m) {
		decl num;
		
			if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {						
				m_vThres[m] = sizer(distincval(selectifr(m_mY[][m],m_mY[][m].!=-2 .&& m_mY[][m].!=9),0))+(m_vType[m]==ORDER);			
			}
			else {
				m_vThres[m] = 0;						
			}
		}	
	
	GetGroupNames(L_VAR,&m_asL);	
	m_mL = GetGroup(L_VAR);	
	m_cL = sizec(m_mL);

	GetGroupNames(F_VAR,&m_asF);	
	m_mF = GetGroup(F_VAR);	
	m_cF = sizec(m_mF);

	GetGroupNames(Z_VAR,&m_asZ);	
	m_mZ = GetGroup(Z_VAR);	
	m_cZ = sizec(m_mZ);

	GetGroupNames(W_VAR,&m_asW);
	m_mW = GetGroup(W_VAR);
	m_cW = sizec(m_mW);
		
	m_asX = m_asL|m_asF|m_asW|m_asZ;
	m_mX = m_mL~m_mF~m_mW~m_mZ;
	m_cX = sizec(m_mX);
   

    return TRUE;
}

FEM::GetParNames()
{                
	decl asParNames,asParTypes;	

	// ---- Initial Condition Model --------------
	if (m_iModel==M_INIT) {

	asParNames = m_asZ;
	asParTypes = {};
	for (decl z = 0; z<m_cZ;++z) {
		asParTypes |= sprint("xb(",0,")");
	}
		
		for (decl m=1; m<m_cY;++m) {
			
		asParNames |= m_asZ;	
			
			for (decl z = 0; z < m_cZ; ++z) {				
				asParTypes |= sprint("xb(",m,")");						
			}		
		}	
		
		
		for (decl m=0; m<m_cY;++m) {
			if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
			decl num;
				num = m_vThres[m];	
				for (decl n=0;n<num;++n) {
					asParNames |= sprint("thres(",n,")");
					asParTypes |= sprint("eq(",m,")");
				}
			}
		}	
		
		for (decl m=0; m<m_cY;++m) {
			for (decl n=m; n<m_cY;++n) {
			
			asParNames |= sprint("cov(",m,",",n,")");
			asParTypes |= "cov";
			
			}		
		}	
			
	}

	// ---- Transition Model ---------------------

	if (m_iModel==M_TRANS) {

	asParNames = m_asX;
	asParTypes = {};
	for (decl x = 0; x<m_cX;++x) {
		asParTypes |= sprint("xb(",0,")");
	}
	
	
		for (decl m=1; m<m_cY;++m) {
			
			asParNames |= m_asX;	
			
			for (decl x = 0; x < m_cX; ++x) {				
				asParTypes |= sprint("xb(",m,")");						
			}		
		}	
		
		
		for (decl m=0; m<m_cY;++m) {
			if (m_vType[m]==ORDER) {
			decl num;
				num = m_vThres[m];	
				for (decl n=0;n<num;++n) {
					asParNames |= sprint("thres(",n,")");
					asParTypes |= sprint("eq(",m,")");
				}
			}
		}	
		
		for (decl m=0; m<m_cY;++m) {
			for (decl n=0; n<m_cFactor;++n) {
			
			asParNames |= sprint("Load(",m,",",n,")");
			asParTypes |= "Load";
			
			}		
		}	
		for (decl m=0; m<m_cY;++m) {
			for (decl n=m; n<m_cY;++n) {
			
			asParNames |= sprint("covE(",m,",",n,")");
			asParTypes |= "covE";
			
			}		
		}				
	}

	
	m_asParTypes = asParTypes;		
    return asParNames;
}


FEM::InitPar() 
{


	ModelBaseMPI::InitPar();   // first call ModelBaseMPI version

	println("Initialize Parameters ...");
	// ---- Initial Condition Model ------------------
	if (m_iModel==M_INIT) {

		decl cParX = m_cZ*m_cY;		
		
		decl cParT = sumc(m_vThres);
		
		decl cParC = (m_cY^2-m_cY)/2 + m_cY;

				
		m_cPar = cParX + cParT + cParC;
		SetParCount(m_cPar);
		
		decl mE = new matrix[m_cN][m_cY];
		// mean
		decl vVarE = new matrix[m_cY][1];
		decl InitParX = 0,par_m; 
		for (decl m = 0; m<m_cY;++m) {			
			decl ym,zm;
			if (m_vType[m]==CENSOR || m_vType[m]==CENSORBIN || m_vType[m]==CENSORORDER) {
				ym = selectifr(m_mY[][m],m_mY[][m_vS[m]].==1);
				zm = selectifr(m_mZ,m_mY[][m_vS[m]].==1);
			}
			else {
				ym = m_mY[][m];
				zm = m_mZ;
			}
			olsc(ym,zm,&par_m);
				vVarE[m] = varc(ym-zm*par_m);
				
			if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) { 
				par_m *= 1.6;
			}
			if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
				par_m *=0;
			}
			InitParX |= par_m;	
		}	
		InitParX = dropr(InitParX,0);	
				
		// Restrictions on Thresholds
		decl pos = cParX,InitParT=0;
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
				FixPar(pos,-.Inf);
				FixPar(pos+1,0);
				InitParT |= zeros(max(m_vThres[m]-3,0),1);
				FixPar(pos+m_vThres[m]-1,+.Inf);		
				pos += m_vThres[m];
			}
		} 
		InitParT = dropr(InitParT,0);
		
		// Restrictions on Covariance Matrix
		pos = cParX + cParT;
		
		decl InitParC = 0,ym,yn;
		for (decl m = 0; m<m_cY;++m) {
			for (decl n = m; n<m_cY;++n) {
				if (m==n)  {
					if (m_vType[m]==BIN || m_vType[m]==ORDER
								|| m_vType[m]==CENSORBIN || m_vType[m]==CENSORORDER) {
						FixPar(pos,1);				
					}
					else {
						InitParC |= log(vVarE[m]);
//						FixPar(pos,1);
					}
				}
				else {
				
					//println("m_vType[n]",m~n~m_vType[n]~m_vS[n]);
					
					if ((m_vType[n]==CENSOR
								|| m_vType[n]==CENSORBIN || m_vType[n]==CENSORORDER) && m_vS[n]==m) {
						//println("m = ",m," n = ",n);
						FixPar(pos,0);	
					}
					else if (m_vType[m]==BIN) {
						//if (meanc(m_mY[][m])<0.05 || meanc(m_mY[][m])>0.95) {
						//	FixPar(pos,0);
						//}
						if (m_vType[n]==BIN) {
							ym = meanc(m_mY[][m])<0.05 || meanc(m_mY[][m])>0.95;
							yn = meanc(m_mY[][n])<0.05 || meanc(m_mY[][n])>0.95;
							if (ym==1 && yn==1) {
								FixPar(pos,0);						
							}
							else {
								InitParC |= 0;//Cor[m][n];										
							//FixPar(pos,0);
							}
							
						}
						else {
							InitParC |= 0;//Cor[m][n];											
							//FixPar(pos,0);
						
						}
					}	
					else {
						InitParC |= 0;//Cor[m][n];
						//FixPar(pos,0);

					}						
					
					
				}
				
				pos +=1;	
			}
		
		}		
		InitParC = dropr(InitParC,0);
		
		InitParX = loadmat("param/init_initialx.xls");

		
	SetFreePar(InitParX|InitParT|InitParC);
	//SetFreePar(loadmat("param/"+m_iName+"_FreePar_Init.xls"));
	//SetFreePar(loadmat("param/init_final5.xls"));
	}

   // -------- Transition Model --------------------
	if (m_iModel==M_TRANS) {

		decl cParX = m_cX*m_cY;		
		
		decl cParT = sumc(m_vThres);
	
		decl cParC = m_cY*m_cFactor;
		decl cParE = m_vM[1] + m_vM[3];
		
		m_cPar = cParX + cParT + cParC + (m_cY^2-m_cY)/2 + m_cY;
		SetParCount(m_cPar);
		decl asRestrictions = new array[m_cY];
		decl eq;
		for (decl r = 0; r<m_cRestrictions;++r) {
			eq = strfind(m_asY,m_asRestrictions[r][0]);		
			if (eq!=<>) asRestrictions[eq] = m_asRestrictions[r][1:];
		}
		
		decl asnames = GetParNames();		
		decl mE = new matrix[m_cNT][m_cY];
		// mean
		decl InitParX = 0,par_m,samp_m,y_m,x_m,err_m,posx=0,posk; 
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]!=CONT && m_vType[m]!=CENSOR) {
				samp_m = m_mY[][m].!=-2 .&& m_mY[][m].!=9;
			}
			else {
				samp_m = m_mY[][m].!=999;
			}
			y_m = selectifr(m_mY[][m],samp_m);

			x_m = selectifr(m_mX,samp_m);
			// impose restrictions on xs
			posk = ones(1,m_cX);
			if (asRestrictions[m]) {
				for (decl k = 0; k<m_cX;++k) {
					if (strfind(asRestrictions[m],asnames[posx])!=-1) {		
					 	FixPar(posx,0);
						posk[k] = 0;
					}					
					posx +=1;
				}
			}
			else {
				posx +=m_cX;
			}

			x_m = selectifc(x_m,posk);
			//println("x_m = ",sumc(samp_m));
			olsc(y_m,x_m,&par_m);
			//par_m = zeros(sizec(x_m),1);
			err_m = samp_m.==1 .? m_mY[][m] - selectifc(m_mX,posk)*par_m .: constant(.NaN,m_cNT,1);
			mE[][m] = err_m;
			if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) { 
				par_m *= 1.6;
			}
			if (m_vType[m]==ORDER) {
				par_m *=0;
			}
			InitParX |= par_m;	
		}	
			InitParX = dropr(InitParX,0);
		// Restrictions on Thresholds
		//decl thres = loadmat("param/initthres.xls");
		decl pos = cParX,InitParT=0;
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]==ORDER) {
				FixPar(pos,-.Inf);
				FixPar(pos+1,0);
				InitParT |= zeros(max(m_vThres[m]-3,0),1);
				FixPar(pos+m_vThres[m]-1,+.Inf);		
				pos += m_vThres[m];
			}
		} 
		InitParT = dropr(InitParT,0);
/*		InitParT = loadmat("param/initthres.xls");
		InitParT[0] = log(InitParT[0]);
		InitParT[1] = log(InitParT[1]);
		InitParT[2] = log(InitParT[2]);
		InitParT[3] = log(InitParT[3]-0.2);
*/
		// Restrictions on Covariance Matrix (Factors)
		pos = cParX + cParT;
		decl InitParC;
		InitParC = ranu(m_cY*m_cFactor,1);
		pos += cParC;
/*
		decl Cor = correlation(mE);
		decl var = varc(mE)';
		decl InitParC = 0,ym,yn,cor;
		for (decl m = 0; m<m_cY;++m) {
			for (decl n = m; n<m_cY;++n) {
				if (m==n)  {
						InitParC |= log(varc(deleter(mE[][m])));
				}
				else {				
					 cor	= correlation(selectifr(mE[][m]~mE[][n],mE[][m].!=.NaN .&& mE[][n].!=.NaN));					
					InitParC |= tanh(cor[1][0]);															
				}										
				pos +=1;	
			}
		
		}		
		InitParC = dropr(InitParC,0);
*/


		decl InitParE = 0;
		
		for (decl m = 0; m<m_cY;++m) {
			for (decl n = m; n<m_cY;++n) {
				if (m==n)  {
					if (m_vType[m]==BIN || m_vType[m]==ORDER || m_vType[m]==CENSORBIN) {
						FixPar(pos,0);				
					}
					else {
						InitParE |= -2;
					}
				}
				else {				
					FixPar(pos,0);						
				}				
				pos +=1;	
			}
		
		}
		
		InitParE = dropr(InitParE,0);
		InitParX = loadmat("param/inittrans.xls");
  		SetFreePar(InitParX|InitParT|InitParC|InitParE);
		//SetFreePar(loadmat("param/initmini.xls"));
		//println("GetFreePar()",GetFreePar()');
		
	}

	
	SetModelStatus(MS_PARAMS);    
    return TRUE;
}
 
FEM::CalcDraws() {
	ranseed(12345);
	m_mU = haltdrawsunif(m_cR, m_cN, m_iModel==M_TRANS ? m_cFactor : m_cY, 25,1);
	if (m_iModel==M_TRANS)	   {		
			println("Getting New Draws ...");
		m_mU = setbounds(quann(m_mU),-10,10);
	}	
}

FEM::fMapFreetoPar(const vFreePar)
{
	SetFreePar(vFreePar);    
    	decl vP = GetPar();
	if (m_iModel==M_INIT) {			
		
		decl mParX,aThres=new array[m_cY],mCov;
		// Means
		mParX = shape(vP[0:m_cZ*m_cY-1],m_cZ,m_cY);
		decl pos = m_cZ*m_cY;
		
		// Thresholds
		for (decl m = 0; m<m_cY; ++m) {
			if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
				aThres[m] = vP[pos:pos+m_vThres[m]-1];
				for (decl n = 0; n<m_vThres[m];++n) {
					if (n>1) {
						aThres[m][n][0] = aThres[m][n-1][0]+exp(aThres[m][n][0]);
					}
				}
			pos += m_vThres[m];
			}	
			
		}
		  
		// Covariance
		
		mCov =	unvech(vP[pos:]);
		//println("unvech = ",mCov);
		for (decl m=0; m<m_cY;++m) {
			if (m_vType[m]==CONT || m_vType[m]==CENSOR) {
				mCov[m][m] = exp(mCov[m][m]);
			}		
		}
		
		for (decl m = 0; m<m_cY;++m) {			
			for (decl n = 0; n<m_cY;++n) {
				if (m!=n) {
					mCov[m][n] = tanh(mCov[m][n]).*sqrt(mCov[m][m].*mCov[n][n]);
				}			
			}
		}

		
		return {mParX,aThres,mCov};
	
	}	

	if (m_iModel==M_TRANS) {			
		
		decl mParX,aThres=new array[m_cY],mCovA,mCovE,mFactor;
		// Means
		mParX = shape(vP[0:m_cX*m_cY-1],m_cX,m_cY);
		decl pos = m_cX*m_cY;
		
		// Thresholds
		for (decl m = 0; m<m_cY; ++m) {
			if (m_vType[m]==ORDER) {
				aThres[m] = vP[pos:pos+m_vThres[m]-1];
				for (decl n = 0; n<m_vThres[m];++n) {
					if (n>1) {
						aThres[m][n][0] = aThres[m][n-1][0]+exp(aThres[m][n][0]);
					}
				}
			pos += m_vThres[m];
			}	
			
		}
	//	  println("asThres = ",aThres);
		// Covariance
		
/*		mCovA =	unvech(vP[pos:pos + (m_cY^2-m_cY)/2 + m_cY - 1]);
		//println("unvech = ",mCov);
		for (decl m=0; m<m_cY;++m) {
		
				mCovA[m][m] = exp(mCovA[m][m]);
		}
		
		for (decl m = 0; m<m_cY;++m) {			
			for (decl n = 0; n<m_cY;++n) {
				if (m!=n) {
					mCovA[m][n] = tanh(mCovA[m][n]).*sqrt(mCovA[m][m].*mCovA[n][n]);
				}			
			}
		}
		pos += (m_cY^2-m_cY)/2 + m_cY;
*/
		mFactor = shape(vP[pos:pos+m_cY*m_cFactor-1],m_cFactor,m_cY);
		pos += m_cY*m_cFactor;
		
		mCovE = unvech(vP[pos:]);
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]==CONT || m_vType[m]==CENSOR) {				
				mCovE[m][m] =  exp(mCovE[m][m]);
			}

		}

//		println("mParX = ",mParX);
//		println("aThres = ",aThres);
//		println("mCovA = ",mCovA);
//		println("mCovE = ",mCovE);
				
//		return {mParX,aThres,mCovA,mCovE};
		return {mParX,aThres,mFactor,mCovE};
	}		
	
}


FEM::fm_init(const vP, const adFunc, const avScore, const amHess)
{
	// Parameters and Indices
	decl mPx,asThres,mL,mCov,mXB;
	asThres = new array[m_cY];
	
		[mPx,asThres,mCov] = fMapFreetoPar(vP);
		
	mXB = m_mZ * mPx;


	
	decl mCmax,mCmin;
	mCmax = mCmin = zeros(m_cN,m_cY);
	
	for (decl m = 0; m<m_cY;++m) {
		
		if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) {
			mCmax[][m] = m_mY[][m].==1 .? +.Inf .: 0;
			mCmin[][m] = m_mY[][m].==1 .? 0 .: -.Inf;
		}
		if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
			for (decl n = 1; n < m_vThres[m];++n) {
				
				mCmax[][m] = m_mY[][m].==n .? asThres[m][n][0]   .: mCmax[][m];
				mCmin[][m] = m_mY[][m].==n .? asThres[m][n-1][0] .: mCmin[][m];				
				
				
			}	
			
		}
	
	}
	//	println("bounds ",selectifr(m_mY[][m_cY-1]~mCmin[][m_cY-1]~mCmax[][m_cY-1],m_mY[][m_vS[m_cY-1]].==1));	
	// Pierre-Carl says that it is OK for this decomposition to fail, so let's not print when it does.
	// This will hopefully remove any confusion on the part of the user over whether or not it is working.
	mL = choleski(mCov);
	
	if (mL==0) {
		println("used previous decomposition ... ");	
		mL = unit(m_cY);
		if (m_mCholeski!=0) {
			mL = unit(m_cY);//m_mCholeski;
		}
		else {
		  	mL = unit(m_cY);
		}
	}
	else {
		m_mCholeski = mL;
	}
	
	decl mProb,mEta,index,pmax,pmin,prob;
	mProb = ones(m_cN,m_cR);	
	decl mUr;	
	for (decl r = 0; r<m_cR;++r) {
		
		mEta = zeros(m_cN,m_cY);
		mUr = m_mU[][r*m_cY:r*m_cY + m_cY -1];
		 
		for (decl m = 0; m<m_cY;++m) {
		
			if (m_vType[m]==BIN || m_vType[m]==ORDER) {
			
				// taking draw consistent with observed data
				index = mXB[][m] + (mL[m][]*(mEta') )'; 
							
				pmax  = probn((mCmax[][m]- index)./mL[m][m]);
				pmin  = probn((mCmin[][m]- index)./mL[m][m]);			
			
				
				mEta[][m] = quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin);			
				
//				println("m = ",m);
//				println("Eta,",mEta[0:25][m]~mUr[0:25][m]);				
				
				// Compute probability
				mProb[][r] = mProb[][r].*(pmax - pmin);
			
				//println("mProb = ",mProb[0:25][r]);
			}
			else {
				if (m_vType[m]==CONT) {
					index = mXB[][m] + (mL[m][]*(mEta') )';
					mEta[][m] = (m_mY[][m] - index)./mL[m][m];			
					mProb[][r] = mProb[][r].*(1/mL[m][m]).*densn(mEta[][m]);
				}
				if (m_vType[m]==CENSOR) {
					index = mXB[][m] + (mL[m][]*(mEta') )';					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? (m_mY[][m] - index)./mL[m][m] .: quann(mUr[][m]); 																	
					prob = m_mY[][m_vS[m]].==1 .? (1/mL[m][m]).*densn(mEta[][m]) .: 1 ;					
					mProb[][r] = mProb[][r].*prob;					
				}
				if (m_vType[m]==CENSORBIN ) {
				
					// taking draw consistent with observed data
					index = mXB[][m] + (mL[m][]*(mEta') )'; 
								
					pmax  = probn((mCmax[][m]- index)./mL[m][m]);
					pmin  = probn((mCmin[][m]- index)./mL[m][m]);			
				
					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin) .: quann(mUr[][m]);			
									
					// Compute probability
					mProb[][r] = mProb[][r].*(m_mY[][m_vS[m]].==1 .? (pmax - pmin) .: 1);
				
				}			
				if (m_vType[m]==CENSORORDER ) {
				
					// taking draw consistent with observed data
					index = mXB[][m] + (mL[m][]*(mEta') )'; 
								
					pmax  = probn((mCmax[][m]- index)./mL[m][m]);
					pmin  = probn((mCmin[][m]- index)./mL[m][m]);			

					//println("pmax - pmin = ",selectifr(pmax~pmin,m_mY[][m_vS[m]].==1));
					
					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin) .: quann(mUr[][m]);			
									
					// Compute probability
					mProb[][r] = mProb[][r].*(m_mY[][m_vS[m]].==1 .? (pmax - pmin) .: 1);
				
				}			
			}		
		} // end loop m	
		
	} // end loop r
//decl vLL = log(meanr(mProb)); 
//adFunc[0]=double(sumc(selectifr(vLL,vLL.!=-.Inf))./m_cN);
adFunc[0]=double(sumc(log(meanr(mProb)))./m_cN);
//println("adFunc[0]",adFunc[0]);
return 1;
}

FEM::fm_initi(const vP, const adFunc, const avScore, const amHess)
{
	// Parameters and Indices
	decl mPx,asThres,mL,mCov,mXB;
	asThres = new array[m_cY];
	
		[mPx,asThres,mCov] = fMapFreetoPar(vP);
		
	mXB = m_mZ * mPx;


	
	decl mCmax,mCmin;
	mCmax = mCmin = zeros(m_cN,m_cY);
	
	for (decl m = 0; m<m_cY;++m) {
		
		if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) {
			mCmax[][m] = m_mY[][m].==1 .? +.Inf .: 0;
			mCmin[][m] = m_mY[][m].==1 .? 0 .: -.Inf;
		}
		if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {
			for (decl n = 1; n < m_vThres[m];++n) {
				
				mCmax[][m] = m_mY[][m].==n .? asThres[m][n][0]   .: mCmax[][m];
				mCmin[][m] = m_mY[][m].==n .? asThres[m][n-1][0] .: mCmin[][m];				
				
				
			}	
			
		}
	
	}
	//	println("bounds ",selectifr(m_mY[][m_cY-1]~mCmin[][m_cY-1]~mCmax[][m_cY-1],m_mY[][m_vS[m_cY-1]].==1));	
	mL = choleski(mCov);
	
	if (mL==0) {
		println("used previous decomposition ... ");	
		mL = unit(m_cY);
		if (m_mCholeski!=0) {
			mL = m_mCholeski;
		}
		else {
		  	mL = unit(m_cY);
		}
	}
	else {
		m_mCholeski = mL;
	}
	
	decl mProb,mEta,index,pmax,pmin,prob;
	mProb = ones(m_cN,m_cR);	
	decl mUr;	
	for (decl r = 0; r<m_cR;++r) {
		
		mEta = zeros(m_cN,m_cY);
		mUr = m_mU[][r*m_cY:r*m_cY + m_cY -1];
		 
		for (decl m = 0; m<m_cY;++m) {
		
			if (m_vType[m]==BIN || m_vType[m]==ORDER) {
			
				// taking draw consistent with observed data
				index = mXB[][m] + (mL[m][]*(mEta') )'; 
							
				pmax  = probn((mCmax[][m]- index)./mL[m][m]);
				pmin  = probn((mCmin[][m]- index)./mL[m][m]);			
			
				
				mEta[][m] = quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin);			
				
//				println("m = ",m);
//				println("Eta,",mEta[0:25][m]~mUr[0:25][m]);				
				
				// Compute probability
				mProb[][r] = mProb[][r].*(pmax - pmin);
			
				//println("mProb = ",mProb[0:25][r]);
			}
			else {
				if (m_vType[m]==CONT) {
					index = mXB[][m] + (mL[m][]*(mEta') )';
					mEta[][m] = (m_mY[][m] - index)./mL[m][m];			
					mProb[][r] = mProb[][r].*(1/mL[m][m]).*densn(mEta[][m]);
				}
				if (m_vType[m]==CENSOR) {
					index = mXB[][m] + (mL[m][]*(mEta') )';					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? (m_mY[][m] - index)./mL[m][m] .: quann(mUr[][m]); 																	
					prob = m_mY[][m_vS[m]].==1 .? (1/mL[m][m]).*densn(mEta[][m]) .: 1 ;					
					mProb[][r] = mProb[][r].*prob;					
				}
				if (m_vType[m]==CENSORBIN ) {
				
					// taking draw consistent with observed data
					index = mXB[][m] + (mL[m][]*(mEta') )'; 
								
					pmax  = probn((mCmax[][m]- index)./mL[m][m]);
					pmin  = probn((mCmin[][m]- index)./mL[m][m]);			
				
					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin) .: quann(mUr[][m]);			
									
					// Compute probability
					mProb[][r] = mProb[][r].*(m_mY[][m_vS[m]].==1 .? (pmax - pmin) .: 1);
				
				}			
				if (m_vType[m]==CENSORORDER ) {
				
					// taking draw consistent with observed data
					index = mXB[][m] + (mL[m][]*(mEta') )'; 
								
					pmax  = probn((mCmax[][m]- index)./mL[m][m]);
					pmin  = probn((mCmin[][m]- index)./mL[m][m]);			

					//println("pmax - pmin = ",selectifr(pmax~pmin,m_mY[][m_vS[m]].==1));
					
					
					mEta[][m] = m_mY[][m_vS[m]].==1 .? quann(mUr[][m].*pmax + (1-mUr[][m]).*pmin) .: quann(mUr[][m]);			
									
					// Compute probability
					mProb[][r] = mProb[][r].*(m_mY[][m_vS[m]].==1 .? (pmax - pmin) .: 1);
				
				}			
			}		
		} // end loop m	
		
	} // end loop r
adFunc[0]=double(log(meanr(mProb)));
return 1;
}

FEM::fm_trans(const vP, const adFunc, const avScore, const amHess)
{
	// Parameters and Indices
	decl mPx,asThres,mL,mCovA,mCovE,mXB,mA,index,mFactor;
	asThres = new array[m_cY];
	
		[mPx,asThres,mFactor,mCovE] = fMapFreetoPar(vP);
	//println("mPx = ",mPx);	
	mXB = m_mX * mPx;

	
	decl mCmax,mCmin;
	mCmax = mCmin = zeros(m_cNT,m_cY);
	
	for (decl m = 0; m<m_cY;++m) {
		
		if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) {
			mCmax[][m] = m_mY[][m].==1 .? +.Inf .: 0;
			mCmin[][m] = m_mY[][m].==1 .? 0 .: -.Inf;
		}
		if (m_vType[m]==ORDER) {
			for (decl n = 1; n < m_vThres[m];++n) {				
				mCmax[][m] = m_mY[][m].==n .? asThres[m][n][0]   .: mCmax[][m];
				mCmin[][m] = m_mY[][m].==n .? asThres[m][n-1][0] .: mCmin[][m];								
			}	
				//println("mCmin[][m]~mCmax[]][m]~m_mY[][m]",mCmin[][m]~mCmax[][m]~m_mY[][m]);
		}
	
	}
/*		
	mL = choleski(mCovA);
	if (mL==0) {
		println("used previous decomposition ... ");	
		mL = unit(m_cY);
		if (m_mCholeski!=0) {
			mL = m_mCholeski;
		}
		else {
		  	mL = unit(m_cY);
		}
	}
	else {
		m_mCholeski = mL;
	}
*/	
  
decl count = 0,vLL = 0;
decl mXp,Np,mYp,mUp,mCmaxp,mCminp;
decl sampm,pmax,pmin,probr,vProb;

for (decl p = m_cPmin; p<=m_cPmax;++p) {

	mXp = selectifr(mXB,m_vPer.==p);
	Np  = sizer(mXp)/p;
	mYp = selectifr(m_mY,m_vPer.==p);
	mUp	= m_mU[count:count + Np -1][];
	mCmaxp = selectifr(mCmax,m_vPer.==p);
	mCminp = selectifr(mCmin,m_vPer.==p);
	vProb = zeros(Np,1);

	for (decl r = 0; r<m_cR;++r) {
//		mA = (mL * mUp[][r*m_cY:r*m_cY + m_cY -1]') ';
		mA = mUp[][r*m_cFactor:r*m_cFactor + m_cFactor -1];

//		index = mXp + mA**ones(p,1);
		index = mXp + (mA**ones(p,1))*mFactor;

		probr = ones(Np,1);
		
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]==BIN) {
				sampm = 	mYp[][m].!=-2 .&& mYp[][m].!=9;			
				pmax  = probn(mCmaxp[][m]- index[][m]);
				pmin  = probn(mCminp[][m]- index[][m]);
			
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}	
			if (m_vType[m]==ORDER) {
				sampm = 	mYp[][m].!=-2 .&& mYp[][m].!=9;		
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				//	println("pmax~pmin = ",selectifr(mCmaxp[][m]~mCminp[][m]~index[][m]~pmax~pmin,sampm));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}	
			else if (m_vType[m]==CONT) {
				sampm = 	mYp[][m].!=999;		
				pmax  = densn((mYp[][m] - index[][m])./sqrt(mCovE[m][m]))./sqrt(mCovE[m][m]);
				probr = probr.*prodr(shape(sampm .==1 .? pmax .: 1,p,Np)');	
			}
			else if (m_vType[m]==CENSOR) {
				sampm = 	mYp[][m_vS[m]].==1 .&& mYp[][m].!=999;
				pmax = 	(1/sqrt(mCovE[m][m])).*densn((mYp[][m] - index[][m])./sqrt(mCovE[m][m]));
		
				probr = probr.*prodr(shape(sampm.==1 .? pmax .: 1,p,Np)');	
			}
			else if (m_vType[m]==CENSORBIN) {
				sampm = 	mYp[][m_vS[m]].==1 .&& (mYp[][m].==0 .|| mYp[][m].==1);
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}
			else if (m_vType[m]==CENSORORDER) {
				sampm = 	mYp[][m_vS[m]].==1 .&& (mYp[][m].==0 .|| mYp[][m].==1);
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}							
		}  // end loop m
		vProb += probr./m_cR;	
	}  // end loop r
		
		 
	vLL += sumc(log(vProb));
	count += Np;
} // end loop p	
		// println("LogLike = ",vLL/m_cN);
adFunc[0]=double(vLL/m_cN);
return 1;
}

FEM::fm_transi(const vP, const adFunc, const avScore, const amHess)
{
	// Parameters and Indices
	decl mPx,asThres,mL,mCovA,mCovE,mXB,mA,index,mFactor;
	asThres = new array[m_cY];
	
		[mPx,asThres,mFactor,mCovE] = fMapFreetoPar(vP);
	//println("mPx = ",mPx);	
	mXB = m_mX * mPx;

	
	decl mCmax,mCmin;
	mCmax = mCmin = zeros(m_cNT,m_cY);
	
	for (decl m = 0; m<m_cY;++m) {
		
		if (m_vType[m]==BIN || m_vType[m]==CENSORBIN) {
			mCmax[][m] = m_mY[][m].==1 .? +.Inf .: 0;
			mCmin[][m] = m_mY[][m].==1 .? 0 .: -.Inf;
		}
		if (m_vType[m]==ORDER) {
			for (decl n = 1; n < m_vThres[m];++n) {				
				mCmax[][m] = m_mY[][m].==n .? asThres[m][n][0]   .: mCmax[][m];
				mCmin[][m] = m_mY[][m].==n .? asThres[m][n-1][0] .: mCmin[][m];								
			}	
				//println("mCmin[][m]~mCmax[]][m]~m_mY[][m]",mCmin[][m]~mCmax[][m]~m_mY[][m]);
		}
	
	}
/*		
	mL = choleski(mCovA);
	if (mL==0) {
		println("used previous decomposition ... ");	
		mL = unit(m_cY);
		if (m_mCholeski!=0) {
			mL = m_mCholeski;
		}
		else {
		  	mL = unit(m_cY);
		}
	}
	else {
		m_mCholeski = mL;
	}
*/	
  
decl count = 0,vLL = 0;
decl mXp,Np,mYp,mUp,mCmaxp,mCminp;
decl sampm,pmax,pmin,probr,vProb;

for (decl p = m_cPmin; p<=m_cPmax;++p) {

	mXp = selectifr(mXB,m_vPer.==p);
	Np  = sizer(mXp)/p;
	mYp = selectifr(m_mY,m_vPer.==p);
	mUp	= m_mU[count:count + Np -1][];
	mCmaxp = selectifr(mCmax,m_vPer.==p);
	mCminp = selectifr(mCmin,m_vPer.==p);
	vProb = zeros(Np,1);

	for (decl r = 0; r<m_cR;++r) {
//		mA = (mL * mUp[][r*m_cY:r*m_cY + m_cY -1]') ';
		mA = mUp[][r*m_cFactor:r*m_cFactor + m_cFactor -1];

//		index = mXp + mA**ones(p,1);
		index = mXp + (mA**ones(p,1))*mFactor;

		probr = ones(Np,1);
		
		for (decl m = 0; m<m_cY;++m) {
			if (m_vType[m]==BIN) {
				sampm = 	mYp[][m].!=-2 .&& mYp[][m].!=9;			
				pmax  = probn(mCmaxp[][m]- index[][m]);
				pmin  = probn(mCminp[][m]- index[][m]);
			
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}	
			if (m_vType[m]==ORDER) {
				sampm = 	mYp[][m].!=-2 .&& mYp[][m].!=9;		
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				//	println("pmax~pmin = ",selectifr(mCmaxp[][m]~mCminp[][m]~index[][m]~pmax~pmin,sampm));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}	
			else if (m_vType[m]==CONT) {
				sampm = 	mYp[][m].!=999;		
				pmax  = densn((mYp[][m] - index[][m])./sqrt(mCovE[m][m]))./sqrt(mCovE[m][m]);
				probr = probr.*prodr(shape(sampm .==1 .? pmax .: 1,p,Np)');	
			}
			else if (m_vType[m]==CENSOR) {
				sampm = 	mYp[][m_vS[m]].==1 .&& mYp[][m].!=999;
				pmax = 	(1/sqrt(mCovE[m][m])).*densn((mYp[][m] - index[][m])./sqrt(mCovE[m][m]));
		
				probr = probr.*prodr(shape(sampm.==1 .? pmax .: 1,p,Np)');	
			}
			else if (m_vType[m]==CENSORBIN) {
				sampm = 	mYp[][m_vS[m]].==1 .&& (mYp[][m].==0 .|| mYp[][m].==1);
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}
			else if (m_vType[m]==CENSORORDER) {
				sampm = 	mYp[][m_vS[m]].==1 .&& (mYp[][m].==0 .|| mYp[][m].==1);
				pmax  = probn((mCmaxp[][m]- index[][m]));
				pmin  = probn((mCminp[][m]- index[][m]));
				probr = probr.*prodr(shape(sampm.==1 .? (pmax-pmin) .: 1,p,Np)');
			}							
		}  // end loop m
		vProb += probr./m_cR;	
	}  // end loop r
	//	println("vProb = ",vProb);
	vLL |= log(vProb);
  }
   vLL = dropr(vLL,0);
   
adFunc[0]=vLL;
return 1;
}

FEM::Estimate()
{
	println("\n* Requesting Estimation of Parameters ...");
	decl  vpstart, vpfree, estout;

    ClearEstimation();
	InitPar();
	CalcDraws();
    
    
    vpstart = GetFreePar();
		
	estout = DoEstimation(vpstart); 
    vpfree = isarray(estout) ? estout[0] : estout;
    
    SetFreePar(vpfree);     
	 if (m_iResult!=9) {	
    if (m_iResult >= MAX_CONV && m_iResult < MAX_MAXIT)
        m_iModelStatus = MS_ESTIMATED;
    else
        m_iModelStatus = MS_EST_FAILED;

    if (m_fPrint)
    {   Output();
        if (isarray(estout))
            OutputMax(estout[1], m_iResult, vpstart, estout[2]);
    }
    }
    return m_iModelStatus == MS_ESTIMATED;
}

FEM::DoEstimation(vStart)
{
	MaxControl(-1,1); 
	println("Model :",GetModel());
	println("\nStarting Optimization ...");
    	println("Initial Values used ");
    	print("%c",GetFreeParNames(),GetFreePar()');	
	decl time0 = timer();

	if (m_iModel==M_INIT) {
	m_iResult = MaxBFGS(fm_init, &vStart, &m_dLogLik, 0, TRUE);
	
	
	}
	if (m_iModel==M_TRANS) {
	m_iResult = MaxBFGS(fm_trans, &vStart, &m_dLogLik, 0, TRUE);		
	}
	
	SetResult(m_iResult);
	if (m_iResult!=9) {
	println("Calculating Standard Errors ...");
		
	println("Time taken for estimation :",timespan(timer(),time0));
       // m_iResult has return code, vStart will have new params
    	m_dLogLik *= m_cN;             // change to unscaled log-lik
	m_iT1est = 0; 	m_iT2est = m_cN-1;
		
	}
    return {vStart, "BFGS", FALSE};       // three return values
}

FEM::Covar()
{
	decl mH,mHinv,mG;
	
	if (m_iModel==M_INIT)  {
	
		if (m_iStdErr==HESSIAN) {
			Num2Derivative(fm_init,GetFreePar(),&mH);	
			mHinv = -invert(mH)./m_cN;            	
			if (mHinv==0){      
				mHinv = constant(.NaN,GetFreeParCount(),GetFreeParCount());
			}
			m_mCovar = mHinv;
		}
		if (m_iStdErr==OGP) {
		
			mG =  fnGradient(fm_initi,GetFreePar(),0);  
			m_mCovar = invert(mG'*mG);
			if (m_mCovar==0) {
				m_mCovar = constant(.NaN,GetFreeParCount(),GetFreeParCount());
			}
		}
	
	}
	if (m_iModel==M_TRANS)  {
	
		if (m_iStdErr==HESSIAN) {
			Num2Derivative(fm_trans,GetFreePar(),&mH);	
			mHinv = -invert(mH)./m_cN;            	
			if (mHinv==0){      
				mHinv = constant(.NaN,GetFreeParCount(),GetFreeParCount());
			}
			m_mCovar = mHinv;
		}
		if (m_iStdErr==OGP) {
		
			mG =  fnGradient(fm_transi,GetFreePar(),0);  
			m_mCovar = invertsym(mG'*mG);
		}
	
	}
	return TRUE;	
}
FEM::GetcT() {
return m_cN;
}

FEM::Output()
{
    if (!OutputHeader(GetPackageName()))     // returns FALSE if no estimation
        return;

    OutputPar();
    OutputLogLik();
    SavePar(GetFreePar());
}
FEM::OutputHeader(const sTitle)
{
    println("\n---- ", sTitle, " ----");
	println("Model: ",GetModel());
	print("\n");

    return TRUE;
}

FEM::OutputPar()
{
    decl i, tval, abstval, tprob;
    decl aspar,aspartypes;
    aspar = GetParNames();
    aspartypes = m_asParTypes;
	decl cpartypes = isarray(aspartypes) ? sizeof(aspartypes) : 0;
	
    decl vstderr = GetStdErr(), vrobstderr = GetStdErrRobust(),
      bcovarrobust = FALSE;
    decl ct = GetcT();
    decl mpar, vp = GetPar();
    decl cp = rows(vp);
    decl cdfloss = GetcDfLoss();
	
	
    mpar = vp ~ vstderr ~ vp ./ vstderr;
    if (rows(vrobstderr) > 1)
    {   mpar ~= vrobstderr ~ vp ./ vrobstderr;
        bcovarrobust = TRUE;
    }
    print("%32s", "Coefficient", "%11s", "Std.Error");
    if (bcovarrobust)
        print("%11s", "robust-SE");
    println("%9s", "t-value", "%8s", "t-prob");
    
    for (i = 0; i < cp; ++i)
    {
       // if (!m_vIsFreePar[i] && mpar[i][0] == 0)
            //continue;
        tval = mpar[i][2];
		if (i < cpartypes)
	        print("%-13s", aspar[i], " ", "%-2s",
				aspartypes[i], "%#13.6g", mpar[i][0]);
		else
	        print("%-16s", aspar[i], "%#13.6g", mpar[i][0]);
        if (!m_vIsFreePar[i])
            println("    (fixed)");
        else if (mpar[i][1] > 0)
        {
            print("%#11.4g", mpar[i][1]);
            if (bcovarrobust)
            {
                tval = mpar[i][4];
                print("%#11.4g", mpar[i][3]);
            }
			abstval = fabs(tval);
            tprob = 2 * tailt(abstval, ct - cdfloss);
            println(abstval <= 1e-4 ? "%9.2f" : abstval >= 1e3 ? "%#9.4g"
				: "%#9.3g", tval, "%8.3f", tprob);
        }
        else
            print("\n");
    }
}
FEM::OutputLogLik()
{
    decl ct = GetcT();
    decl cdfloss = GetcDfLoss();
    print("%r",{"equation "},"%c",m_asY,range(0,m_cY-1,1));
	
    println("\nlog-likelihood", "%15.9g", m_dLogLik);
    println("no. of observations", "%10d", ct,
          "  no. of parameters  ", "%10d", cdfloss);
    println("no. of draws       ", "%10d", int(m_cR),
          "  no. of dimensions  ", "%10d", int(m_cY));		  

}
FEM::OutputMax(const sMethod, const iResult, const vPstart,
						const bNumerical) {
/*    
    if (iResult >= 0)
    {
        decl deps1, deps2;
        [deps1, deps2] = GetMaxControlEps();
        println(sMethod, " using ", bNumerical ? "analytical"
								: "numerical",
            " derivatives (eps1=", deps1, "; eps2=", deps2, "):\n",
            MaxConvergenceMsg(iResult));
    }
    if (sizerc(vPstart))
        print("Used starting values:", vec(vPstart)', "\n");
*/
}

/** This function saves the results to a useful set of excel spreadsheets.

- Means_Init are the betas for the regressions
- Thresholds_Init are the cut points for any ordered outcomes
- CovarianceU_Init is the covariance matrix

\bug NaN's are not output consistently. Sometimes they show up as huge positives, sometimes \#NUM, etc. Might be an Excel problem, but the output here should be made consistent.

\todo save these crucial parameters in a fashion that allows Stata to read them in automatically. Converting the means and covariance spreadsheets to CSV is close, but still requires a manual step.
Even worse are the cut points, which currently need to be typed in by hand directly in to new51_simulate.do, making it impossible to run multiple scenarios easily.
*/
FEM::SavePar(const vFreePar) {

	if (m_iModel==M_INIT) {
	println("Saving Parameter Estimates ...");
	decl mPx,aThres,mCov;
	aThres = new array[m_cY];
	[mPx,aThres,mCov] = fMapFreetoPar(GetFreePar());

	decl mThres;
	mThres = zeros(maxc(m_vThres),m_cY);
	for (decl m = 0; m<m_cY;++m) {
		if (m_vType[m]==ORDER || m_vType[m]==CENSORORDER) {		
			mThres[0:m_vThres[m]-1][m] = aThres[m];
		}  
	}	
	
	savemat("param/"+m_iName+"_Means_Init.xls",mPx,m_asY);
	savemat("param/"+m_iName+"_Thresholds_Init.xls",mThres,m_asY);
	savemat("param/"+m_iName+"_CovarianceU_Init.xls",mCov,m_asY);
	savemat("param/"+m_iName+"_CovFreePar_Init.in7",m_mCovar);
	savemat("param/"+m_iName+"_FreePar_Init.xls",GetFreePar());
	savemat("param/"+m_iName+"_Par_Init.xls",GetPar());		
		

	decl ctMeans = new CellTable();
	ctMeans.AddData(<0,1>, m_asY, "row");
	ctMeans.AddData(<1,0>, m_asZ, "column");
	ctMeans.AddData(<1,1>, mPx);
	ctMeans.Write("param/"+m_iName+"_Means_Init.csv");

	decl ctThresh = new CellTable();
	ctMeans.AddData(<0,0>, m_asY, "row");
	ctMeans.AddData(<1,0>, selectifc(mThres,( m_vType.==ORDER || m_vType.==CENSORORDER)'));
	ctMeans.Write("param/"+m_iName+"_Thresholds_Init.csv");

	decl ctCovar = new CellTable();
	ctCovar.AddData(<0,1>, m_asY, "row");
	ctCovar.AddData(<1,0>, m_asY, "column");
	ctCovar.AddData(<1,1>, mCov);
	ctCovar.Write("param/"+m_iName+"_CovarianceU_Init.csv");

	} // end Initial Condition Model


	if (m_iModel==M_TRANS) {
	println("Saving Parameter Estimates ...");
	
	savemat("CovFreePar_Trans.in7",m_mCovar);
	savemat("FreePar_Trans.xls",GetFreePar());		
	savemat("Par_Trans.xls",GetPar());		
	} // end Initial Condition Model
}


