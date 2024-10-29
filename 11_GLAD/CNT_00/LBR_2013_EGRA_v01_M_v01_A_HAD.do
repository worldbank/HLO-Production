

set seed 10051990
set sortseed 10051990

use "${path}/CNT/LBR/LBR_2013_EGRA/LBR_2013_EGRA_v01_M/Data/Stata/2013.dta", clear

*Variables requested by Nadir are not available
*Renaming some variables:
ren (pa_df_init_snd_score pa_df_init_snd_score_zero pa_df_init_snd_score_pcnt pa_df_init_snd_attempted pa_df_init_snd_attempted_pcnt) (pa_init_sound_score pa_init_sound_score_zero pa_init_sound_score_pcnt pa_init_sound_attempted pa_init_sound_attempted_pcnt)
ren exit_interview1a lan_at_home_e
keep country country year strata* fpc* date district language school_code grade id lan_at_home_e female age consent clpm cwpm cnonwpm orf pa_init_sound_score pa_init_sound_score_zero pa_init_sound_score_pcnt letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt fam_word_score fam_word_score_zero fam_word_score_pcnt fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_zero invent_word_score_pcnt invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score_zero read_comp_score_pcnt read_comp_score read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt num_id_score num_id_score_zero num_id_score_pcnt num_id_attempted num_id_attempted_pcnt  quant_comp_score quant_comp_score_zero quant_comp_score_pcnt quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_zero miss_num_score_pcnt miss_num_attempted miss_num_attempted_pcnt word_prob_score word_prob_score_pcnt word_prob_score_zero word_prob_attempted word_prob_attempted_pcnt sub_score add_score sub_score_zero sub_score_pcnt sub_attempted sub_attempted_pcnt add_score_zero add_score_pcnt add_attempted add_attempted_pcnt wt_final
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 1
drop if missing(language)
decode language, gen(language_s)
drop language
ren language_s language 
encode district, gen(district_n)
drop district
ren district_n district
bysort id: gen id_n = _n
drop id
ren id_n id
gen s_res = 1
gen lang_instr = "English"
drop if missing(year)

replace country = "Liberia"
gen cntabb = "LBR"
gen idcntry = 430

*****************************************************
*Development of ESCS variable
*****************************************************
*Identifying variables:
*Not enough variables available.
codebook, compact
cf _all using "${path}/CNT/LBR/LBR_2013_EGRA/LBR_2013_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/LBR/LBR_2013_EGRA/LBR_2013_EGRA_v01_M_v01_A_HAD.dta", replace

