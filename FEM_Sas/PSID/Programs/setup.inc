options ls=200 ps=82 nocenter replace nodate nonumber mprint nofmterr;

%include "../../../fem_env.sas";

libname psid "&psid./Sas";
libname proj "./Output/"; 
libname feminput "../../../input_data/";

/* First year and last year of data to include */
%let minyr = 1969;
%let maxyr = 2015;

/* Earliest year of data that we'll be pulling (used for high school and college attendance back to 1985) */
%let minrawyr = 1985;

/* Define paths */
%let topdir = ./ ;
%let maclib = &topdir.Mac/;
%let fmtlib = &topdir.Fmt/;
%let outlib = &topdir.Output/;

/* Default macros to include */
%include "&maclib.listyrv.mac";
%include "&maclib.labelyrv.mac";
