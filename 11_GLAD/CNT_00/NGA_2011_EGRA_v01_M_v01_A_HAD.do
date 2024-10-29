
set seed 10051990
set sortseed 10051990

*Data in Hausa:
use "${path}/CNT/NGA/NGA_2011_EGRA/NGA_2011_EGRA_v01_M/Data/Stata/2011_h.dta", clear
*Variables requested by Nadir:
ren exit_interview2 lan_at_home
keep country year month date state state_treat district school_code school_type id grade female lan_at_home age language consent clspm csspm cwpm cnonwpm orf pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt syll_sound_score syll_sound_score_pcnt syll_sound_score_zero syll_sound_attempted syll_sound_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt wt_final fpc1 fpc2 fpc3
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 1
gen w = 1
drop language
gen language = "Hausa"
ren state region
decode region, gen(region_s)
drop region
ren region_s region
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
gen lang_instr = "English"

replace country = "Nigeria"
gen cntabb = "NGA"
gen idcntry = 566

codebook, compact
cf _all using "${path}\CNT\NGA\NGA_2011_EGRA\NGA_2011_EGRA_v01_M_v01_a_HAD.dta"
save "${path}\CNT\NGA\NGA_2011_EGRA\NGA_2011_EGRA_v01_M_v01_a_HAD.dta", replace

