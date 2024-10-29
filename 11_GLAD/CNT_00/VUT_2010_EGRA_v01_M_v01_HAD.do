* Vanuatu

set seed 10051990
set sortseed 10051990

use "${path}/CNT/VUT/VUT_2010_EGRA/VUT_2010_EGRA_v01_M/Data/Stata/2010.dta", clear

drop if missing(language)
*Data is not svyset.
decode school_langue, gen(lang_instr)
decode language, gen(language_s)
drop language
ren language_s language
*Constructing variables of interest:
replace orf = 0 if missing(orf)
replace reading_score = 0 if missing(reading_score)
gen oral_read_score_pcnt = (reading_score/59)*100
gen oral_read_score_zero = (reading_score == 0)
gen read_comp_score_zero = (read_comp_score == 0)
replace read_comp_score_pcnt = read_comp_score_pcnt*100
keep country region district year school_code school_type lang_instr id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero question18 question19 question20 question21 question22 question23 question24 question25 
gen w = 0
gen n_res = 1
gen r_res = 1
gen s_res = 1
encode id, gen(id_n)
drop id
ren id_n id
replace country = "Vanuatu"
gen cntabb = "VUT"
gen idcntry = 548
*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*question18 question19 question20 question21 question22 question23 question24 question25
numlabel, add
foreach var of varlist question18 question19 question20 question21 question22 question23 question24 question25 {
	tab `var'
	replace `var' = . if inlist(`var',9,99)
}
*Missings:
mdesc question18 question19 question20 question21 question22 question23 question24 question25
*question 25 has around 50% missing. dropped.
*Filling missings:
foreach var of varlist question18 question19 question20 question21 question22 question23 question24 {
	bysort region district school_code: egen `var'_mean = mean(`var')
	bysort region district school_code: egen `var'_count = count(`var')
	bysort region district : egen `var'_mean_d = mean(`var')
	bysort region district : egen `var'_count_d = count(`var')
	bysort region: egen `var'_mean_reg = mean(`var')
	bysort region: egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_d if missing(`var') & `var'_count_d > 7 & !missing(`var'_count_d)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt question18_std question19_std question20_std question21_std question22_std question23_std question24_std , detail item
pca question18_std question19_std question20_std question21_std question22_std question23_std question24_std 
predict ESCS

/*Generating Assets Variables:
gen radio_yn = question18
gen telephone_yn = question19
gen electricity_yn = question20
gen television_yn = question21
gen video_dvd_player_yn = question22
gen canoe_yn = question23
gen engine_boat_yn = question24
*/


save "${path}/CNT/VUT/VUT_2010_EGRA/VUT_2010_EGRA_v01_M_v01_A_BASE/VUT_2010_EGRA_v01_M_v01_A_BASE.dta", replace
keep  country  cntabb idcntry w n_res r_res s_res region year school_code lang_instr id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero 
cf _all using "${path}/CNT/VUT/VUT_2010_EGRA/VUT_2010_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}/CNT/VUT/VUT_2010_EGRA/VUT_2010_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated0
save "${path}/CNT/VUT/VUT_2010_EGRA/VUT_2010_EGRA_v01_M_v01_A_HAD.dta", replace

