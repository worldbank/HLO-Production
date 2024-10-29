set seed 10051990
set sortseed 10051990


use "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M/Data/Stata/2015.dta", clear
*Data is survey set and have weights
ren wt_stage3 wt_final
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2, fpc(fpc2) strata(strata2) || stage3, fpc(fpc3) strata(strata3) singleunit(scaled)
*Variables requested by Nadir
ren s_5 tppri
*Renaming other variables:
ren ht_type school_type
ren e_oral_vocab_* e_vocab_word_*
ren (masked_student_id masked_school_ID) (id school_code)
keep country region district date month year language school_type grade consent age female caddpm csubpm cnumidpm num_id_score_pcnt num_id_score_zero quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero word_prob_score_pcnt word_prob_score_zero add_score_pcnt add_score_zero sub_score_pcnt sub_score_zero we_add_score_pcnt we_add_score_zero we_sub_score_pcnt we_sub_score_zero e_clspm e_cnonwpm e_orf e_letter_sound_score_pcnt e_letter_sound_score_zero e_invent_word_score_pcnt e_invent_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero e_list_comp_score_pcnt e_list_comp_score_zero gh_clspm gh_cnonwpm gh_orf gh_letter_sound_score_pcnt gh_letter_sound_score_zero gh_invent_word_score_pcnt gh_invent_word_score_zero gh_oral_read_score_pcnt gh_oral_read_score_zero gh_read_comp_score_pcnt gh_read_comp_score_zero gh_list_comp_score_pcnt gh_list_comp_score_zero id school_code stage* strata* fpc* wt_final
ren gh_* *
gen n_res = 1
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region 
ren region_s region
decode language, gen(language_s)
drop language
ren language_s language
gen s_res = 1
gen lang_instr = "English"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
replace country = "Ghana"
gen cntabb = "GHA"
gen idcntry = 288

*Destring weighting variables:
encode stage1, gen(su1)
encode stage2, gen(su2)
encode stage3, gen(su3)

save  "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M_v01_A_BASE/GHA_2015_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry region district date month year su* strata* fpc* language school_type grade consent age female caddpm csubpm cnumidpm num_id_score_pcnt num_id_score_zero quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero word_prob_score_pcnt word_prob_score_zero add_score_pcnt add_score_zero sub_score_pcnt sub_score_zero we_add_score_pcnt we_add_score_zero we_sub_score_pcnt we_sub_score_zero e_clspm e_cnonwpm e_orf e_letter_sound_score_pcnt e_letter_sound_score_zero e_invent_word_score_pcnt e_invent_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero e_list_comp_score_pcnt e_list_comp_score_zero clspm cnonwpm orf letter_sound_score_pcnt letter_sound_score_zero invent_word_score_pcnt invent_word_score_zero oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero list_comp_score_pcnt list_comp_score_zero id school_code strata* fpc* wt_final


codebook, compact
cf _all using  "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M_v01_A_HAD.dta"
save  "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M_v01_A_HAD.dta", replace

/*
use "${path}/CNT/GHA/GHA_2013_EGRA/GHA_2013_EGRA_v01_M_v01_A_BASE/GHA_2013_EGRA_v01_M_v01_A_BASE.dta", replace
append using  "${path}/CNT/GHA/GHA_2015_EGRA/GHA_2015_EGRA_v01_M_v01_A_BASE/GHA_2015_EGRA_v01_M_v01_A_BASE.dta"
replace country = "Ghana"
gen cntabb = "GHA"
gen idcntry = 288
gen n = _n
save "${gsdData}/0-RawOutput/merged/Ghana.dta", replace
