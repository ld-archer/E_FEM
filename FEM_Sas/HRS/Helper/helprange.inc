
%macro cardin(type,brak);
  ** 1 loop for hh level questions, 2 for resp/part questions **;
  %do iq=1 %to %length(&qtype);
      %if &qtype=h %then %let Q= ;
      %else %let Q=%substr(&qtype,&iq,1);
      
      %if (&type=semp or &type=wage) and &Q=r %then %let seq=3;
      %else %let seq=1;

* Generate income bracket macro variables *;  
  
      %do i = 0 %to 11;       
            %global l&i&Q&type u&i&Q&type; 
      %end;                

  %let l0&Q&type = 0;	%let u0&Q&type = 999999999;

%IF &BRAK = 5 %THEN %DO;
  %let l1&Q&type = 0;	%let u1&Q&type = %eval(&&b&type.1 - 1);
  %let l2&Q&type = %eval(&&b&type.1 +1);	%let u2&Q&type = %eval(&&b&type.2 - 1);
  %let l3&Q&type = %eval(&&b&type.2 +1);	%let u3&Q&type = %eval(&&b&type.3 - 1);
  %let l4&Q&type = %eval(&&b&type.3 +1);	%let u4&Q&type = %eval(&&b&type.4 - 1);
  %let l5&Q&type = %eval(&&b&type.4 +1);	%let u5&Q&type = 999999999;
  
  %let l6&Q&type = 0;	%let u6&Q&type = %eval(&&b&type.2 - 1);

  %if &seq=3 %then %do;
      %let l7&Q&type = 0;	%let u7&Q&type = %eval(&&b&type.3 - 1);
      %let l8&Q&type = %eval(&&b&type.1 +1);	%let u8&Q&type = 999999999;            
      %let l9&Q&type = %eval(&&b&type.2 +1);	%let u9&Q&type = 999999999;            
      %let l10&Q&type = %eval(&&b&type.3 +1);	%let u10&Q&type = 999999999;           

      %let l11&Q&type = 0;		%let u11&Q&type = 999999999;
  %end;
  
  %if &seq=1 %then %do;
      %let l7&Q&type = %eval(&&b&type.2 +1);	%let u7&Q&type = 999999999;            
      %let l8&Q&type = %eval(&&b&type.3 +1);	%let u8&Q&type = 999999999;           

      %let l9&Q&type = 0;		%let u9&Q&type = 999999999;
  %end;      

  %if &inctype=asset %then %do;
      %let l7&Q&type = 0;		%let u7&Q&type = %eval(&&b&type.3 - 1);           
  %end;      
%END;

%IF &BRAK = 4 %THEN %DO;
  %let l1&Q&type = 0;	%let u1&Q&type = %eval(&&b&type.1 - 1);
  %let l2&Q&type = %eval(&&b&type.1 +1);	%let u2&Q&type = %eval(&&b&type.2 - 1);
  %let l3&Q&type = %eval(&&b&type.2 +1);	%let u3&Q&type = %eval(&&b&type.3 - 1);
  %let l4&Q&type = %eval(&&b&type.3 +1);	%let u4&Q&type = 999999999;
               
  %let l5&Q&type = 0;	%let u5&Q&type = %eval(&&b&type.2 - 1);
  %let l6&Q&type = %eval(&&b&type.2 +1);	%let u6&Q&type = 999999999;
  
  %let l7&Q&type = 0;	%let u7&Q&type = 999999999;
  
%END;

%IF &BRAK = 2 %THEN %DO;
  %let l1&Q&type = 0;	%let u1&Q&type = %eval(&&b&type.1 - 1);
  %let l2&Q&type = %eval(&&b&type.1 +1);	%let u2&Q&type = 9999999;

  %let l3&Q&type = 0;	%let u3&Q&type = 9999999;
%END;

%IF &BRAK = 0 %THEN %DO;
  %let l1&Q&type = 0;	%let u1&Q&type = 999999999;
