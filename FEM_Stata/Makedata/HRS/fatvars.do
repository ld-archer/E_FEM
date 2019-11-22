/** \file fatvars.do This file holds all the variables that we merge in from the fat files.

Each wave has its own list. Please keep these lists to one variable per line in alphabetical order.
This makes merges where the lists have changed MUCH easier to manage.

Now that there is a Harmonized HRS, those variables are listed here as well.
*/
  #delimit;

  /* Harmonized HRS variables */
  local harmvars r*hometyp r*rxchol
;
  
  /* Code binge drinking variables for waves 4 + 
1 do you ever drink
2 average days per week drink in last three months
3 average drinks per day in last three months when drank 
4 number of days with 4+ drinks in last three months

*/;
local r4alcohol f1282 f1283 f1284 f1285;
local r5alcohol g1415 g1416 g1417 g1418;
local r6alcohol hc128 hc129 hc130 hc131;
local r7alcohol jc128 jc129 jc130 jc131;
local r8alcohol kc128 kc129 kc130 kc131;
local r9alcohol lc128 lc129 lc130 lc131;
local r10alcohol MC128 MC129 MC130 MC131;
local r11alcohol nc128 nc129 nc130 nc131;
local r12alcohol oc128 oc129 oc130 oc131;

/* ADL Help Variables */;
local r4meals f2562 f2564 f2565;
local r4grocery f2567 f2569 f2570;
local r4phone f2572 f2574 f2575;
local r4medication f2577 f2578 f2579 f2580;
                           
local r5meals g2860 g2862 g2863;              
local r5grocery g2865 g2867 g2868;
local r5phone g2870 g2872 g2873;                          
local r5medication g2875 g2876 g2877 g2878;
                                                                   
local r6meals hg041 hg042 hg043;
local r6grocery hg044 hg045 hg046;
local r6phone hg047 hg048 hg049;
local r6medication hg050 hg051 hg052 hg053;
                                                                   
local r7meals jg041 jg042 jg043;
local r7grocery jg044 jg045 jg046;
local r7phone jg047 jg048 jg049;
local r7medication jg050 jg051 jg052 jg053;
                                                             
local r8meals kg041 kg042 kg043;
local r8grocery kg044 kg045 kg046;
local r8phone kg047 kg048 kg049;
local r8medication kg050 kg051 kg052 kg053;
                                                             
local r9meals lg041 lg042 lg043;
local r9grocery lg044 lg045 lg046;
local r9phone lg047 lg048 lg049;
local r9medication lg050 lg051 lg052 lg053;

local r10meals MG041 MG042 MG043;
local r10grocery MG044 MG045 MG046;
local r10phone MG047 MG048 MG049;
local r10medication MG050 MG051 MG052 MG053;

local r11meals ng041 ng042 ng043;
local r11grocery ng044 ng045 ng046;
local r11phone ng047 ng048 ng049;
local r11medication ng050 ng051 ng052 ng053;

local r12meals og041 og042 og043;
local r12grocery og044 og045 og046;
local r12phone og047 og048 og049;
local r12medication og050 og051 og052 og053;

/* Assisted Living Variables */;
local r4al f56 f306 f2840 f2857 f2858 f2859 f2861 f2862 f2863 f2865 f2866 f2867 f2869 f2870 f2871 f2877 f2878 f2879 f2887 f2888 f2889 f2891 f2892 f2741 f2742 f521;
local r5al g306 g56 g3158 g3059 g3060 g3175 g3176 g3177 g3179 g3180 g3181 g3183 g3184 g3185 g3187 g3188 g3189 g3195 g3196 g3197 g3205 g3206 g3207 g3209 g3210 g562;
local r6al hh101 hh108 hh115-hh134 hx033 hz144 hz024 hh001 hh002 ha030;
local r7al jh101 jh108 jh115-jh134 jx033 jz144 jz024 jh001 jh002 ja030;
local r8al kh101 kh108 kh115-kh134 kx033 kz024 kh001 kh002 ka030;
local r9al lh101 lh108 lh115-lh134 lx033 lz024 lh001 lh002 la030;
local r10al MH101 MH108 MH115-MH134 MX033 MZ024 MH001 MH002 MA030;
local r11al nh101 nh108 nh115-nh134 nx033 nz024 nh001 nh002 na030;
local r12al oh101 oh108 oh115-oh134 ox033 oz024 oh001 oh002 oa030;

