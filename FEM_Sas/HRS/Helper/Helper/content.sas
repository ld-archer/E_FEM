options ls=120 ps=58 nocenter replace nofmterr compress=yes;

libname ahd93 "/homer/d/HRSAHEAD/AheadW1/Ssd";

%macro cont(lib,fn);
proc printto print="&fn..cont.txt" new;
proc contents data=&lib..&fn;
run;
%mend;
%cont(ahd93,bhp21)
