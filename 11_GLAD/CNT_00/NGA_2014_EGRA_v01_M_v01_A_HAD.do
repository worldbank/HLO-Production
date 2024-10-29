*Aroob's comments: This file is not correct as it does not use English scores - Language of Instruction in Nigeria in Grade 4 is English.
*We have included GLAD in its place now!
set seed 10051990
set sortseed 10051990

use "${path}/CNT/NGA/NGA_2014_EGRA/NGA_2014_EGRA_v01_M/Data/Stata/PUF_3.Nigeria2014-4_State_grade2-3_EGRA-SSME_Hausa-English.dta", clear
*Variables requested by Nadir:
ren wealthindex tses0
keep country language state strata* stage* fpc* school_type school_code id date year month consent grade female end_time h_clspm h_cnonwpm h_orf h_letter_sound_score h_letter_sound_score_pcnt h_letter_sound_score_zero h_letter_sound_attempted h_letter_sound_attempted_pcnt h_invent_word_score h_invent_word_score_pcnt h_invent_word_score_zero h_invent_word_attempted h_invent_word_attempted_pcnt h_oral_read_score h_oral_read_time_remain h_oral_read_score_pcnt h_oral_read_score_zero h_oral_read_auto_stop h_oral_read_attempted h_oral_read_attempted_pcnt h_read_comp_score h_read_comp_score_pcnt h_read_comp_score_zero h_read_comp_attempted h_read_comp_attempted_pcnt h_list_comp_score h_list_comp_score_pcnt h_list_comp_score_zero h_list_comp_attempted h_list_comp_attempted_pcnt e_letter_sound_score e_letter_sound_score_pcnt e_letter_sound_score_zero e_letter_sound_attempted e_letter_sound_attempted_pcnt e_invent_word_score e_invent_word_score_pcnt e_invent_word_score_zero e_invent_word_attempted e_invent_word_attempted_pcnt e_oral_read_score e_oral_read_score_pcnt e_oral_read_score_zero e_oral_read_attempted e_oral_read_attempted_pcnt e_read_comp_score e_read_comp_score_pcnt e_read_comp_score_zero e_read_comp_attempted e_read_comp_attempted_pcnt e_list_comp_score e_list_comp_score_pcnt e_list_comp_score_zero e_list_comp_attempted e_list_comp_attempted_pcnt wt_final strata1 fpc1 stage1 stage2 strata2 fpc2
*Renaming Hausa scores to normal scores
ren h_* *
gen n_res = 0
gen r_res = 1
gen w = 1 
replace orf = 0 if missing(orf)
ren state region
decode region, gen(region_s)
drop region
ren region_s region
drop language
gen language = "Hausa"
encode school_code, gen(school_code_n)
drop school_code
ren school_code_n school_code
bysort id: gen id_n = _n
drop id
ren id_n id
gen s_res = 1
gen lang_instr = "English"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type

replace country = "Nigeria"
gen cntabb = "NGA"
gen idcntry = 566

codebook, compact
cf _all using "${path}\CNT\NGA\NGA_2014_EGRA\NGA_2014_EGRA_v01_M_v01_A_HAD"
save "${path}\CNT\NGA\NGA_2014_EGRA\NGA_2014_EGRA_v01_M_v01_A_HAD", replace
