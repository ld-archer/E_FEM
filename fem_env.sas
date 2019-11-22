
/** \file

 sets up macro variables that give locations of data libraries, formats, macros, etc.
*/

%let maxwv=12;
%let maxfamwv=10;
%let minyear=1992;
%let maxyear=2014;
%let rndv= %sysget(RANDVER);
%let rfamv = %sysget(RANDFAMV);

%let rootdir= %sysget(ROOT);
%let fmtlib=&rootdir./FEM_Sas/HRS/Fmt/;
%let maclib=&rootdir./FEM_Sas/HRS/Mac/;
%let outlib=&rootdir./input_data/;

* path to store restricted HRS data products - This is not used in the trunk.  If you are generating restricted data products, follow this template;
%let dua_rand_hrs=%sysget(HRSDIR);

%let dataroot= %sysget(HRSPUB);
%let hrsprojects = %sysget(HRSPROJECTS);
%let hrslib=&dataroot./SAS/;

%let resroot = %sysget(HRSRESTRICT);
%let mcare_data=&resroot./../Claims/Sas/;
%let mcare_xref=&resroot./../Claims/Xref/;

%let reshrslib = &resroot./;

%let psid = %sysget(PSIDPUB);