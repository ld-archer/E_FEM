/****************************************************************************************** 	
	PROGRAM: varlists_allyrs.sas 
	PURPOSE: The code generates macro variables for different concepts with a list of 
	year-specific variable names corresponding to that concept. The code can be included as needed
	in any program, and the list of concepts can be expanded.

******************************************************************************************/

/******** INDIVIDUAL FILE VARIABLES ****************************************************/
** Sequence number;
%let seqin=[68]ER30002 [69]ER30021 [70]ER30044 [71]ER30068 [72]ER30092 [73]ER30118 
           [74]ER30139 [75]ER30161 [76]ER30189 [77]ER30218 [78]ER30247 [79]ER30284 
           [80]ER30314 [81]ER30344 [82]ER30374 [83]ER30400 [84]ER30430 [85]ER30464 
           [86]ER30499 [87]ER30536 [88]ER30571 [89]ER30607 [90]ER30643 [91]ER30690 
           [92]ER30734 [93]ER30807 [94]ER33102 [95]ER33202 [96]ER33302 [97]ER33402 
           [99]ER33502 [01]ER33602 [03]ER33702 [05]ER33802 [07]ER33902 [09]ER34002
           [11]ER34102;
** Family number;
%let famnumin=[68]ER30001 [69]ER30020 [70]ER30043 [71]ER30067 [72]ER30091 
              [73]ER30117 [74]ER30138 [75]ER30160 [76]ER30188 [77]ER30217 [78]ER30246 
              [79]ER30283 [80]ER30313 [81]ER30343 [82]ER30373 [83]ER30399 [84]ER30429 
              [85]ER30463 [86]ER30498 [87]ER30535 [88]ER30570 [89]ER30606 [90]ER30642 
              [91]ER30689 [92]ER30733 [93]ER30806 [94]ER33101 [95]ER33201 [96]ER33301 
              [97]ER33401 [99]ER33501 [01]ER33601 [03]ER33701 [05]ER33801 [07]ER33901 
              [09]ER34001 [11]ER34101;

** Month individual born;
%let rabmonthin=[83]ER30403 [84]ER30433 [85]ER30467 [86]ER30502 [87]ER30539 [88]ER30574 [89]ER30610 
								[90]ER30646 [91]ER30693 [92]ER30737 [93]ER30810 [94]ER33105 [95]ER33205 [96]ER33305 
								[97]ER33405 [99]ER33505 [01]ER33605 [03]ER33705 [05]ER33805 [07]ER33905 [09]ER34005
								[11]ER34105;
** Year individual born;
%let rabyearin=[83]ER30404 [84]ER30434 [85]ER30468 [86]ER30503 [87]ER30540 [88]ER30575 [89]ER30611 
							[90]ER30647 [91]ER30694 [92]ER30738 [93]ER30811 [94]ER33106 [95]ER33206 [96]ER33306 
							[97]ER33406 [99]ER33506 [01]ER33606 [03]ER33706 [05]ER33806 [07]ER33906 [09]ER34006
							[11]ER34106;
							
/******** FAMILY FILE VARIABLES *****************************************************/
/* NOTE: these were not easily listed cross-year wise. 
   If pulling 1968 family data please verify that V2 is the correct famnum to use */
%let famfidin=[68]V2     [69]V442   [70]V1102  [71]V1802  [72]V2402  [73]V3002  
              [74]V3402  [75]V3802  [76]V4302  [77]V5202  [78]V5702  [79]V6302
              [80]V6902  [81]V7502  [82]V8202  [83]V8802  [84]V10002 [85]V11102 
              [86]V12502 [87]V13702 [88]V14802 [89]V16302 [90]V17702 [91]V19002 
              [92]V20302 [93]V21602 [94]ER2002 [95]ER5002 [96]ER7002 [97]ER10002
              [99]ER13002 [01]ER17002 [03]ER21002 [05]ER25002 [07]ER36002 [09]ER42002
              [11]ER47302;

/* Interview Date Variables */
%let hdiwmonthin=[97]ER10005 [99]ER13006 [01]ER17009 [03]ER21012 [05]ER25012 [07]ER36012 [09]ER42012 [11]ER47312;
%let hdiwdayin=[97]ER10006 [99]ER13007 [01]ER17010 [03]ER21013 [05]ER25013 [07]ER36013 [09]ER42013 [11]ER47313;
%let hdiwyearin=[97]ER10007 [99]ER13008 [01]ER17011 [03]ER21014 [05]ER25014 [07]ER36014 [09]ER42014 [11]ER47314;