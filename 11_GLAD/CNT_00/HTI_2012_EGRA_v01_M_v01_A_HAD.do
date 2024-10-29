*Haiti
set seed 10051990
set sortseed 10051990

use "${path}/CNT/HTI/HTI_2012_EGRA/HTI_2012_EGRA_v01_M/Data/Stata/2012.dta", clear

*Data is weighted
drop if missing(language)
keep country year month date id grade female strata1 school_code fpc1 strat2 id fpc2 start_time end_time language consent *clspm *clpm *cwpm *cnonwpm *orf *pa_init_sound_score *pa_init_sound_score_pcnt *pa_init_sound_score_zero *pa_init_sound_attempted *pa_init_sound_attempted_pcnt *letter_score *letter_score_pcnt *letter_score_zero *letter_attempted *letter_attempted_pcnt *letter_sound_score *letter_sound_score_pcnt *letter_sound_score_zero *letter_sound_attempted *letter_sound_attempted_pcnt *fam_word_score *fam_word_score_pcnt *fam_word_score_zero *fam_word_attempted *fam_word_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt wt_final exit_interview24 exit_interview27a exit_interview27b exit_interview27c exit_interview27d exit_interview27e exit_interview27f exit_interview27g exit_interview27h exit_interview27i exit_interview27j exit_interview27k exit_interview27l exit_interview27m_1 exit_interview27m_2 exit_interview27m_3 exit_interview27m_4 exit_interview27m_5 exit_interview27n_1 exit_interview27n_2 exit_interview27n_3 exit_interview27n_4 exit_interview27o_1 exit_interview27o_2 exit_interview27o_3 exit_interview27o_5 exit_interview27o_6 exit_interview27o_7 exit_interview27o_8 exit_interview27o_9 exit_interview27o_10 exit_interview27p_1 exit_interview27p_2 exit_interview27p_3 exit_interview27p_4
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
ren f_* fr_*
gen n_res = 0
gen r_res = 0
gen w = 1
drop language
gen s_res = 1
gen lang_instr = "French"
gen language = "French"


