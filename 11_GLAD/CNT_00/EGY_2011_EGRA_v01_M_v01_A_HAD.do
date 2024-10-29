* Egypt
set seed 10051990
set sortseed 10051990

use "${path}/CNT/EGY/EGY_2011_EGRA/EGY_2011_EGRA_v01_M/Data/Stata/2011.dta", clear
*No weights available in this dataset. Not nationally representative.
keep country year region district id grade female language clspm cwpm cnonwpm orf  letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 1
gen w = 0
decode language, gen(language_s)
drop language
ren language_s language
replace language = "Arabic"
drop region
gen lang_instr = "Arabic"
replace country = "Egypt"
gen cntabb = "EGY"
gen idcntry = 818

codebook, compact
cf _all using "${path}\CNT\EGY\EGY_2011_EGRA\EGY_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\EGY\EGY_2011_EGRA\EGY_2011_EGRA_v01_M_v01_A_HAD.dta", replace

