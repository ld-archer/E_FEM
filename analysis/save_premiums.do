#delimit;
use ../output/example_stock/example_stock_summary;

tsset year;
tsfill;
ipolate mcare_pta year, gen(pta);
ipolate mcare_ptb year, gen(ptb);

outsheet year pta using ../FEM_CPP_settings/timeseries/mcare_pta.txt, replace nolabel nonames;
outsheet year ptb using ../FEM_CPP_settings/timeseries/mcare_ptb.txt, replace nolabel nonames;
