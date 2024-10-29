** Ghana

set seed 10051990
set sortseed 10051990

*Bringing in Ghana Data:
use "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M/Data/Stata/2013.dta", clear
*Data is survey set and have weights
ren wt_stage2 wt_final
ren s_5 tppri
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2, fpc(fpc2) strata(strata2) singleunit(scaled)
*Variables requested by Nadir
ren wealth_index tses0
ren e_oral_vocab_* e_vocab_word_*
ren (masked_student_id masked_school_ID) (id school_code)

decode region, gen(region_s)
drop region 
ren region_s region
keep country district region school_type urban school_code year month date id grade female age consent e_clspm e_cnonwpm e_orf caddpm csubpm cnumidpm  e_vocab_word_score_pcnt e_vocab_word_attempted_pcnt e_vocab_word_score_zero e_letter_sound_score_pcnt e_letter_sound_score_zero e_invent_word_score_pcnt e_invent_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero e_list_comp_score_pcnt e_list_comp_score_zero num_id_score_pcnt num_id_score_zero quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero add_score_pcnt add_score_zero we_add_score_pcnt we_add_score_zero sub_score_pcnt sub_score_zero we_sub_score_pcnt we_sub_score_zero word_prob_score_pcnt word_prob_score_zero ghna_clspm ghna_cnonwpm ghna_orf ghna_letter_sound_score_pcnt ghna_letter_sound_score_zero ghna_invent_word_score_pcnt ghna_invent_word_score_zero ghna_oral_read_score_pcnt ghna_oral_read_score_zero ghna_read_comp_score_pcnt ghna_read_comp_score_zero ghna_list_comp_score_pcnt ghna_list_comp_score_zero tppri tses0 strata1 stage1 fpc1 strata2 stage2 fpc2 wt_final s_16 s_17  s_19 s_20 s_21_a s_21_b s_21_c s_21_d s_21_e s_21_f s_21_g s_21_h s_22

ren ghna_* *

gen n_res = 1
gen r_res = 1
gen w = 1

gen test_language = "English"
gen lang_instr = "English"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
*Constructing index for socio-economic index:
*Identifying variables
*s_16 s_17  s_19 s_20 s_21_a s_21_b s_21_c s_21_d s_21_e s_21_f s_21_g s_21_h s_22
*Cleaning variables:
foreach var of varlist s_16 s_19 s_20 {
	replace `var' = . if inlist(`var',777,888,7777)
}
foreach var of varlist s_17 s_21_a s_21_b s_21_c s_21_d s_21_e s_21_f s_21_g s_21_h s_22 {
	replace `var' = . if `var' == 3
}
*
mdesc s_16 s_17  s_19 s_20 s_21_a s_21_b s_21_c s_21_d s_21_e s_21_f s_21_g s_21_h s_22
*Generating dummy variables for categorical variables:
foreach var of varlist s_16 s_19 s_20 {
	tab `var', gen(`var'_d)
}
foreach var of varlist s_16_d* s_17  s_19_d* s_20_d* s_21_a s_21_b s_21_c s_21_d s_21_e s_21_f s_21_g s_21_h s_22 {
	bysort region district school_code: egen `var'_mean = mean(`var')
	bysort region district school_code: egen `var'_count = count(`var')
	bysort region district: egen `var'_mean_d = mean(`var')
	bysort region district: egen `var'_count_d = count(`var')
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_d if missing(`var') & `var'_count_d > 7 & !missing(`var'_count_d)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}

alphawgt s_16_d*_std s_17_std s_19_d*_std s_20_d*_std s_21_a_std s_21_b_std s_21_c_std s_21_d_std s_21_e_std s_21_f_std s_21_g_std s_21_h_std s_22_std [weight = wt_final], detail item std
pca s_16_d*_std s_17_std s_19_d*_std s_20_d*_std s_21_a_std s_21_b_std s_21_c_std s_21_d_std s_21_e_std s_21_f_std s_21_g_std s_21_h_std s_22_std [weight = wt_final]
predict ESCS

*Labelling asset variables:
gen river_stream_yn = s_16_d1
gen well_borehole_yn = s_16_d2
gen tap_in_home_compound_yn = 1 if (s_16_d3 == 1 | s_16_d4 == 1)
replace tap_in_home_compound_yn = 0 if (s_16_d3 == s_16_d4 == 0)
gen tank_watertruck_yn = s_16_d5
gen electricity_yn = s_17
gen firewood_yn = s_19_d1
gen coal_yn = s_19_d2
gen gas_electric_stove_yn = 1 if (s_19_d3 == 1 | s_19_d4 == 1)
replace gas_electric_stove_yn = 0 if (s_19_d3 == 0 & s_19_d4 == 0)
gen cooker_oven_yn = s_19_d5
gen pit_toilet_yn = s_20_d1
gen communal_toilet_yn = 1 if (s_20_d2 == 1 | s_20_d3 == 1)
replace communal_toilet_yn = 0 if (s_20_d2 == 0 & s_20_d3 == 0)
gen toilet_yn = 1 if (s_20_d4 == 1 ) | (s_20_d5 == 1)
replace toilet_yn = 0 if (s_20_d4 == 0 & s_20_d5 == 0)
gen bush_yn = s_20_d6
gen radio_yn = s_21_a
gen mobile_yn = s_21_b
gen television_yn = s_21_c
gen computer_yn = s_21_d
gen fridge_yn = s_21_e
gen bicycle_yn = s_21_f 
gen motorcycle_yn = s_21_g 
gen four_wheeler_yn = s_21_h
gen books_yn = s_22

replace country = "Ghana"
gen cntabb = "GHA"
gen idcntry = 288

*Converting weighting variables to numeric:
encode stage1, gen(su1)
gen su2 = stage2




save  "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M_v01_A_BASE/GHA_2013_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res r_res w district region school_type su* strata* fpc* urban school_code year month date id grade female age consent e_clspm e_cnonwpm e_orf caddpm csubpm cnumidpm  e_vocab_word_score_pcnt e_vocab_word_attempted_pcnt e_vocab_word_score_zero e_letter_sound_score_pcnt e_letter_sound_score_zero e_invent_word_score_pcnt e_invent_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero e_list_comp_score_pcnt e_list_comp_score_zero num_id_score_pcnt num_id_score_zero quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero add_score_pcnt add_score_zero we_add_score_pcnt we_add_score_zero sub_score_pcnt sub_score_zero we_sub_score_pcnt we_sub_score_zero word_prob_score_pcnt word_prob_score_zero clspm cnonwpm orf letter_sound_score_pcnt letter_sound_score_zero invent_word_score_pcnt invent_word_score_zero oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero list_comp_score_pcnt list_comp_score_zero tppri tses0 strata1 fpc1 strata2 fpc2 wt_final *_yn

codebook, compact
cf _all using "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M_v01_A_HAD.dta"
save  "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M_v01_A_HAD.dta", replace


/*
use "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M_v01_A_BASE/GHA_2013_EGRA_v01_M_v01_A_BASE.dta", replace
append using  "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M_v01_A_BASE/GHA_2015_EGRA_v01_M_v01_A_BASE.dta"
replace country = "Ghana"
gen cntabb = "GHA"
gen idcntry = 288
gen n = _n
save "${gsdData}/0-RawOutput/merged/Ghana.dta", replace
