%include "setup.inc";
%include "&maclib.psidget.mac";  /* macro to get early release data */ 
%include "&maclib.renyrv.mac";  /* macro to rename variables */

proc sql;
	create table temp1 (drop = tmpid) as
	select a.*, b.*
	from proj.demographics ( rename = (id = hhidpn) keep = id age: inyr: hdwf: hdwfever hispan white black other male married: widowed: single: aged: bmonth byear iwdt: childses grewup ) as a 
		left join proj.extract_data (drop = ER: smoke:  age: inyr: hdwf: mstatalt: hdwfever grewup: famnum69-famnum97 seq69-seq95 relhd69-relhd95 parpoor69-parpoor95 chld: srh: cancrlimit: diablimit: 
		heartlimit: hibplimit: lunglimit: heartalimit: stroklimit: 
		strokeage: heartattackage: heartdiseaseage: hypertensionage: asthmaage: lungdiseaseage: 
		diabetesage: arthritisage: memorylossage: learningdisorderage: cancerage: psychprobage:
		respsadness: respnervous: resprestless: resphopeless: respeffort: respworthless: respk6scale:
		alcohol: alcdrinks: alcfreq: satisfaction: alcbinge:
		rename = (id = tmpid famnum68=hhid) ) as b
	on a.hhidpn = b.tmpid;

	create table temp2 (drop = tmpid) as
	select a.*, c.*
	from temp1 as a left join proj.health ( rename = (id = tmpid )  ) as c
	on a.hhidpn = c.tmpid;

	create table temp3 (drop = tmpid) as
	select a.*, d.*
	from temp2 as a left join proj.limitations ( rename = (id = tmpid ) keep = id adlstat: iadlstat: adlhelp: limitwrk:) as d
	on a.hhidpn = d.tmpid;

	create table temp4 (drop = tmpid) as
	select a.*, e.*
	from temp3 as a left join proj.education ( rename = (id = tmpid ) keep = id hsless: college: feduc meduc outoflabor: edyrs: educ: educ_b: degree: colldegyr somecollyr hsdegyr gedgradyr) as e
	on a.hhidpn = e.tmpid;

	create table temp5 (drop = tmpid) as
	select a.*, f.*
	from temp4 as a left join proj.marrvars ( rename = (id = tmpid )) as f
	on a.hhidpn = f.tmpid;

	create table temp6 (drop = tmpid) as
	select a.*, g.*
	from temp5 as a left join proj.children ( rename = (id = tmpid ) keep = id births: birthse: kidsinfu: numbiokids: yrsnclastkid: siblings: ) as g
	on a.hhidpn = g.tmpid;

	create table temp7 (drop = tmpid) as
	select a.*, s.*
	from temp6 as a left join proj.wfrel ( rename = (id = tmpid ) keep = id sp_id: ) as s
	on a.hhidpn = s.tmpid;
	
	create table temp8 (drop = tmpid) as
	select a.*, i.*
	from temp7 as a left join proj.childhealth ( rename = (id = tmpid )  ) as i
	on a.hhidpn = i.tmpid;
	
	create table temp9 (drop = tmpid) as
	select a.*, j.*
	from temp8 as a left join proj.k6 ( rename = (id = tmpid )  ) as j
	on a.hhidpn = j.tmpid;
	
	create table feminput.psid_merge as
	select a.*, h.ofch, h.relinv
	from temp9 as a left join proj.famrelv as h
	on a.hhidpn=h.id
	order a.hhidpn;
quit;

