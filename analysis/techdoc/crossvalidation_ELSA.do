/* Creating script for internal validation.

This script will extract information from ELSA on chronic disease, ADLs and IADLs
for both men and women, and compares them to estimates produced by our FEM 
simluation. 

ELSA first wave was in 2002, and data was collected every 2 years subsequently 
(known as waves), with our current final wave (wave 6) collected in 2014.
We will therefore simulate from 2006 onwards, allowing us to see unsimulated 
ELSA data for the first 6 years, and then a comparison with simulated FEM data
from 2006-2014, finally showing only FEM simulated data from 2014 onwards.

This is to validate our early simulated data against known true trajectories 
in the raw data.

*/

quietly include ../../fem_env.do

use $outdata/H_ELSA.dta, clear

local chronic_diseases cancre diabe hibpe hearte lunge stroke
local disabilities adlstat iadlstat

local minwave 3
local maxwave 6
