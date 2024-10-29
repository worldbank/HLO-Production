* Guyana
set seed 10051990
set sortseed 10051990

use "${path}\CNT\GUY\GUY_2008_EGRA\GUY_2008_EGRA_v01_M\Data\Stata\2008.dta", clear

*Data is svyset
keep country year zone region fpc* school_code id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero wt_final exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18
gen w = 1
gen n_res = 1
gen r_res = 1
gen s_res = 1
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
label define lyn 0 "no" 1 "Yes"
bysort id: gen id_n = _n
drop id
ren id_n id
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = "English"
replace country = "Guyana"
gen cntabb = "GUY"
gen idcntry = 328

*Identifying variables for socio-economic status:
*exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18
*Cleaning variables:
foreach var of varlist exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 {
	tab `var'
}
*Missing variables:
mdesc exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18
*Fillin missing:
foreach var of varlist exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 {
	bysort region school_code: egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview10_std exit_interview11_std exit_interview12_std exit_interview13_std exit_interview14_std exit_interview15_std exit_interview16_std exit_interview17_std exit_interview18_std [weight = wt_final], item detail std
pca exit_interview10_std exit_interview11_std exit_interview12_std exit_interview13_std exit_interview14_std exit_interview15_std exit_interview16_std exit_interview17_std exit_interview18_std [weight = wt_final]
predict ESCS

*Variables are not value labelled, and the scores are in opposite direction of ESCS
/*

*Labelling 
gen radio_yn = exit_interview10
gen telephone_yn = exit_interview11
gen electricity_yn = exit_interview12
gen television_yn = exit_interview13
gen fridge_yn = exit_interview14
gen toilet_yn = exit_interview15
gen bicycle_yn = exit_interview16
gen motorcycle_yn = exit_interview17
gen four_wheeler_yn = exit_interview18

*/
*Destring weight variables:
encode zone, gen(strata1)
gen su1 =  region
gen su2 = school_code
gen strata3 = grade
gen su3 = id



save "${path}\CNT\GUY\GUY_2008_EGRA\GUY_2008_EGRA_v01_M_v01_A_BASE\GUY_2008_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry zone w n_res r_res s_res  lang_instr year strata* su* fpc* school_code id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero wt_final

codebook, compact
cf _all using "${path}\CNT\GUY\GUY_2008_EGRA\GUY_2008_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\GUY\GUY_2008_EGRA\GUY_2008_EGRA_v01_M_v01_A_HAD.dta", replace