*Identifying variables for ESCS:
*exit_interview24 exit_interview27a exit_interview27b exit_interview27c exit_interview27d exit_interview27e exit_interview27f exit_interview27g exit_interview27h exit_interview27i exit_interview27j exit_interview27k exit_interview27l exit_interview27m_1 exit_interview27m_2 exit_interview27m_3 exit_interview27m_4 exit_interview27m_5 exit_interview27n_1 exit_interview27n_2 exit_interview27n_3 exit_interview27n_4 exit_interview27o_1 exit_interview27o_2 exit_interview27o_3 exit_interview27o_5 exit_interview27o_6 exit_interview27o_7 exit_interview27o_8 exit_interview27o_9 exit_interview27o_10 exit_interview27p_1 exit_interview27p_2 exit_interview27p_3 exit_interview27p_4
foreach var of varlist exit_interview24 exit_interview27a exit_interview27b exit_interview27c exit_interview27d exit_interview27e exit_interview27f exit_interview27g exit_interview27h exit_interview27i exit_interview27j exit_interview27k exit_interview27l exit_interview27m_1 exit_interview27m_2 exit_interview27m_3 exit_interview27m_4 exit_interview27m_5 exit_interview27n_1 exit_interview27n_2 exit_interview27n_3 exit_interview27n_4 exit_interview27o_1 exit_interview27o_2 exit_interview27o_3 exit_interview27o_5 exit_interview27o_6 exit_interview27o_7 exit_interview27o_8 exit_interview27o_9 exit_interview27o_10 exit_interview27p_1 exit_interview27p_2 exit_interview27p_3 exit_interview27p_4 {
	tab `var'
}
*Missing:
mdesc exit_interview24 exit_interview27a exit_interview27b exit_interview27c exit_interview27d exit_interview27e exit_interview27f exit_interview27g exit_interview27h exit_interview27i exit_interview27j exit_interview27k exit_interview27l exit_interview27m_1 exit_interview27m_2 exit_interview27m_3 exit_interview27m_4 exit_interview27m_5 exit_interview27n_1 exit_interview27n_2 exit_interview27n_3 exit_interview27n_4 exit_interview27o_1 exit_interview27o_2 exit_interview27o_3 exit_interview27o_5 exit_interview27o_6 exit_interview27o_7 exit_interview27o_8 exit_interview27o_9 exit_interview27o_10 exit_interview27p_1 exit_interview27p_2 exit_interview27p_3 exit_interview27p_4
*Vehicle and roof questions have more than 30% missing values: Removing these variables: exit_interview27d exit_interview27e exit_interview27p_1 exit_interview27p_2 exit_interview27p_3 exit_interview27p_4
*Some variables are coding others. Remove these: exit_interview27m_5 exit_interview27n_4 exit_interview27o_10 exit_interview27p_4
*Filling in missing
foreach var of varlist exit_interview24 exit_interview27a exit_interview27b exit_interview27c exit_interview27f exit_interview27g exit_interview27h exit_interview27i exit_interview27j exit_interview27k exit_interview27l exit_interview27m_1 exit_interview27m_2 exit_interview27m_3 exit_interview27m_4 exit_interview27n_1 exit_interview27n_2 exit_interview27n_3 exit_interview27o_1 exit_interview27o_2 exit_interview27o_3 exit_interview27o_5 exit_interview27o_6 exit_interview27o_7 exit_interview27o_8 exit_interview27o_9 {
	replace `var' = . if `var' == 9
	bysort strata1 school_code: egen `var'_mean = mean(`var')
	bysort strata1 school_code: egen `var'_count = count(`var')
	bysort strata1: egen `var'_mean_s = mean(`var')
	bysort strata1: egen `var'_count_s = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_s if missing(`var') & `var'_count_s > 10 & !missing(`var'_count_s)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview24_std exit_interview27a_std exit_interview27b_std exit_interview27c_std exit_interview27f_std exit_interview27g_std exit_interview27h_std exit_interview27i_std exit_interview27j_std exit_interview27k_std exit_interview27l_std exit_interview27m_1_std exit_interview27m_2_std exit_interview27m_3_std exit_interview27m_4_std  exit_interview27n_1_std exit_interview27n_2_std exit_interview27n_3_std  exit_interview27o_1_std exit_interview27o_2_std exit_interview27o_3_std exit_interview27o_5_std exit_interview27o_6_std exit_interview27o_7_std exit_interview27o_8_std exit_interview27o_9_std [weight = wt_final], detail item std
pca exit_interview24_std exit_interview27a_std exit_interview27b_std exit_interview27c_std exit_interview27f_std exit_interview27g_std exit_interview27h_std exit_interview27i_std exit_interview27j_std exit_interview27k_std exit_interview27l_std exit_interview27m_1_std exit_interview27m_2_std exit_interview27m_3_std exit_interview27m_4_std  exit_interview27n_1_std exit_interview27n_2_std exit_interview27n_3_std  exit_interview27o_1_std exit_interview27o_2_std exit_interview27o_3_std exit_interview27o_5_std exit_interview27o_6_std exit_interview27o_7_std exit_interview27o_8_std exit_interview27o_9_std  [weight = wt_final]
predict ESCS

*Generating Asset Variables:
gen books_yn = exit_interview24
gen radio_yn = exit_interview27a
gen television_yn = exit_interview27b
gen bicycle_yn = exit_interview27c
gen motorcycle_yn = exit_interview27f
gen cart_yn = exit_interview27g
gen four_wheeler_yn = exit_interview27h
gen canoe_yn = exit_interview27i
gen electricity_yn = exit_interview27j
gen computer_yn = exit_interview27k
gen kitchen_yn = exit_interview27l
gen pit_toilet_yn = exit_interview27m_1
gen toilet_yn = exit_interview27m_2
gen bucket_yn = exit_interview27m_3
gen firewood_yn = exit_interview27n_1
gen coal_yn = exit_interview27n_2
gen gas_electric_stove_yn = exit_interview27n_3
gen river_stream_yn = exit_interview27o_1
gen tank_watertruck_yn = exit_interview27o_2
gen tap_in_home_compound_yn = exit_interview27o_3
gen well_borehole_yn = exit_interview27o_5
gen rain_yn = exit_interview27o_6
gen sachet_yn = exit_interview27o_7
gen bottle_yn = exit_interview27o_8
gen company_yn = exit_interview27o_9

replace country = "Haiti"
gen cntabb = "HTI"
gen idcntry = 332
save "${path}/CNT/HTI/HTI_2012_EGRA/HTI_2012_EGRA_v01_M_v01_A_BASE/HTI_2012_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res r_res w s_res lang_instr year month date id grade female strata1 school_code fpc1 strat2 id fpc2 start_time end_time language consent *clspm *clpm *cwpm *cnonwpm *orf *pa_init_sound_score *pa_init_sound_score_pcnt *pa_init_sound_score_zero *pa_init_sound_attempted *pa_init_sound_attempted_pcnt *letter_score *letter_score_pcnt *letter_score_zero *letter_attempted *letter_attempted_pcnt *letter_sound_score *letter_sound_score_pcnt *letter_sound_score_zero *letter_sound_attempted *letter_sound_attempted_pcnt *fam_word_score *fam_word_score_pcnt *fam_word_score_zero *fam_word_attempted *fam_word_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt wt_final *_yn

codebook, compact
cf _all using "${path}/CNT/HTI/HTI_2012_EGRA/HTI_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/HTI/HTI_2012_EGRA/HTI_2012_EGRA_v01_M_v01_A_HAD.dta", replace




/*use "${gsdRawData}/EGRA/Haiti/Data/2012.dta", clear
*Data is weighted
drop if missing(language)
keep country year month date id grade female strata1 school_code fpc1 strat2 id fpc2 start_time end_time language consent *clspm *clpm *cwpm *cnonwpm *orf *pa_init_sound_score *pa_init_sound_score_pcnt *pa_init_sound_score_zero *pa_init_sound_attempted *pa_init_sound_attempted_pcnt *letter_score *letter_score_pcnt *letter_score_zero *letter_attempted *letter_attempted_pcnt *letter_sound_score *letter_sound_score_pcnt *letter_sound_score_zero *letter_sound_attempted *letter_sound_attempted_pcnt *fam_word_score *fam_word_score_pcnt *fam_word_score_zero *fam_word_attempted *fam_word_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt wt_final
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
ren f_* fr_*
gen n_res = 0
gen r_res = 0
gen w = 1
drop language
gen s_res = 1
gen lang_instr = "French"
gen language = "French"
save "${gsdData}/0-RawOutput/EGRA_Haiti_2012_s_fr.dta", replace
*/

