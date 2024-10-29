*Jordan

set seed 10051990
set sortseed 10051990

use "${path}/CNT/JOR/JOR_2012_EGRA/JOR_2012_EGRA_v01_M/Data/Stata/2012.dta", clear
*Data is weighted
ren student_no id
*3 word problems:
ren word_probscore word_prob_score
ren sublvl1* sub*
ren addlvl1* add*
ren sublvl2* we_sub*
ren addlvl2* we_add*
label define language 11 "Arabic"
label values language language
*Letter sound variables incorrecly named as letter name variables:
rename (letter_score letter_attempted letter_attempted_pcnt) (letter_sound_score letter_sound_attempted letter_sound_attempted_pcnt)
keep country year month date region reg_schgen2 district school_code fpc1 class_id teacher_id fpc2 id grade female age *start_time *end_time language clspm cnonwpm orf cnumidpm cmissnumpm cqcpm caddpm1 caddpm2 csubpm1 csubpm2 letter_sound_score letter_sound_attempted letter_sound_attempted_pcnt letter_sound_score_pcnt letter_sound_score_zero invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt wt_final s34 s37_01 s37_02 s37_03 s37_04 s37_05 s37_06 s37_07 s37_08 s37_09 s37_10 s37_11 s37_12 s37_13 s37_14 s37_15 s37_16 s37_17 s37_18

foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 1
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
drop language
gen language = "Arabic"
gen s_res = 1
gen lang_instr = "Arabic"
*Identifying variables:
*s34 s37_01 s37_02 s37_03 s37_04 s37_05 s37_06 s37_07 s37_08 s37_09 s37_10 s37_11 s37_12 s37_13 s37_14 s37_15 s37_16 s37_17 s37_18
foreach var of varlist s34 s37_01 s37_02 s37_03 s37_04 s37_05 s37_06 s37_07 s37_08 s37_09 s37_10 s37_11 s37_12 s37_13 s37_14 s37_15 s37_16 s37_17 s37_18 {
	tab `var'
}
*Missings:
mdesc s34 s37_01 s37_02 s37_03 s37_04 s37_05 s37_06 s37_07 s37_08 s37_09 s37_10 s37_11 s37_12 s37_13 s37_14 s37_15 s37_16 s37_17 s37_18
foreach var of varlist s34 s37_01 s37_02 s37_03 s37_04 s37_05 s37_06 s37_07 s37_08 s37_09 s37_10 s37_11 s37_12 s37_13 s37_14 s37_15 s37_16 s37_17 s37_18 {
	replace `var' = . if `var' == 9
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
alphawgt s34_std s37_01_std s37_02_std s37_03_std s37_04_std s37_05_std s37_06_std s37_07_std s37_08_std s37_09_std s37_10_std s37_11_std s37_12_std s37_13_std s37_14_std s37_15_std s37_16_std s37_17_std s37_18_std [weight = wt_final], detail item gen(HOMEPOS)
*Very low alphavalue.
replace country = "Jordan"
gen cntabb = "JOR"
gen idcntry = 400

*Keeping weight variables:
gen strata1 = reg_schgen2
gen su1 = school_code
gen strata2 = class_id
gen su2 = teacher_id


save "${path}/CNT/JOR/JOR_2012_EGRA/JOR_2012_EGRA_v01_M_v01_A_BASE/JOR_2012_EGRA_v01_M_v01_A_BASE.dta", replace
codebook, compact
cf _all using "${path}/CNT/JOR/JOR_2012_EGRA/JOR_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/JOR/JOR_2012_EGRA/JOR_2012_EGRA_v01_M_v01_A_HAD.dta", replace



