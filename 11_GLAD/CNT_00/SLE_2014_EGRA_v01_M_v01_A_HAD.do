

* Sierra Leone

set seed 10051990
set sortseed 10051990


import excel "${path}/CNT\SLE\SLE_2014_EGRA\SLE_2014_EGRA_v01_M\Data/Original\2014.xlsx", clear firstrow
keep country year school_code id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
drop if missing(orf)
gen n_res = 1
gen r_res = 0
gen w= 0 
replace oral_read_score_pcnt = oral_read_score_pcnt*100
replace read_comp_score_pcnt = read_comp_score_pcnt*100
drop year
gen year = 2014
drop language
gen language = "English"
gen lang_instr = "English"
replace country = "Sierra Leone"
gen cntabb = "SLE"
gen idcntry = 694

codebook, compact
cf _all using "${path}/CNT/SLE/SLE_2014_EGRA/SLE_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/SLE/SLE_2014_EGRA/SLE_2014_EGRA_v01_M_v01_A_HAD.dta", replace

