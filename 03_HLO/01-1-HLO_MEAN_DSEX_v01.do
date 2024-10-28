*Author: Syedah Aroob Iqbal

/*****************************************************************
This do file :
-	Harmonizes all country level means to HLO units
*****************************************************************/

global master_seed  10051990
set seed 10051990 
set sortseed 10051990   // Ensures reproducibility


use "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta", clear
*Merging with exchange rates to develop harmonized scores:
gen level = "pri" if inlist(grade,"2","2-4","3","4","5","6")
replace level = "sec" if missing(level)
gen assessment = test 
merge m:1 assessment level subject using "$clone/02_exchangerate/output/exchange_rates.dta", assert(master match using) keep(master match)
replace exchangerate = 1 if _merge == 1
drop _merge

*Generating HLOs:
gen HLO = score * exchangerate
gen HLO_m = score_m * exchangerate
gen HLO_f = score_f * exchangerate

*cf _all using "$clone\03_HLO\output\HLO_MEANS_DSEX_v01.dta", verbose
save "$clone\03_HLO\output\HLO_MEANS_DSEX_v01.dta", replace





