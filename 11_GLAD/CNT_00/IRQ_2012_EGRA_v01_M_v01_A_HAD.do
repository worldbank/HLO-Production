*Iraq
set seed 10051990
set sortseed 10051990

use "${path}/CNT/IRQ/IRQ_2012_EGRA/IRQ_2012_EGRA_v01_M/Data/Stata/2012.dta", clear

*Data is weighted
*Variables asked by Nadir are not available
ren student_no id
*3 word problems:
ren word_probscore word_prob_score
ren sublvl1* sub*
ren addlvl1* add*
ren sublvl2* we_sub*
ren addlvl2* we_add*
ren wt_final wt_final
svyset school_code [pweight = wt_final], fpc(fpc1) strata(province) || teacher_id , fpc(fpc2) strata(class_id) || _n, fpc(fpc3)  singleunit(scaled)
keep country year month date province region district school_code fpc* class_id teacher_id id grade female age *start_time *end_time  language clspm cnonwpm orf cnumidpm cmissnumpm cqcpm caddpm1 caddpm2 csubpm1 csubpm2 letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt wt_final* s36 s39_1 s39_2 s39_3 s39_4 s39_5 s39_6 s39_7 s39_9 s39_10 s39_11 s39_12 s39_13 s39_14 s39_15 s39_16 s39_17
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
drop language
gen language = "Arabic"
gen s_res = 1
gen lang_instr = "Arabic"
*Identifying variables for ESCS
*s36 s39_1 s39_2 s39_3 s39_4 s39_5 s39_6 s39_7 s39_9 s39_10 s39_11 s39_12 s39_13 s39_14 s39_15 s39_16 s39_17
foreach var of varlist s36 s39_1 s39_2 s39_3 s39_4 s39_5 s39_6 s39_7 s39_9 s39_10 s39_11 s39_12 s39_13 s39_14 s39_15 s39_16 s39_17 {
	tab `var'
}
*missing:
mdesc s36 s39_1 s39_2 s39_3 s39_4 s39_5 s39_6 s39_7 s39_9 s39_10 s39_11 s39_12 s39_13 s39_14 s39_15 s39_16 s39_17
foreach var of varlist s36 s39_1 s39_2 s39_3 s39_4 s39_5 s39_6 s39_7 s39_9 s39_10 s39_11 s39_12 s39_13 s39_14 s39_15 s39_16 s39_17 {
	replace `var' = . if `var' == 9
	bysort region district school_code: egen `var'_mean = mean(`var')
	bysort region district school_code: egen `var'_count = count(`var')
	bysort region district : egen `var'_mean_d = mean(`var')
	bysort region district : egen `var'_count_d = count(`var')
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_d if missing(`var') & `var'_count_d > 7 & !missing(`var'_count_d)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt s36_std s39_1_std s39_2_std s39_3_std s39_4_std s39_5_std s39_6_std s39_7_std s39_9_std s39_10_std s39_11_std s39_12_std s39_13_std s39_14_std s39_15_std s39_16_std s39_17_std [weight = wt_final_2], detail item 
pca s36_std s39_1_std s39_2_std s39_3_std s39_4_std s39_5_std s39_6_std s39_7_std s39_9_std s39_10_std s39_11_std s39_12_std s39_13_std s39_14_std s39_15_std s39_16_std s39_17_std [weight = wt_final_2]
predict ESCS
replace country = "Iraq"
gen cntabb = "IRQ"
gen idcntry = 368

*Generating Asset Variables:

gen books_yn = s36
gen radio_yn = s39_1
gen television_yn = s39_2
gen bicycle_yn = s39_3
gen vehicle_yn = s39_4
gen computer_yn = s39_5
gen toilet_yn = 1 if (s39_6 == 1 | s39_7 == 1)
replace toilet_yn = 0 if (s39_6 == 0 & s39_7 == 0)
gen kitchen_yn = s39_9
gen coal_yn = s39_10
gen gas_electric_stove_yn = s39_11
gen river_stream_yn = s39_12
gen tank_watertruck_yn = 1 if (s39_13 == 1 | s39_16 == 1)
replace tank_watertruck_yn = 0 if (s39_13 == s39_16 == 0)
gen tap_in_home_compound_yn = 1 if ( s39_14 == 1 | s39_15 == 1)
replace tap_in_home_compound_yn = 0 if (s39_14 == s39_15 == 0)
gen well_borehole_yn = s39_17





save "${path}/CNT/IRQ/IRQ_2012_EGRA/IRQ_2012_EGRA_v01_M_v01_A_BASE/IRQ_2012_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res r_res w s_res language lang_instr year month date province region district school_code fpc* class_id teacher_id id grade female age *start_time *end_time  language clspm cnonwpm orf cnumidpm cmissnumpm cqcpm caddpm1 caddpm2 csubpm1 csubpm2 letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt wt_final* *_yn
codebook, compact
cf _all using "${path}/CNT/IRQ/IRQ_2012_EGRA/IRQ_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/IRQ/IRQ_2012_EGRA/IRQ_2012_EGRA_v01_M_v01_A_HAD.dta", replace



/*save "${gsdData}/0-RawOutput/Iraq_2012_s.dta", replace
replace country = "Iraq"
gen cntabb = "IRQ"
gen idcntry = 368
save "${gsdData}/0-RawOutput/merged/Iraq.dta", replace
