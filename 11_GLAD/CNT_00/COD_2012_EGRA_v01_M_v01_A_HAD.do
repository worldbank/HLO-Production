set seed 10051990
set sortseed 10051990

use "${path}/CNT/COD/COD_2012_EGRA/COD_2012_EGRA_v01_M/Data/Stata/2012.dta", clear
*Renaming variables to same names as in 2010.
ren division district
*Clean formatting
gen date2 = date(date, "MDY")
format date2 %td
drop date
ren date2 date
keep country year month date treatment region school_code id strata1 strata2 fpc1 fpc2 grade female age start_time end_time  language consent clspm cwpm cnonwpm orf cnumidpm vocab_word_score vocab_word_score_pcnt vocab_word_score_zero vocab_word_attempted vocab_word_attempted_pcnt pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt add_score add_score_pcnt add_attempted add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt we_mult_score we_mult_score_pcnt we_mult_score_zero we_mult_attempted we_mult_attempted we_mult_attempted_pcnt we_div_score we_div_score_pcnt we_div_score_zero we_div_attempted we_div_attempted_pcnt wt_final exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 exit_interview19 
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 1 
decode region, gen(region_s)
drop region 
ren region_s region
*Coding languages using https://www.loc.gov/standards/iso639-2/php/code_list.php
decode language, gen(language_s)
drop language
ren language_s language
gen s_res = 1
gen lang_instr = "French"

replace country = "Congo, (Kinshasa)"
gen cntabb = "COD"
gen idcntry = 180

*Constructing index for socio-economic status
*Identifying variables:
*exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 exit_interview19
foreach var of varlist exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 exit_interview19 {
	replace `var' = . if `var' == 9
	egen `var'_mean = mean(`var')
	replace `var' = `var'_mean if missing(`var')
}

alphawgt exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 exit_interview19 [weight = wt_final], detail std item label  // cronbach alpha = 0.6487
foreach var of varlist exit_interview10 exit_interview11 exit_interview12 exit_interview13 exit_interview14 exit_interview15 exit_interview16 exit_interview17 exit_interview18 exit_interview19 {
	egen `var'_std = std(`var')
}
pca *_std [weight = wt_final]
*predict ESCS
gen radio_yn = exit_interview10
gen telephone_yn = exit_interview11
gen electricity_yn = exit_interview12
gen television_yn = exit_interview13
gen toilet_yn = exit_interview15
gen fridge_yn = exit_interview14
gen bicycle_yn = exit_interview16
gen motorcycle_yn = exit_interview17
gen canoe_yn = exit_interview18
gen four_wheeler_yn = exit_interview19

codebook, compact
cf _all using "${path}/CNT/COD/COD_2012_EGRA/COD_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/COD/COD_2012_EGRA/COD_2012_EGRA_v01_M_v01_A_HAD.dta", replace

