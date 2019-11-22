/* transfers_tokids.sas
   collect financial transfers to kids variables from count[yy]r files.
   the count[yy]r files are precursors to the RAND Family data, not yet released.
   they are respondent level.
   Amounts in R* variables are for the couple. They will be divided in half for married individuals
   in the analysis but are the household amount here.
*/

options ls=125 ps=58 nocenter replace compress=no mprint; /* FILELOCKS=NONE needed at NBER */

%include "../../../fem_env.sas";  /* file to set up libnames, fmt/mac locations */

libname rfam "&hrslib.RANDFAM";
libname library "&hrslib";
libname out "&outlib";

proc sql;
	create table count98r as
		select a.*,b.r4tcamt as s4tcamt, b.r4tcany as s4tcany
		from rfam.count98r (keep=hhidpn r4tcamt r4tcany h4cpl s4hhidpn) a
		left join rfam.count98r (keep =hhidpn r4tcamt r4tcany) b
		on a.s4hhidpn=b.hhidpn
		order hhidpn;	
	
	create table count00r as
		select a.*,b.r5tcamt as s5tcamt, b.r5tcany as s5tcany
		from rfam.count00r (keep=hhidpn r5tcamt r5tcany h5cpl s5hhidpn) a
		left join rfam.count00r (keep =hhidpn r5tcamt r5tcany) b
		on a.s5hhidpn=b.hhidpn
		order hhidpn;

	create table count02r as
		select a.*,b.r6tcamt as s6tcamt, b.r6tcany as s6tcany
		from rfam.count02r (keep=hhidpn r6tcamt r6tcany h6cpl s6hhidpn) a
		left join rfam.count02r (keep =hhidpn r6tcamt r6tcany) b
		on a.s6hhidpn=b.hhidpn
		order hhidpn;
	
	create table count04r as
		select a.*,b.r7tcamt as s7tcamt, b.r7tcany as s7tcany
		from rfam.count04r (keep=hhidpn r7tcamt r7tcany h7cpl s7hhidpn) a
		left join rfam.count04r (keep =hhidpn r7tcamt r7tcany) b
		on a.s7hhidpn=b.hhidpn
		order hhidpn;
	
	create table count06r as
		select a.*,b.r8tcamt as s8tcamt, b.r8tcany as s8tcany
		from rfam.count06r (keep=hhidpn r8tcamt r8tcany h8cpl s8hhidpn) a
		left join rfam.count06r (keep =hhidpn r8tcamt r8tcany) b
		on a.s8hhidpn=b.hhidpn
		order hhidpn;
	
	create table count08r as
		select a.*,b.r9tcamt as s9tcamt, b.r9tcany as s9tcany
		from rfam.count08r (keep=hhidpn r9tcamt r9tcany h9cpl s9hhidpn) a
		left join rfam.count08r (keep =hhidpn r9tcamt r9tcany) b
		on a.s9hhidpn=b.hhidpn
		order hhidpn;

* count files not available for 2010
	create table count10r as
		select a.*,b.r10tcamt as s10tcamt, b.r10tcany as s10tcany
		from rfam.count10r (keep=hhidpn r10tcamt r10tcany h10cpl s10hhidpn) a
		left join rfam.count10r (keep =hhidpn r10tcamt r10tcany) b
		on a.s10hhidpn=b.hhidpn
		order hhidpn;


data out.transfers_tokids;
	merge 	count98r (in=_in98 keep=hhidpn r4tcamt r4tcany h4cpl s4tcamt s4tcany)
		count00r (in=_in00 keep=hhidpn r5tcamt r5tcany h5cpl s5tcamt s5tcany)
    count02r (in=_in02 keep=hhidpn r6tcamt r6tcany h6cpl s6tcamt s6tcany)
		count04r (in=_in04 keep=hhidpn r7tcamt r7tcany h7cpl s7tcamt s7tcany)
		count06r (in=_in06 keep=hhidpn r8tcamt r8tcany h8cpl s8tcamt s8tcany)
		count08r (in=_in08 keep=hhidpn r9tcamt r9tcany h9cpl s9tcamt s9tcany)
		count10r (in=_in10 keep=hhidpn r10tcamt r10tcany h10cpl s10tcamt s10tcany)
     ;
    by hhidpn;

    array in_[*] in98 in00 in02 in04 in06 in08 in 10;
    array _in_[*] _in98 _in00 _in02 _in04 _in06 _in08 _in10;
    
    do i=1 to dim(in_);
       in_[i]=_in_[i];
    end;
run;

proc means data=out.transfers_tokids;
run;

proc means data=out.transfers_tokids;
	class h4cpl;
	var r4tcamt s4tcamt;
run;

proc print data=out.transfers_tokids (where=(r5tcamt>100000) obs=20);
	var HHIDPN r4tcamt r5tcamt r6tcamt r7tcamt r8tcamt r9tcamt r10tcamt H4cpl h5cpl h6cpl h7cpl h8cpl h9cpl /*h10cpl*/;
run;

