** Nicaragua
set seed 10051990
set sortseed 10051990

use "${path}/CNT/NIC/NIC_2008_EGRA/NIC_2008_EGRA_v01_M/Data/Stata/2008.dta", clear

ren exit_interview0 lan_at_home
ren exit_interview12 tppri
ren SES tses0
*Averaging phenomics scores:
foreach v in score score_pcnt score_zero attempted {
	egen pa_init_sound_`v'_total = rowtotal(pa_init_sound_`v' pa_df_init_snd_`v')
	replace pa_init_sound_`v' = pa_init_sound_`v'_total/2
	}
egen pa_init_sound_attempted_pcnt_t = rowtotal(pa_init_sound_attempted_pcnt pa_df_init_snd_attempted_pcnt)
replace pa_init_sound_attempted_pcnt = pa_init_sound_attempted_pcnt_t/2
keep country year month date region district school_code urban id grade female age wt_final program fpc1 fpc2 clpm language cwpm cnonwpm orf pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt *exit_interview16a exit_interview16b exit_interview17a exit_interview17b exit_interview17c exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17

foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 1
gen r_res = 0
gen w =1 
replace orf = 0 if missing(orf)
drop language
gen language = "Spanish"
decode region, gen(region_s)
drop region
ren region_s region
gen s_res = 1
gen lang_instr = "Spanish"
replace country = "Nicaragua"
gen cntabb = "NIC"
gen idcntry = 558

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interview16a exit_interview16b exit_interview17a exit_interview17b exit_interview17c exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17
numlabel, add
foreach var of varlist exit_interview16a exit_interview16b exit_interview17a exit_interview17b exit_interview17c exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17 {
	tab `var'
	replace `var' = . if inlist(`var',9,10,99)
}
*Missings:
mdesc exit_interview16a exit_interview16b exit_interview17a exit_interview17b exit_interview17c exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17
*For mothers, no job is coded as 0 and as 8. Recoding 8's to 8's for both parents:
replace exit_interview16a = 0 if exit_interview16a == 8
replace exit_interview16b = 0 if exit_interview16b == 8
foreach var of varlist exit_interview17a exit_interview17b exit_interview17c exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17 {
	egen `var'_std = std(`var')
}
alphawgt exit_interview17a_std exit_interview17b_std exit_interview17c_std exit_interview17g_std exit_interview17h_std exit_interview17i_std exit_interview17j_std exit_interview17_std [weight = wt_final], detail item
pca  exit_interview17a_std exit_interview17b_std exit_interview17c_std exit_interview17g_std exit_interview17h_std exit_interview17i_std exit_interview17j_std exit_interview17_std [weight = wt_final]
predict HOMEPOS

*Generating asset variables:
gen books_yn = exit_interview17a
gen electricity_yn = exit_interview17b
gen tap_in_home_compound_yn = exit_interview17c
gen telephone_yn = exit_interview17g
gen television_yn = exit_interview17h
gen radio_yn = exit_interview17i
gen fridge_yn = exit_interview17j
gen vehicle_yn = exit_interview17

*HIOCC
egen HIOCC = rowmax(exit_interview16a exit_interview16b)
label values HIOCC cuest16a

*Filling in missing in occupation:
bysort region district school_code : egen HIOCC_mode = mode(HIOCC), maxmode
bysort region district school_code : egen HIOCC_count = count(HIOCC)

bysort region district  : egen HIOCC_mode_d = mode(HIOCC), maxmode
bysort region district  : egen HIOCC_count_d = count(HIOCC)

bysort region  : egen HIOCC_mode_reg = mode(HIOCC), maxmode
bysort region  : egen HIOCC_count_reg = count(HIOCC)

egen HIOCC_mode_cnt = mode(HIOCC)

replace HIOCC = HIOCC_mode if missing(HIOCC) & HIOCC_count > 5 & !missing(HIOCC_count)
replace HIOCC = HIOCC_mode_d if missing(HIOCC) & HIOCC_count_d > 7 & !missing(HIOCC_count_d)
replace HIOCC = HIOCC_mode_reg if missing(HIOCC) & HIOCC_count_reg > 10 & !missing(HIOCC_count_reg)
replace HIOCC = HIOCC_mode_cnt if missing(HIOCC)

polychoricpca HIOCC HOMEPOS [weight= wt_final], score(ESCS) nscore(1)
ren ESCS1 ESCS

*Weight variables:
gen strata1 = program
gen su1 = school_code
gen strata2 = grade
gen su2 = id



save "${path}\CNT\NIC\NIC_2008_EGRA\NIC_2008_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry n_res r_res w s_res lang_instr strata* su1 su2 year month date region district school_code urban id grade female age wt_final program fpc1 fpc2 clpm language cwpm cnonwpm orf pa_init_sound_score pa_init_sound_score_pcnt pa_init_sound_score_zero pa_init_sound_attempted pa_init_sound_attempted_pcnt letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt dict_score dict_score_pcnt dict_score_zero dict_attempted dict_attempted_pcnt  *_yn HIOCC
codebook, compact
cf _all using "${path}\CNT\NIC\NIC_2008_EGRA\NIC_2008_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}\CNT\NIC\NIC_2008_EGRA\NIC_2008_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}\CNT\NIC\NIC_2008_EGRA\NIC_2008_EGRA_v01_M_v01_A_HAD.dta", replace


