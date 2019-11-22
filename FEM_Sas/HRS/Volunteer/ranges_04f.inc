
/* from 2004 forward there are 3 points */
%let bvolun1 =    50;
%let bvolun2 =   100;
%let bvolun3 =   200;
%let bvolun4 =   1000;

%let bhlpff1 =    50;
%let bhlpff2 =   100;
%let bhlpff3 =   200;

%macro cardin(type,brak);
      %do i = 0 %to &brak;       	         
          %global l&i&type u&i&type; 
          
          %let h=%eval(&i-1);
          %if &i=0 %then %do;
          		%let hicut=%eval(&brak-1);
          		%let l0&type = -999999;			%let u0&type = 99999996;
          %end;
          %else %if &i=1 %then %do;
          		%let l1&type = -999999;			%let u1&type = %eval(&&b&type.1 - 1);
          %end;
          %else %if &i<&brak %then %do;
  	  		%let l&i&type = %eval(&&b&type&h + 1);	%let u&i&type = %eval(&&b&type&i - 1);
	  %end;
          %else %do;
  	  		%let l&i&type = %eval(&&b&type&h + 1);	%let u&i&type = 99999996;
          %end;
      %end;



  %global prp&type opn&type;
  %let prp&type =&brak;  		* number of proper brackets *;
  %let opn&type=%eval(&brak+10);	* cc&type for no bracket info **;

  /************************************************************
  VALUE FORMATS
  &type.bnd 
  -Translates max and min values to lower and upper bound proper brackets
  &type.rng
  -Translates continuous values to proper bracket numbers
  &type.lo
  -Translates bracket numbers into lower bound continuous values
  &type.up 
  -Translates bracket numbers into upper bound continuous values
  &type.tab 
  -Translates bracket numbers into ranges for descriptive output
  ************************************************************/
  proc format;
  
    value &type.bnd
      0, &&u1&type = 1
      %do i=2 %to &&prp&type;
          &&l&i&type, &&u&i&type = &i
      %end;;

    value &type.rng                              
      %do i=1 %to %eval(&&prp&type-1);   
          %let j=%eval((&i+1)*10);                
          &&l&i&type - &&u&i&type = &i     
          &&b&type&i = &j 
      %end;
          &&l&brak&type - 999999999 = &brak;                                

    value &type.lo           
    	  .,.Z,0,&&opn&type = -999999 
          %do i=1 %to &&prp&type;
              %let j=%eval((&i+1)*10);
              %let k=%eval(&i*11);
              &i,&k = &&l&i&type
              %if &i<&&prp&type %then &j = &&b&type&i;
          %end;;                 
    value &type.up           
    	  .,.Z,0,&&opn&type = &&u&brak&type 
          %do i=1 %to &&prp&type;
              %let j=%eval((&i+1)*10);
              %let k=%eval(&i*11);
              &i,&k = &&u&i&type
              %if &i<&&prp&type %then &j = &&b&type&i;
          %end;;                  

    value &type.tab
    	      %do i=1 %to %eval(&&prp&type-1);
     	          %let j=%eval((&i+1)*10);    
    	          &i = "&&l&i&type - &&u&i&type"
     	          &j = "&&b&type&i"            
    	      %end;
	      &&prp&type = "&&l&brak&type.+"
    	      ;
  
  run;
  
  
%mend;

%cardin (volun,5)
%cardin (hlpff,4)
