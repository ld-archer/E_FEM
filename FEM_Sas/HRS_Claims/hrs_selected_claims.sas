/** \file hrs_selected_claims.sas This file creates a compendium of Medicare claims based on the years included by minyear and maxyear from fem_env.sas.

    Also created are a number of indicator variables, some of general use (e.g. exlcu_hmo_enroll) and some disease-specific (e.g. afib_exclu_valve). Rather
    than creating multiple modules for different diseases, it will be much more efficient to create all the indicators in one spot. This minimizes the
    number of reads/writes of the claims (a large data set) and keeps down the number of files that need to be maintained.
   

    inputs: HRS-linked Medicare claims, linkage file
    outputs: hrs&minyear.&maxyear._clms and hrs&minyear.&maxyear._clms_trans in the restricted output directory

    original author: Jeff Sullivan, March 2013

    $Id: hrs_selected_claims.sas 5 2013-07-24 20:34:41Z jeffreys $

    */

%include "../../fem_env.sas";

filename projauto ".";
options mautosource sasautos=(projauto sasautos) threads ;

libname routd "&dua_rand_hrs.";
libname outd "&outlib.";
libname xref "&mcare_xref.";
libname clms "&mcare_data.";

proc sql;
    create table routd.hrs&minyear.&maxyear._basf as
        select x.hhidpn,
        b.bid_hrs,
        b.ab_mo_cnt < 12 as exclu_ab_enroll,
        b.hmo_mo > 0 as exclu_hmo_enroll,
        b.ms_cd not in ('10','11') as exclu_age,
        calculated exclu_ab_enroll | calculated exclu_hmo_enroll | calculated exclu_age as exclu_person_year,
        b.start_dt, b.end_dt,
        year(b.start_dt) as clm_year,
        b.ami, b.alzh, b.alzhdmta, b.atrialfb, b.cataract, b.chrnkidn, b.copd,
        b.chf, b.diabetes, b.glaucoma, b.hipfrac, b.ischmcht, b.depressn, b.osteoprs,
        b.ra_oa, b.strketia, b.cncrbrst, b.cncrclrc, b.cncrprst, b.cncrlung, b.cncrendm,
        b.amie, b.alzhe, b.alzhdmte, b.atrialfe, b.catarcte, b.chrnkdne, b.copde,
        b.chfme, b.diabtese, b.glaucmae, b.hipfrace, b.ischmche, b.deprssne,
        b.osteopre, b.ra_oa_e, b.strktiae, b.cncrbrse, b.cncrclre, b.cncrprse,
        b.cncrlnge, b.cncendme
        from xref.hrscms2008 (keep=hhidpn bid_hrs_10) as x
        inner join clms.basf_1991_2008 as b on x.bid_hrs_10=b.bid_hrs;
quit;

proc freq data=routd.hrs&minyear.&maxyear._basf;
    tables exclu_ab_enroll exclu_hmo_enroll exclu_age exclu_person_year;
run;

* This toy macro does not really deserve its own file;
%macro process_clms(first, last);
    %do i=&first. %to &last.;
        %process_clmyr(&i.)
        %end;
    %mend;

