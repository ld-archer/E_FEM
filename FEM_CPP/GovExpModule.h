#pragma once
#include "Module.h"
#include "TimeSeries.h"
#include "Model.h"
#include "SSCalculator.h"

class GovExpModule :
	public Module
{
public:
	GovExpModule(ITimeSeriesProvider *tp);
	virtual ~GovExpModule(void);
	virtual void process(PersonVector& persons, unsigned int year, Random* random);
	virtual std::string description() const {return "Govt Expenditures Module";}
	virtual void setModelProvider(IModelProvider* mp);
protected:
	/* 
	// SS Benefit calculations should be done through the SSCalculator class.  This was commented out on 7/30/2013, remove it if it is no longer needed.
	void SSBenefit(double raime, double rq, double ry_earn, unsigned int rclyr, unsigned int rbyr, bool rl, unsigned int rdthyr,
		double saime, double sq, double sy_earn, unsigned int sclyr, unsigned int sbyr, bool sl, unsigned int sdthyr,
		bool rmar, unsigned int yr,
		double &rben_g, double &rben_s, double &rben_v, double &sben_g, double &sben_s, double &sben_v);
	*/
	
	/* 
	// PIA calculations should be done through the SSCalculator class.  This was commented out on 7/30/2014, remove it if it is no longer needed.
	double SsPIA(double raime, double rq, unsigned int rbyr, bool alive, unsigned int dthyr);
	*/
	double DiBenefit(double raime, double rq, double ry_earn, unsigned int rbyr, unsigned int yr);

/** Struct to hold information about taxation paramters */	
	struct tax_params {
		/// Federal tax schedule 
		/// brackets single (s) and couples (c)
		double sbra[5];
		double cbra[5];
		double mtr[6];
		
		/// Basic deduction and old age deduction
		double bded_sing;
		double bded_coup;
		double oded_sing;
		double oded_coup;
		double pded;
		double pded_r;
		double pded_s;
		double pded_tcoup;
		double pded_tsing;
		
		
		/// taxation of social security benefits 
		double base_ssa_sing;
		double base_ssa_coup;
		double base2_ssa_sing;
		double base2_ssa_coup;

		/// tax credit for low-income elderly
		double tc_max1_sing;
		double tc_max1_one65;
		double tc_max1_both65;
		double tc_max2_sing;
		double tc_max2_one65;
			
		/// Earned Income Tax Credit
		double eic_rate;
		double eic_lim;
		double eic_tre_mar;
		double eic_tre_sig;
		double eic_phase;

		/// taxes: Detroit, Michigan
		double city_ded;
		double state_ded;
		double state_atr;
		double city_atr;
		double city_tc_thres1;
		double city_tc_thres2;
		double city_tc_mtr1;
		double city_tc_mtr2;
		double city_tc_mtr3;

		/// social security tax witheld on earnings
		double oasi_tr;
		double medc_tr;
		double stax_max;
	};


	void GovRevenues(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
		double y_ot, double y_as, bool mar, double rage, double sage,
			 double &gross, double &agi, double &ninc, double &ftax, double &stax, double &ctax, double &hoasi, double &hmed, tax_params& cur_tax_params);

	void SsTax(double ry_earn, double &rtax, double &rmed, tax_params& cur_tax_params);

	void StateTax(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
		double y_ot, double y_as, bool mar, double rage, double sage, double &stax, double &ctax, tax_params& cur_tax_params);

	void FedTax(double ry_earn, double sy_earn, double ry_pub, double sy_pub, double y_ben, double y_pen,
		    double y_ot, double y_as, bool mar, double rage, double sage, double &ftax, double &agi, tax_params& cur_tax_params);

	double eadisreg(unsigned int yr, unsigned int age);

	/** Time series for the normal retirement age */
	ITimeSeries* nra;
	
	/** Time series for the Consumer Price Index (CPI) */
	ITimeSeries* cpi_yearly;

	/** Time series for the cost of living adjustment, as an index */
	ITimeSeries* cola;

	/** Time series for the National Wage Index */
	ITimeSeries* nwi;

	/** Time series for SS Contribution and Benefit Base */
	ITimeSeries* sscap;

	/** Time series for deferred retirement credit */
	ITimeSeries* drc;

	/** Time series for earnings disregard for ages 62 - NRA */
	ITimeSeries* eadisreg1;

	/** Time series for earnings disregard for ages NRA - 70 */
	ITimeSeries* eadisreg2;

	/** Time series for significant gainful activity */
	ITimeSeries* sga;
	
	/** Model for widower benefits when no spousal record is present */
	IModel* isret_wd_model;

	/** Model for SSI benefits */
	IModel* admin_ssi_model;

	/** Calculator for SS benefits */
	SSCalculator sscalc;

	
	/** Current year tax parameters. 
		Filled in with values during process(year,...)
	*/
	tax_params current_tax_params;

};
