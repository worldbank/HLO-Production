set seed 10051990
set sortseed 10051990


use "${path}/CNT/KEN/KEN_2012_EGRA/KEN_2012_EGRA_v01_M/Data/Stata/2012.dta", clear
*Data is weighted
*Renaming some variables:
ren (caddpm1 csubpm1) (caddpm csubpm)
*Level 2 Addition and Subtraction are written exercises
ren sublvl1* sub*
ren addlvl1* add*
ren sublvl2* we_sub*
ren addlvl2* we_add*
ren pa_phon_sound* pa_init_sound*
ren k_syll* syll*
encode district, gen(district_n)
drop district
ren district_n district
encode region, gen(region_n)
drop region
ren region_n region
keep country year month date region district urban nonformal strata1 strat2 school_code fpc* id grade female age *start_time *end_time  *language consent *clspm *cnonwpm *orf cnumidpm caddpm csubpm vocab_word_score vocab_word_score_pcnt vocab_word_score_zero vocab_word_attempted vocab_word_attempted_pcnt pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt *letter_sound_score *letter_sound_attempted *letter_sound_attempted_pcnt *letter_sound_score_pcnt *letter_sound_score_zero syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *unt_oral_read_score *unt_oral_read_score_pcnt *unt_oral_read_score_zero *unt_oral_read_attempted *unt_oral_read_attempted_pcnt *unt_read_comp_score *unt_read_comp_score_pcnt *unt_read_comp_score_zero *unt_read_comp_attempted *unt_read_comp_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt *maze_score maze_score_pcnt *maze_score_zero *maze_attempted *maze_attempted_pcnt count_obj_max num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt  we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt wt_final exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview17

foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
decode language, gen(language_s)
drop language
ren language_s language
gen s_res = 1
gen lang_instr = "English"

*ESCS
*Identifying variables:
*exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview17
numlabel, add
foreach var of varlist exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview17 {
	tab `var'
}
*Missings:
mdesc exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview17

foreach var of varlist  exit_interview2 exit_interview3 exit_interview4 exit_interview5 exit_interview6 exit_interview7 exit_interview8 exit_interview9 exit_interview10 exit_interview17 {
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
alphawgt  exit_interview2_std exit_interview3_std exit_interview4_std exit_interview5_std exit_interview6_std exit_interview7_std exit_interview8_std exit_interview9_std exit_interview10_std exit_interview17_std [weight = wt_final], item detail
pca  exit_interview2_std exit_interview3_std exit_interview4_std exit_interview5_std exit_interview6_std exit_interview7_std exit_interview8_std exit_interview9_std exit_interview10_std exit_interview17_std [weight = wt_final]
predict ESCS

*Generating Asset Variables:
gen radio_yn = exit_interview2
gen telephone_yn = exit_interview3
gen electricity_yn = exit_interview4
gen television_yn = exit_interview5
gen fridge_yn = exit_interview6
gen toilet_yn = exit_interview7
gen bicycle_yn = exit_interview8
gen motorcycle_yn = exit_interview9
gen four_wheeler_yn = exit_interview10
gen books_yn = exit_interview17


replace country = "Kenya"
gen cntabb = "KEN"
gen idcntry = 404

save "${path}/CNT/KEN/KEN_2012_EGRA/KEN_2012_EGRA_v01_M_v01_A_BASE/KEN_2012_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry n_res r_res w s_res lang_instr year month date region district urban nonformal strata1 strat2 school_code fpc* id grade female age *start_time *end_time  *language consent *clspm *cnonwpm *orf cnumidpm caddpm csubpm vocab_word_score vocab_word_score_pcnt vocab_word_score_zero vocab_word_attempted vocab_word_attempted_pcnt pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt *letter_sound_score *letter_sound_attempted *letter_sound_attempted_pcnt *letter_sound_score_pcnt *letter_sound_score_zero syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *unt_oral_read_score *unt_oral_read_score_pcnt *unt_oral_read_score_zero *unt_oral_read_attempted *unt_oral_read_attempted_pcnt *unt_read_comp_score *unt_read_comp_score_pcnt *unt_read_comp_score_zero *unt_read_comp_attempted *unt_read_comp_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt *maze_score maze_score_pcnt *maze_score_zero *maze_attempted *maze_attempted_pcnt count_obj_max num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt word_prob_score add_score add_score_pcnt add_attempted add_attempted_pcnt  we_add_score we_add_score_pcnt we_add_score_zero we_add_attempted we_add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt we_sub_score we_sub_score_pcnt we_sub_score_zero we_sub_attempted we_sub_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt wt_final *_yn
codebook, compact
cf _all using "${path}/CNT/KEN/KEN_2012_EGRA/KEN_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/KEN/KEN_2012_EGRA/KEN_2012_EGRA_v01_M_v01_A_HAD.dta", replace


/*// append
save "${gsdData}/0-RawOutput/Kenya_2012_s.dta", replace
append using "${gsdData}/0-RawOutput/Kenya_2012_s.dta"

replace country = "Kenya"
gen cntabb = "KEN"
gen idcntry = 404

save "${gsdData}/0-RawOutput/merged/Kenya.dta", replace
