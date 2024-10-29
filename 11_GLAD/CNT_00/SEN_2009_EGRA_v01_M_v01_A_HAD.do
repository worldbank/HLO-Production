* Senegal
set seed 10051990
set sortseed 10051990

use "${path}/CNT/SEN/SEN_2009_EGRA/SEN_2009_EGRA_v01_M/Data/Stata/2009.dta", clear

*Data svyset but school_code not available
drop if consent == 0
gen w = 0
*Variables requested by Nadir:
ren jardin_enfant_new tppri
keep w country year region district id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tppri exit_interview6 exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18

foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
replace orf = 0 if missing(orf)
replace oral_read_score_pcnt = 0 if missing(oral_read_score_pcnt)
replace oral_read_score_zero = 1 if missing(oral_read_score_zero)
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt)
replace read_comp_score_zero = 1 if missing(read_comp_score_pcnt)
gen n_res = 1
gen r_res = 1
decode language, gen(language_s)
drop language
ren language_s language
decode region, gen(region_s)
drop region
ren region_s region
gen lang_instr = "French"
gen cntabb = "SEN"
gen idcntry = 686

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interview6 exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18
numlabel, add
foreach var of varlist exit_interview6 exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 {
	tab `var'
	replace `var' = . if `var' == 9
}
mdesc exit_interview6 exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18
foreach var of varlist exit_interview6 exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 {
	bysort region district : egen `var'_mean = mean(`var')
	bysort region district : egen `var'_count = count(`var')
	bysort region: egen `var'_mean_reg = mean(`var')
	bysort region: egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview6_std exit_interview10_std exit_interview11_std exit_interview12_std exit_interview13_std exit_interview14_std exit_interview15_std exit_interview16_std exit_interview17_std exit_interview18_std, detail item

pca exit_interview6_std exit_interview10_std exit_interview11_std exit_interview12_std exit_interview13_std exit_interview14_std exit_interview15_std exit_interview16_std exit_interview17_std exit_interview18_std
predict ESCS

*Generating Asset Variables:
gen books_yn = exit_interview6
gen radio_yn = exit_interview10
gen telephone_yn = exit_interview11
gen electricity_yn = exit_interview12
gen television_yn = exit_interview13
gen fridge_yn = exit_interview14
gen tap_in_home_compound_yn = exit_interview15
gen bicycle_yn = exit_interview16
gen motorcycle_yn = exit_interview17
gen four_wheeler_yn = exit_interview18

save "${path}/CNT/SEN/SEN_2009_EGRA/SEN_2009_EGRA_v01_M_v01_A_BASE/SEN_2009_EGRA_v01_M_v01_A_BASE.dta", replace

keep w country cntabb idcntry n_res r_res year region district id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tppri *_yn

codebook, compact
cf _all using "${path}/CNT/SEN/SEN_2009_EGRA/SEN_2009_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/SEN/SEN_2009_EGRA/SEN_2009_EGRA_v01_M_v01_A_HAD.dta", replace
