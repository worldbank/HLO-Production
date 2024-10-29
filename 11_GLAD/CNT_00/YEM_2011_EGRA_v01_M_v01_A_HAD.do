* Yemen

set seed 10051990
set sortseed 10051990

use "${path}/CNT/YEM/YEM_2011_EGRA/YEM_2011_EGRA_v01_M/Data/Stata/2011.dta", clear

keep country year region_type region school_code id wt_final fpc* grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero exit_interview34 exit_interview37_01 exit_interview37_02 exit_interview37_03 exit_interview37_04 exit_interview37_05 exit_interview37_06 exit_interview37_07 exit_interview37_08 exit_interview37_09 exit_interview37_10 exit_interview38_1 exit_interview38_2 exit_interview38_3 exit_interview38_4
gen w = 1
gen n_res = 1
gen r_res = 1
replace oral_read_score_pcnt = oral_read_score_pcnt*100
replace read_comp_score_pcnt = read_comp_score_pcnt*100
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = language
replace country = "Yemen"
gen cntabb = "YEM"
gen idcntry = 887

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interview34 exit_interview37_01 exit_interview37_02 exit_interview37_03 exit_interview37_04 exit_interview37_05 exit_interview37_06 exit_interview37_07 exit_interview37_08 exit_interview37_09 exit_interview37_10 exit_interview38_1 exit_interview38_2 exit_interview38_3 exit_interview38_4
numlabel, add
foreach var of varlist exit_interview34 exit_interview37_01 exit_interview37_02 exit_interview37_03 exit_interview37_04 exit_interview37_05 exit_interview37_06 exit_interview37_07 exit_interview37_08 exit_interview37_09 exit_interview37_10 exit_interview38_1 exit_interview38_2 exit_interview38_3 exit_interview38_4 {
	tab `var'
	replace `var' = . if `var' == 888
}
mdesc exit_interview34 exit_interview37_01 exit_interview37_02 exit_interview37_03 exit_interview37_04 exit_interview37_05 exit_interview37_06 exit_interview37_07 exit_interview37_08 exit_interview37_09 exit_interview37_10 exit_interview38_1 exit_interview38_2 exit_interview38_3 exit_interview38_4
foreach var of varlist exit_interview34 exit_interview37_01 exit_interview37_02 exit_interview37_03 exit_interview37_04 exit_interview37_05 exit_interview37_06 exit_interview37_07 exit_interview37_08 exit_interview37_09 exit_interview37_10 exit_interview38_1 exit_interview38_2 exit_interview38_3 exit_interview38_4 {
	bysort region school_code : egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')

	egen `var'_mean_cnt = mean(`var')
	
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean if missing(`var') & `var'_count > 10 & !missing(`var'_count)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
*All households have pit latrine. Drop pit latrine.
alphawgt exit_interview34_std exit_interview37_01_std exit_interview37_02_std exit_interview37_03_std exit_interview37_04_std exit_interview37_05_std exit_interview37_06_std exit_interview37_07_std exit_interview37_08_std exit_interview37_09_std exit_interview37_10_std exit_interview38_1_std exit_interview38_2_std exit_interview38_3_std exit_interview38_4_std [weight = wt_final], detail item
pca exit_interview34_std exit_interview37_01_std exit_interview37_03_std exit_interview37_04_std exit_interview37_05_std exit_interview37_06_std exit_interview37_07_std exit_interview37_08_std exit_interview37_09_std exit_interview37_10_std exit_interview38_1_std exit_interview38_2_std exit_interview38_3_std exit_interview38_4_std [weight = wt_final]
predict ESCS

*Generating Asset Variable:
gen books_yn = exit_interview34
gen television_yn = exit_interview37_01
gen toilet_yn = 1 if (exit_interview37_03 == 1 | exit_interview37_04 == 1)
replace toilet_yn = 0 if (exit_interview37_03 == 0 | exit_interview37_04 == 0)
gen air_conditioner_yn = exit_interview37_05
gen electricity_yn = exit_interview37_06
gen computer_yn = exit_interview37_07
gen kitchen_yn = exit_interview37_08
gen coal_yn = exit_interview37_09
gen gas_electric_stove_yn = exit_interview37_10
gen river_stream_yn = exit_interview38_1
gen tank_watertruck_yn = 1 if (exit_interview38_2 == 1 | exit_interview38_4 == 1)
replace tank_watertruck_yn = 0 if (exit_interview38_2 == 0 & exit_interview38_4 == 0)
gen tap_in_home_compound_yn = exit_interview38_3

*Weight variables:
gen strata1 = region_type
gen su1 = region
gen su2 = school_code
gen strata3 = grade
gen su3 = id



save "${path}/CNT/YEM/YEM_2011_EGRA/YEM_2011_EGRA_v01_M_v01_A_BASE/YEM_2011_EGRA_v01_M_v01_A_BASE.dta", replace


keep country cntabb idcntry w n_res r_res lang_instr year  school_code id wt_final strata* su* fpc* grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero *_yn
codebook, compact
cf _all using "${path}/CNT/YEM/YEM_2011_EGRA/YEM_2011_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}/CNT/YEM/YEM_2011_EGRA/YEM_2011_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}/CNT/YEM/YEM_2011_EGRA/YEM_2011_EGRA_v01_M_v01_A_HAD.dta", replace
