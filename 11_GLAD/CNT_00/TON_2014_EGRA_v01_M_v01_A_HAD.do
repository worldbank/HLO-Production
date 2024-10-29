set seed 10051990
set sortseed 10051990

use "${path}/CNT/TON/TON_2014_EGRA/TON_2014_EGRA_v01_M/Data/Stata/2014.dta", clear
ren question3 tppri
*Developing variables of interest:
foreach var of varlist read_word?? {
	replace `var' = 0 if `var' == 9 | missing(`var')
}
egen oral_read_score = rowtotal(read_word??)
gen oral_read_score_pcnt = (oral_read_score/60)*100
gen oral_read_score_zero = (orf == 0)
gen read_comp_score_zero = (oral_read_score == 0)
keep country year id grade female region age tppri orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
gen n_res = 1
gen s_res = 1
gen r_res = 0
gen w = 0
drop if grade == 99
gen lang_instr = "Tongan"
gen language = "Tongan"
*Standardizing read_comp_score_pcnt:
replace read_comp_score_pcnt = read_comp_score_pcnt*100
encode id , gen (id_n)
drop id
ren id_n id
replace female = . if female == 99
replace country = "Tonga"
gen cntabb = "TON"
gen idcntry = 776
*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*No variables for ESCS
codebook, compact
cf _all using "${path}\CNT\TON\TON_2014_EGRA\TON_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\TON\TON_2014_EGRA\TON_2014_EGRA_v01_M_v01_A_HAD.dta", replace

