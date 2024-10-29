set seed 10051990
set sortseed 10051990

use "${path}/CNT/MWI/MWI_2010_EGRA/MWI_2010_EGRA_v01_M/Data/Stata/2010.dta", clear
ren exit_interview11 tppri
*svyset is there. But school_code is not available.
gen w = 0
*Renaming some variables:
ren (pa_num_sound_score pa_num_sound_score_pcnt pa_num_sound_score_zero pa_num_sound_attempted pa_num_sound_attempted_pcnt) (syll_seg_score syll_seg_sound_score_pcnt syll_seg_sound_score_zero syll_seg_sound_attempted syll_seg_sound_attempted_pcnt)
keep w country district year month date urban treat_phase strat3 fpc* id grade female age language consent clpm csspm cwpm cnonwpm orf syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_score_pcnt letter_score letter_score_zero letter_attempted letter_attempted_pcnt syll_seg_score syll_seg_sound_score_pcnt syll_seg_sound_score_zero syll_seg_sound_attempted syll_seg_sound_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt wt_final tppri *exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15 exit_interview18 exit_interview19

foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
*Sampling Method:
gen n_res = 0
gen r_res = 0
gen lang_instr = "Chichewa"
decode language, gen(language_s)
drop language
ren language_s language

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15 exit_interview18 exit_interview19
numlabel, add
foreach var of varlist exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15 exit_interview18 exit_interview19 {
	tab `var'
	replace `var' = . if inlist(`var',8,9)
}
mdesc exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15 exit_interview18 exit_interview19 
*Parents' education variables have missing around 50%.
mdesc exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15 exit_interview18 exit_interview19 
foreach var of varlist exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15  {
	bysort district : egen `var'_mean = mean(`var')
	bysort district : egen `var'_count = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview15, detail item
pca exit_interview2_std exit_interview3_std exit_interview4_std exit_interview5_std exit_interview6_std exit_interview7_std exit_interview8_std exit_interview9_std exit_interview10_std exit_interview15_std
predict ESCS

*Generation of Asset variables:
gen radio_yn = exit_interview2
gen telephone_yn = exit_interview3
gen electricity_yn = exit_interview4
gen television_yn = exit_interview5
gen fridge_yn = exit_interview6
gen toilet_yn = exit_interview7
gen bicycle_yn = exit_interview8
gen motorcycle_yn = exit_interview9
gen four_wheeler_yn = exit_interview10
gen books_yn = exit_interview15


replace country = "Malawi"
gen cntabb = "MWI"
gen idcntry = 454



save "${path}/CNT/MWI/MWI_2010_EGRA/MWI_2010_EGRA_v01_M_v01_A_BASE/MWI_2010_EGRA_v01_M_v01_A_BASE.dta", replace
keep w country cntabb idcntry n_res r_res language lang_instr year month date urban treat_phase strat3 fpc* id grade female age language consent clpm csspm cwpm cnonwpm orf syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_score_pcnt letter_score letter_score_zero letter_attempted letter_attempted_pcnt syll_seg_score syll_seg_sound_score_pcnt syll_seg_sound_score_zero syll_seg_sound_attempted syll_seg_sound_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt wt_final tppri *_yn
cf _all using "${path}/CNT/MWI/MWI_2010_EGRA/MWI_2010_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/MWI/MWI_2010_EGRA/MWI_2010_EGRA_v01_M_v01_A_HAD.dta", replace
