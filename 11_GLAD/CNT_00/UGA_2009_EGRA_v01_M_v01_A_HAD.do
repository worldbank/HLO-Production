* Uganda
set seed 10051990
set sortseed 10051990

use "${path}/CNT/UGA/UGA_2009_EGRA/UGA_2009_EGRA_v01_M/Data/Stata/2009.dta", clear

*The data is svyset.
gen grade = 3 if class == 2
replace grade = 2 if class == 1
keep country year region district emis id female age grade e_language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero r_exit_interviews11 r_orf r_read_comp_score_zero r_read_comp_score_pcnt r_oral_read_score_pcnt r_oral_read_score_zero strata* fpc* wt_final exit_interviews2 exit_interviews3 exit_interviews4 exit_interviews5 exit_interviews6 exit_interviews7 exit_interviews8 exit_interviews9 exit_interviews10 exit_interviews15 exit_interviews17 exit_interviews18

gen n_res = 0
gen r_res = 1
gen w = 1
replace orf = 0 if missing(orf)
replace oral_read_score_pcnt = 0 if missing(oral_read_score_pcnt)
replace oral_read_score_zero = 1 if missing(oral_read_score_zero)
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt)
replace read_comp_score_zero = 1 if missing(read_comp_score_zero)
replace oral_read_score_pcnt = oral_read_score_pcnt*100
replace read_comp_score_pcnt = read_comp_score_pcnt*100
decode region, gen (region_s)
drop region
ren region_s region
decode e_language, gen(language_s)
drop e_language
ren language_s language
gen lang_instr = language
replace year = 2009 if missing(year)
replace country = "Uganda"
gen cntabb = "UGA"
gen idcntry = 800

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interviews2 exit_interviews3 exit_interviews4 exit_interviews5 exit_interviews6 exit_interviews7 exit_interviews8 exit_interviews9 exit_interviews10 exit_interviews15 exit_interviews17 exit_interviews18
numlabel, add
foreach var of varlist exit_interviews2 exit_interviews3 exit_interviews4 exit_interviews5 exit_interviews6 exit_interviews7 exit_interviews8 exit_interviews9 exit_interviews10 exit_interviews15 exit_interviews17 exit_interviews18 {
	tab `var'
	replace `var' = . if inlist(`var',7,8,9)
}
*Missings:
mdesc exit_interviews2 exit_interviews3 exit_interviews4 exit_interviews5 exit_interviews6 exit_interviews7 exit_interviews8 exit_interviews9 exit_interviews10 exit_interviews15 exit_interviews17 exit_interviews18
*High missing values.
drop  exit_interviews2 exit_interviews3 exit_interviews4 exit_interviews5 exit_interviews6 exit_interviews7 exit_interviews8 exit_interviews9 exit_interviews10 exit_interviews15 exit_interviews17 exit_interviews18

codebook, compact
cf _all using "${path}/CNT/UGA/UGA_2009_EGRA/UGA_2009_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/UGA/UGA_2009_EGRA/UGA_2009_EGRA_v01_M_v01_A_HAD.dta", replace