/* Heart Attack */;
local r1heartat v406 v407 v408 v409 v410 v414 v245 ;
local ahd1heartat b244 b242 b245;
local r2heartat   w367 w369 w371 w372 w376 ;
local ahd2heartat d828 d829 d830 d834 d836 d837 d840 d841 d842 ;
local r3heartat   e828 e829 e830 e834 e836 e837 e840 e841 e842 e96 e95 e99 e22_1 e393 e391;
local r4heartat   f1156 f1157 f1158 f1162 f1164 f1165 f1168 f1169 f1170 f26_1 f219 f218 f699 f697;
local r5heartat   g1289 g1290 g1291 g1295 g1297 g1298 g1301 g1302 g1303 g26_1 gprviwyr	gprviwmo giwyear giwmonth;
local r6heartat   hc036 hc037 hc038 hc040 hc041 hc042 hc045 hc046 hc047 hz093 hz092 hz076 ha501 ha500;
local r7heartat   jc036 jc037 jc038 jc040 jc041 jc042 jc045 jc046 jc047 jz093 jz092 jz076 ja501 ja500;
local r8heartat   kc036 kc037 kc038 kc040 kc041 kc042 kc045 kc046 kc047 kz093 kz092 kz076 ka501 ka500;
local r9heartat   lc036 lc037 lc038 lc040 lc041 lc042 lc045 lc046 lc047 lz093 lz092 lz076 la501 la500;
local r10heartat  MC036 MC037 MC038 MC257 MC258 MC259 MC274 MC275 MC276 MC277 MC040 MC041 MC042 MC260 MC261 MC262 MC045 MC046 MC047 MC264 MC265 MC266 MC269 MC049 MA500 MA501 MZ255 MZ093 MZ076 MZ092; 
local r11heartat  nc036 nc037 nc038 nc257 nc258 nc259 nc274 nc275 nc276 nc277 nc040 nc041 nc042 nc260 nc261 nc262 nc045 nc046 nc047 nc264 nc265 nc266 nc269 nc049 na500 na501 nz255 nz093 nz076 nz092;
local r12heartat  oc036 oc037 oc038 oc257 oc258 oc259 oc274 oc275 oc276 oc277 oc040 oc041 oc042 oc260 oc261 oc045 oc046 oc264 oc049 oa500 oa501 oc266 oc269 oz093 oz255 oz076 oz092;

/*Treament - any drugs, cholesterol, hyptertension, diabetes*/;

local r4treatment f1110 f1117;
local r5treatment g2622 g1239 g1248;
local r6treatment hn175 hc006 hc011;
local r7treatment jn175 jc006 jc011;
local r8treatment kn175 kn360 kc006 kc011;
local r9treatment ln175 ln360 lc006 lc011;
local r10treatment MN175 MN360 MC006 MC011;
local r11treatment nn175 nn360 nc006 nc011;
local r12treatment on175 on360 oc006 oc011;


  local hrs1fat
v329
v336
v338
v339
v408
v411
v440
v441
v442
v504
v6602
v6604
`r1heartat'
;

local ahd1fat
b1838
b224
b292
`ahd1heartat'
;

local hrs2fat
w338
w341
w342
w352
w370
w373
w437
w438
w6700
w6701
w6702
w6703
w6704
`r2heartat'
;

local ahd2fat
d5155
d5158
d784
d790
d807
d813
d814
d824
d838
d839
d843
d911
d912
d913
`ahd2heartat'
;

