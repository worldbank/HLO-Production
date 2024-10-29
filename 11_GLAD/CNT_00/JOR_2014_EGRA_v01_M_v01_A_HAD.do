set seed 10051990
set sortseed 10051990


use "${path}/CNT/JOR/JOR_2014_EGRA/JOR_2014_EGRA_v01_M/Data/Stata/2014.dta", clear
*Data is weighted
ren wt_stage3 wt_final
replace language = "11"
destring language, replace
label define language 11 "Arabic"
label values language language
destring school_code, replace
destring id, replace
destring stage1, replace
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2 , fpc(fpc2) strata(strata2) || stage3, fpc(fpc3) strata(strata3) singleunit(scaled)
keep country year month date region district school_code strata* stage* fpc*  id grade female age *start_time *end_time  language clspm csspm cnonwpm orf cnumidpm caddpm csubpm letter_sound_score letter_sound_attempted letter_sound_attempted_pcnt letter_sound_score_pcnt letter_sound_score_zero syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt  we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt wt_final s25 s30_1 s30_2 s30_3 s30_4 s30_5 s30_6 s30_7 s30_8 s39 s40 s41
gen n_res = 1
gen r_res = 1
gen w = 1
*
decode region, gen(region_s)
drop region
ren region_s region
drop language
gen language = "Arabic"
gen s_res = 1
gen lang_instr = "Arabic"
*Identifying variables:
*s25 s30_1 s30_2 s30_3 s30_4 s30_5 s30_6 s30_7 s30_8 s39 s40 s41
foreach var of varlist s25 s30_1 s30_2 s30_3 s30_4 s30_5 s30_6 s30_7 s30_8 s39 s40 s41 {
	tab `var'
	replace `var' = . if inlist(`var',888,6)
}
*Creating dummies for categorical variables:
foreach var of varlist s39 s40 s41 {
	tab `var', gen(`var'_d)
}
*Missings:
mdesc s25 s30_1 s30_2 s30_3 s30_4 s30_5 s30_6 s30_7 s30_8 s39_d* s40_d* s41_d*
*s25 has 73%missing values. Dropped
foreach var of varlist s30_1 s30_2 s30_3 s30_4 s30_5 s30_6 s30_7 s30_8 s39_d* s40_d* s41_d* {
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
alphawgt s30_1_std s30_2_std s30_3_std s30_4_std s30_5_std s30_6_std s30_7_std s30_8_std s39_d*_std s40_d*_std s41_d*_std [weight = wt_final], detail item gen(HOMEPOS)
pca s30_1_std s30_2_std s30_3_std s30_4_std s30_5_std s30_6_std s30_7_std s30_8_std s39_d*_std s40_d*_std s41_d*_std [weight = wt_final]
predict ESCS
replace country = "Jordan"
gen cntabb = "JOR"
gen idcntry = 400
/*
*Generating Asset Variables:
*desc s30_1_std s30_2_std s30_3_std s30_4_std s30_5_std s30_6_std s30_7_std s30_8_std s39_d*_std s40_d*_std s41_d*_std
gen radio_yn =  s30_1
gen television_yn =  s30_2
gen bicycle_yn =  s30_3
gen vehicle_yn =  s30_4
gen computer_yn =  s30_5
gen air_conditioner_yn =  s30_6
gen water_cooler_yn =  s30_7
gen microwave_yn =  s30_8
gen river_stream_yn =  s39_d1
gen well_borehole_yn =  s39_d2
gen tap_communal_yn =  s39_d3
gen tap_in_home_compound_yn =  s39_d4
gen tank_watertruck_yn = s39_d5
gen firewood_yn = s40_d1
gen coal_yn = s40_d2
gen kerosene_yn = s40_d3
gen gas_electric_stove_yn = 1 if (s40_d4 == 1 & s40_d5 == 1)
replace gas_electric_stove_yn = 0 if (s40_d4 == 0 & s40_d5 == 0)
gen pit_toilet_yn = s41_d1 
gen toilet_yn = 1 if (s41_d2 == 1 | s41_d3 == 1)
replace toilet_yn = 0 if (s41_d2 == 0 | s41_d3 == 0)
*/
*Trend with ESCS not coming correct.
*weight variables:
ren stage* su*
encode su2, gen(su2_n)
drop su2
ren su2_n su2

save "${path}/CNT/JOR/JOR_2014_EGRA/JOR_2014_EGRA_v01_M_v01_A_BASE/JOR_2014_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res r_res w language lang_instr year month date region district school_code strata*  fpc* su1 su2 su3 id grade female age *start_time *end_time  language clspm csspm cnonwpm orf cnumidpm caddpm csubpm letter_sound_score letter_sound_attempted letter_sound_attempted_pcnt letter_sound_score_pcnt letter_sound_score_zero syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt  we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt wt_final 
codebook, compact
cf _all using "${path}/CNT/JOR/JOR_2014_EGRA/JOR_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/JOR/JOR_2014_EGRA/JOR_2014_EGRA_v01_M_v01_A_HAD.dta", replace

/*
//append
use "${gsdData}/0-RawOutput/Jordan_2012_s.dta", replace 
append using "${gsdData}/0-RawOutput/Jordan_2014_s.dta" 

replace country = "Jordan"
gen cntabb = "JOR"
gen idcntry = 400

save "${gsdData}/0-RawOutput/merged/Jordan.dta", replace 