filename clms_all TEMP;
data clms_all;
    set %process_clms(&minyear., &maxyear.);

    format claim_date afib_date date.;
    claim_date = input(compress(from_dt), yymmdd8.);
    
    dgn_str = trim(catx(" ", of dgnscd:));
    prc_str = trim(catx(" ", of prcdrcd:));
    cpt_str = trim(catx(" ", of hcpscd:));
    rev_str = trim(catx(" ", of rvcntr:));
    
    length clmtype $2;
    if ip then clmtype = "ip";
    if op then clmtype = "op";
    if pb then clmtype = "pb";

    afib_dgn = prxmatch("/\b42731/", dgn_str) > 0;
    afib_cpt = prxmatch("/\b9920[12345]|\b9921[12345]|\b9921[7890]|\b99220|\b9924[12345]|\b9930[456789]|\b993[12]\d|\b9933[01234567]|\b9934[12345]/", cpt_str) > 0 |
        prxmatch("/\b9934[789]|\b99350|\b9938[1234567]|\b9939[1234567]|\b9940[1234]|\b9941[12]|\b9942[09]|\b9945[56]|\b99499/",cpt_str) > 0;
    valve_dgn = prxmatch("/\bV422|\bV433|\b39[4567]\d\d|\b424\d\d|\b746[01234567]/", dgn_str) > 0;
    valve_prc =  prxmatch("/\b350\d|\b351\d|\b352\d/", prc_str) > 0;
    valve_cpt = prxmatch("/\b3340[0136]|\b3341[01234567]|\b3342[0256789]|\b33430|\b3346[0458]|\b3347[0124568]/", cpt_str) > 0;
    cardiac_prc = prxmatch("/\b005\d|\b3[567]\d\d/", prc_str)> 0;
    pericarditis_dgn = prxmatch("/\b391\d|\b393|\b420\d|\b4232|\b03641|\b07421|\b09381|\b09883/", dgn_str) > 0;
    myocarditis_dgn = prxmatch("/\b3912|\b422\d\d|\b07423|\b3980|\b4290|\b03282|\b03643|\b09382|\b1303/", dgn_str) > 0;
    pulm_embolism_dgn = prxmatch("/\b4151\d/", dgn_str) > 0;
    hyperthyroidism_dgn = prxmatch("/\b242\d/", dgn_str) > 0;
    diabe_dgn = prxmatch("/\b250/", dgn_str) > 0;
    
    er_visit = prxmatch("/\b045\d|\b0981/", rev_str) > 0;
    
    afib_count = 0.0;
    if afib_dgn & clmtype in ("ip") then afib_count=1.0;
    if afib_dgn & er_visit then afib_count=1.0;
    if afib_dgn & clmtype in ("op") & afib_cpt then afib_count=1.0;
    if afib_dgn & clmtype in ("pb") & afib_cpt then afib_count = 0.5;
    if afib_count > 0 then afib_date = claim_date;

run;

* nowarn used because of duplicate bid_hrs variables;
proc sql nowarn;
    create table routd.hrs&minyear.&maxyear._clms as select
        a.*, b.*,
        sum(afib_count) >= 1 as any_afib,
        case calculated any_afib when 1 then min(afib_date) else . end as afib_index_date format=date.,
        calculated afib_index_date - 365 as pre_12m_date format=date.,
        calculated afib_index_date - 90 as pre_3m_date format=date.,
        (valve_dgn | valve_prc | valve_cpt) & claim_date between calculated pre_12m_date and calculated afib_index_date as afib_exclu_valve,
        cardiac_prc & claim_date between calculated pre_3m_date and calculated afib_index_date as afib_exclu_cardiac,
        pericarditis_dgn & claim_date between calculated pre_3m_date and calculated afib_index_date as afib_exclu_pericarditis,
        myocarditis_dgn & claim_date between calculated pre_3m_date and calculated afib_index_date as afib_exclu_myocarditis,
        pulm_embolism_dgn & claim_date between calculated pre_3m_date and calculated afib_index_date as afib_exclu_embolism,
        hyperthyroidism_dgn & claim_date between calculated pre_12m_date and calculated afib_index_date as afib_exclu_hyperthyroidism
        from
        routd.hrs&minyear.&maxyear._basf as a left join clms_all as b
        on a.bid_hrs=b.bid_hrs and a.clm_year=year(b.claim_date)
        where not a.exclu_person_year
        group by a.bid_hrs, a.clm_year;
    quit;
    
proc sort data=routd.hrs&minyear.&maxyear._clms;
    by bid_hrs clm_year;
run;

proc summary data=routd.hrs&minyear.&maxyear._clms;
    by bid_hrs clm_year;
    id hhidpn;
    vars any_afib afib_exclu: exclu_: diabe_dgn;
    output out=routd.hrs&minyear.&maxyear._clms_trans max=;
run;