local wave3fat
e1737
e1739
e1740
e2169
e2172
e5135
e5136
e5648
e784
e790
e807
e813
e814
e824
e838
e839
e843
e911
e912
e913
`r3heartat'
;

local wave4fat
f1112
f1118
f1135
f1141
f1142
f1152
f1166 
f1167
f1171
f1239
f1241
f1278
f1279
f1280
f1764
f2244
f2246
f2247
f2677
f2678
f2681
f5868
f5869
f992
`r4al'
`r4alcohol'
`r4grocery'
`r4meals'
`r4medication'
`r4phone'
`r4heartat'
`r4treatment'
;

local wave5fat
g1980
g2995
g2996
g2999
g2495
g2497
g2498
g1241
g1249
g1285
g1411
g1412
g1413
g1299
g1300 
g1304
g1238
g1268
g1274
g1275
g1079
g1372
g1374
g6241
g6242
`r5al'
`r5alcohol'
`r5grocery'
`r5meals'
`r5medication'
`r5phone'
`r5heartat'
`r5treatment'
;

local wave6fat
hb019
hc008
hc012
hc017
hc025
hc028
hc029
hc033
hc043
hc044 
hc048
hc104
hc105
hc125
hc126
hc127
he012
hf175
hf176
hf177
hg086
hg087
hg092
hn005
hn006
`r6al'
`r6alcohol'
`r6grocery'
`r6meals'
`r6medication'
`r6phone'
`r6heartat'
`r6treatment'
;

local wave7fat
jb019
jc008
jc012
jc017
jc028
jc029
jc033
jc043 
jc044
jc048
jc104
jc105
jc125
jc126
jc127
jc214
je012
jf175
jf176
jf177
jg086
jg195
jg196
jg197
jg198
jg199
jg200
jg201
jlb504*
jlb508*
jlb509
jlb511*
jlb512*
jlb513
jlb515* 
jlb516*
jlb517
jlb519*
jlb520*
jlb521
jn005
jn006
jz204
`r7al'
`r7alcohol'
`r7grocery'
`r7meals'
`r7medication'
`r7phone'
`r7heartat'
`r7treatment'
;

local wave8fat
kb019
kc008
kc012
kc017
kc028
kc029
kc033
kc043
kc044 
kc048
kc104
kc105
kc125
kc126
kc127
kc214
ke012
kf175
klb018
klb020*
kn005
kn006
kz204
`r8al'
`r8alcohol'
`r8grocery'
`r8meals'
`r8medication'
`r8phone'
`r8heartat'
`r8treatment'
;

local wave9fat
lb000
lb019
lc008
lc012
lc017
lc028
lc029
lc033
lc043
lc044 
lc048
lc104
lc105
lc125
lc126
lc127
lc214
le012
lf175
llb018
llb020*
ln005
ln006
lz204
`r9al'
`r9alcohol'
`r9grocery'
`r9meals'
`r9medication'
`r9phone'
`r9heartat'
`r9treatment'
;

local wave10fat
MB000
MB019
MC008
MC012
MC017
MC028
MC029
MC033
MC043 
MC044
MC048
MC104
MC105
MC125
MC126
MC127
MC214
MC263
MC272
MC273
ME012
MF175
MN005
MN006
MZ204
`r10al'
`r10alcohol'
`r10grocery'
`r10meals'
`r10medication'
`r10phone'
`r10heartat'
`r10treatment'
;

local wave11fat
nb000
nb019
nc008
nc012
nc017
nc028
nc029
nc033
nc043
nc044 
nc048
nc104
nc105
nc125
nc126
nc127
nc214
nc263
nc272
nc273
ne012
nf175
nlb018
nlb020*
nn005
nn006
nz204
`r11al'
`r11alcohol'
`r11grocery'
`r11meals'
`r11medication'
`r11phone'
`r11heartat'
`r11treatment'
;

local wave12fat
ob000
ob019
oc012
oc028
oc029
oc033
oc043
oc044
oc048
oc104
oc105
oc125
oc126
oc127
oc214
oc263
oc272
oc273
oe012
of175
olb017
olb019*
on005
on006
oz204
`r12al'
`r12alcohol'
`r12grocery'
`r12meals'
`r12medication'
`r12phone'
`r12heartat'
`r12treatment'
;
