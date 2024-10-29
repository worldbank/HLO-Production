*Rwanda

set seed 10051990
set sortseed 10051990

use "${path}/CNT/RWA/RWA_2011_EGRA/RWA_2011_EGRA_v01_M/Data/Stata/2011.dta", clear

*School_code missing:
sort strata1 district id strata3
ssc install seq
seq school_code, f(1) t(42) b(20)
*Variables requested by Nadir:
ren s_language lan_at_home
*Renaming other variables:
ren id2 id
keep country year month date district school_code id grade female age  language consent clspm cwpm cnonwpm orf k_clspm k_csspm k_cwpm k_cnonwpm k_orf caddpm csubpm cnumidpm vocab_word_score_pcnt vocab_word_score_zero pa_init_sound_score_pcnt pa_init_sound_score_zero letter_sound_score_pcnt letter_sound_score_zero fam_word_score_pcnt fam_word_score_zero invent_word_score_pcnt invent_word_score_zero oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero list_comp_score_pcnt list_comp_score_zero num_id_score_pcnt num_id_score_zero quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero word_prob_score_pcnt word_prob_score_zero add_score_pcnt add_score_zero sub_score_pcnt sub_score_zero mult_score_pcnt mult_score_zero shape_id_score_pcnt shape_id_score_zero we_add_score_pcnt we_add_score_zero we_sub_score_pcnt we_sub_score_zero we_mult_score_pcnt we_mult_score_zero we_div_score_pcnt we_div_score_zero k_language k_pa_init_sound_score_pcnt k_pa_init_sound_score_zero k_letter_sound_score_pcnt k_letter_sound_score_zero k_syll_sound_score_pcnt k_syll_sound_score_zero k_fam_word_score_pcnt k_fam_word_score_zero k_invent_word_score_pcnt k_invent_word_score_zero k_oral_read_score_pcnt k_oral_read_score_zero k_read_comp_score_pcnt k_read_comp_score_zero k_list_comp_score_pcnt k_list_comp_score_zero wt_final strata* fpc*
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 1
gen r_res = 0
gen w =1 
drop language
gen language = "English"
gen s_res = 1
gen lang_instr = "English"
gen cntabb = "RWA"
gen idcntry = 646


*Standardizing survey variables:
gen su1 = district
gen su2 = school_code
gen su3 = id

codebook, compact
cf _all using "${path}\CNT\RWA\RWA_2011_EGRA\RWA_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\RWA\RWA_2011_EGRA\RWA_2011_EGRA_v01_M_v01_A_HAD.dta", replace