%END;

  %global brk&Q&type prp&Q&type opn&Q&type;
  %if &brak>0 %then %let opn&Q&type=%eval(&brak+10);
  
  %if &brak=5 %then %do;
      %if &seq=3 %then %do;
          %let brk&Q&type =10; 
          %let raword = 1 3 6 9 11 4 7 14 13 12 98; 
      %end;  		
      
      %else %if &inctype=asset %then %do;
          %let brk&Q&type = 8;
          %let raword = 1 3 6 9 11 4 7 12 98;
      %end;

      %else %if &Q&type=psemp or &Q&type=pwage %then %do;
          %let brk&Q&type = 8;
          %let raword = 1 3 6 9 11 4 13 12 98;
      %end;

      %else %do;
          %let brk&Q&type = 8;
          %let raword = 1 3 6 8 10 4 12 11 98;
      %end;
      
      %let prp&Q&type =5;  		
  %end;
  
  %if &brak=4 %then %do;
      %let brk&Q&type =6;
      %let prp&Q&type =4;
      %let raword = 1 3 6 8 4 9 98;
  %end;

  %if &brak=2 %then %do;
      %let brk&type =2;		* no brackets, dummy "bracket" used + range cards *;
      %let prp&type =2;
      %let raword = %str(5 1 8,9);
  %end;  

  %if &brak=0 %then %do;
      %let brk&Q&type =0;
      %let prp&Q&type =0;
  %end;
  
  %let start=%eval(&&prp&Q&type + 1);                             
  %let stop=%eval(&&brk&Q&type + 1);   
                                                           
  /************************************************************
  VALUE FORMATS
  &type.brk (rsempBRK.)
  -Translates raw value (Patty's value?) of bracketing item into our bracket number
  &type.abt (rsempABT.)
  -Translates raw value (Patty's value?) of bracketing item into exact amount for 
   households answering "about $2500", for example, in bracket sequence
  &type.rng (rsempRNG.)
  -Translates continuous values to proper bracket numbers
  &type.lo (rsempLO.)
  -Translates bracket numbers into lower bound continuous values
  &type.up (rsempUP.)
  -Translates bracket numbers into upper bound continuous values
  &type.tab (rsempTAB.)
  -Translates bracket numbers into ranges for descriptive output
  ************************************************************/

  proc format;

    %if &brak>0 %then %do;
         value &Q&type.brk                              
              %do i=1 %to &stop;                   
                  %let rawbrak = %scan(&raword,&i,' ');
                  &rawbrak = &i                  
              %end;                                  
              ;  
         
         value &Q&type.abt
              %if %substr(&type,1,2)=lu %then %do;
                  3 = &&b&type.1
              %end;
              %else %do;
                  2 = &&b&type.1                          
                  5 = &&b&type.2                          
                  %if (&type=semp or &type=wage or &type=busin) %then %do;                              
                      8 = &&b&type.3                      
                      10 =  &&b&type.4                    
                  %end; 
	          %else %do;
                      7 = &&b&type.3                      
                      %if &brak=5 %then 9 =  &&b&type.4;  
                  %end;                                   
              %end;                                 
              ;
                                            
         value &Q&type.rng                              
         %do i=1 %to %eval(&&prp&Q&type-1);   
             %let j=%eval((&i+1)*10);             
             &&l&i&Q&type - &&u&i&Q&type = &i  
             &&b&type&i = &j             
         %end;                           
          &&l&brak&Q&type - 999999999 = &brak                                
              ; 
    %end;
    
    %else %do;
        value &Q&type.rng 
              .Z,.D = 0                             
	      &&l1&Q&type - &&u1&Q&type = 1       
              ;                                      
    %end;  
                                         
    %if &brak>0 %then %do;
    value &Q&type.lo           
    	  .,.Z,0,&&opn&Q&type = 0 
          %do i=1 %to &&prp&Q&type;
              %let j=%eval((&i+1)*10);
              %let k=%eval(&i*11);
              &k = &&l&i&Q&type
              %if &i<&&prp&Q&type %then &j = &&b&type&i;
          %end;;                 
    value &Q&type.up           
    	  .,.Z,0,&&opn&Q&type = &&u&brak&Q&type 
          %do i=1 %to &&prp&Q&type;
              %let j=%eval((&i+1)*10);
              %let k=%eval(&i*11);
              &k = &&u&i&Q&type
              %if &i<&&prp&Q&type %then &j = &&b&type&i;
          %end;;      
        value &Q&type.loc           
        	  .,.Z,0 = &&l0&Q&type 
              %do i=1 %to &stop; 
                  &i = &&l&i&Q&type
              %end;              
              ;                  
        value &Q&type.upc           
        	  .,.Z,0 = &&u0&Q&type 
              %do i=1 %to &stop; 
                  &i = &&u&i&Q&type
              %end;              
              ;    
                      
    %end;  
    
    %else %do;
        value &Q&type.lo               
       	      0,1 = &&l1&Q&type    
              ;                      
        value &Q&type.up               
              0,1 = &&u1&Q&type    
              ;                      
    %end; 
            
    *** CHECK THESE BREAKDOWNS  ***;
    %if &brak>0 %then %do;
        value &Q&type.tab
    	      %do i=1 %to %eval(&&prp&Q&type-1);
     	          %let j=%eval((&i+1)*10);    
    	          &i = "&&l&i&Q&type - &&u&i&Q&type"
     	          &j = "&&b&type&i"            
    	      %end;
	      &&prp&Q&type = "&&l&brak&Q&type.+";
    %end;
          ;
          
  run;
                     
   %end;  ** 1 or 2 loops **;       
  run;
                                                  
%mend cardin;

%let qtype=h;
%cardin (days,0)
%cardin (hours,0)
%cardin (tothr,0)

