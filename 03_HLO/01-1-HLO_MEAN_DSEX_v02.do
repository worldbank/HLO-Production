*Author: Syedah Aroob Iqbal

/*****************************************************************
This do file :
-	Harmonizes all country level means to HLO units
*****************************************************************/

global master_seed  10051990
set seed 10051990 
set sortseed 10051990   // Ensures reproducibility


use "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_P_L.dta", clear
*Merging with exchange rates to develop harmonized scores:
gen level = "pri" if inlist(grade,"2","2-4","3","4","5","6")
replace level = "sec" if missing(level)
replace test = "PASEC_2014" if test == "PASEC" & year == 2019
gen assessment = test 
merge m:1 assessment level subject using "$clone/02_exchangerate/output/exchange_rates.dta", assert(master match using) keep(master match)
replace exchangerate = 1 if _merge == 1
drop _merge

*Generating HLOs:
gen HLO = score * exchangerate
gen HLO_m = score_m * exchangerate
gen HLO_f = score_f * exchangerate

replace test = "PASEC" if inlist(test,"PASEC_2014")

cf _all using "$clone\03_HLO\output\HLO_MEANS_DSEX_v01_2022_updated_P_L.dta", verbose
save "$clone\03_HLO\output\HLO_MEANS_DSEX_v01_2022_updated_P_L.dta", replace

/*
*Checking PASEC scores
keep if test == "PASEC" 
keep HLO* score* cntabb test grade subject year
reshape wide HLO* score*, i(cntabb test grade subject) j(year)
graph hbar HLO2014 HLO2019, over(cntabb)
graph dot HLO2014 HLO2019 score2014 score2019, over(cntabb)

*Checking with previous HLO file:
use "$clone\03_HLO\output\HLO_MEANS_DSEX_v01_2022_updated_P.dta", replace
*Checking with previous:
ren HLO* n_HLO*
merge 1:1 cntabb test year n_res subject grade using "N:\GDB\WorldBank_HLO_workingcopy\HLO\HLO_v01\2-output\HLO_MEAN_DSEX_SE_v01.dta", keep(match)
gen diff = n_HLO - HLO
encode test, gen(test_n)
encode subject, gen(subject_n)
mean diff, over(test_n)
mean diff if test == "LLECE", over(test_n subject_n)
mean diff_se, over(test_n)





