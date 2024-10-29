** Laos

set seed 10051990
set sortseed 10051990

use "${path}/CNT/LAO/LAO_2012_EGRA/LAO_2012_EGRA_v01_M/Data/Stata/2012.dta", clear

*Developing variables of interest:
gen oral_read_score_zero = (orf == 0)
replace reading_score = 0 if missing(reading_score)
gen oral_read_score_pcnt = (reading_score/60)*100
gen read_comp_score_zero = (read_comp_score == 0)
*Renaming some variables:
keep country province district year school_code id female age grade language orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt question28 question29 question30 question31 question32 question33 question34 question35 question36 question37 question38 question39 question40 question41 question42 question43 question44 question45 question46
ren province region
replace read_comp_score_pcnt = read_comp_score_pcnt * 100
gen w = 0
gen n_res = 0
gen r_res = 1
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = language
destring school_code, replace
replace country = "Lao PDR"
gen cntabb = "LAO"
gen idcntry = 418


*Calculating ESCS:
*Identifying variables:
*question28 question29 question30 question31 question32 question33 question34 question35 question36 question37 question38 question39 question40 question41 question42 question43 question44 question45 question46
numlabel, add
foreach var of varlist question28 question29 question30 question31 question32 question33 question34 question35 question36 question37 question38 question39 question40 question41 question42 question43 question44 question45 question46 {
	tab `var'
	replace `var' = . if `var' == 9
}
mdesc question28 question29 question30 question31 question32 question33 question34 question35 question36 question37 question38 question39 question40 question41 question42 question43 question44 question45 question46

foreach var of varlist question28 question29 question30 question31 question32 question33 question34 question35 question36 question37 question38 question39 question40 question41 question42 question43 question44 question45 question46 {
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

alphawgt question28_std question29_std question30_std question31_std question32_std question33_std question34_std question35_std question36_std question37_std question38_std question39_std question40_std question41_std question42_std question43_std question44_std question45_std question46_std , detail item
pca question28_std question29_std question30_std question31_std question32_std question33_std question34_std question35_std question36_std question37_std question38_std question39_std question40_std question41_std question42_std question43_std question44_std question45_std question46_std 
predict ESCS

*Generating Asset Variables:
gen radio_yn = question28
gen telephone_yn = question29
gen mobile_yn = question30
gen television_yn = question31
gen bicycle_yn = question32
gen motorcycle_yn = question33
gen four_wheeler_yn = question34
gen clock_yn = question35
gen study_table_yn = question36
gen study_chair_yn = question37
gen study_lamp_yn = question38
gen books_yn = question39
gen wardrobe_yn = question40
gen fan_yn = question41
gen fridge_yn = question42
gen gas_electric_stove_yn = question43
gen washing_machine_yn = question44
gen computer_yn = question45
gen air_conditioner_yn = question46


save "${path}/CNT/LAO/LAO_2012_EGRA/LAO_2012_EGRA_v01_M_v01_A_BASE/LAO_2012_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry n_res r_res w language lang_instr region  year school_code id female age grade language orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt *_yn
cf _all using "${path}/CNT/LAO/LAO_2012_EGRA/LAO_2012_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}/CNT/LAO/LAO_2012_EGRA/LAO_2012_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}/CNT/LAO/LAO_2012_EGRA/LAO_2012_EGRA_v01_M_v01_A_HAD.dta", replace



