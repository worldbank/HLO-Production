set seed 10051990

set sortseed 10051990


use "${path}/CNT/TJK/TJK_2016_EGRA/TJK_2016_EGRA_v01_M/Data/Stata/2016.dta", clear
gen year = 2016
*Variables requested by Nadir:
ren (q2 q31_4_other) (lan_at_home tppri)
*Recoding variables:
replace gender = 0 if gender == 1
replace gender = 1 if gender == 2
ren gender female 
ren type urban
replace urban = "1" if urban == "urban"
replace urban = "0" if urban == "rural"
destring urban, replace
ren (masked_student_ID masked_school_ID) (id school_code)
svyset school_code [pweight = wt_final], strata(treat)
*Generating variables for analysis:
gen fam_word_score_zero = (fw_correct == 0)
gen invent_word_score_zero = (ufw_correct == 0)
gen oral_read_score_zero = (rp_correct == 0)
gen read_comp_score_zero = (total_rpc_correct == 0)
gen list_comp_score_zero = (total_lc_correct == 0)
gen dict_score_zero = (total_dct_correct == 0)
gen letter_score_zero = (ln_correct == 0)
gen pa_init_letter_sound_score_zero = (total_ils_correct == 0)
gen oral_read_score_pcnt = (rp_correct/79)*100
*Variables for analysis:
ren (fw_permin ufw_permin ov_score rp_permin rpc_score lc_score dct_score ln_permin ils_score) (cwpm cnonwpm vocab_word_score_pcnt orf read_comp_score_pcnt list_comp_score_pcnt dict_score_pcnt clpm pa_init_letter_sound_score_pcnt)
destring grade, replace
keep year region school_code treat grade language urban consent lan_at_home tppri female  id wt_final *_zero cwpm cnonwpm vocab_word_score_pcnt oral_read_score_pcnt orf read_comp_score_pcnt list_comp_score_pcnt dict_score_pcnt clpm pa_init_letter_sound_score_pcnt q4_1_newspapers q4_2_magazines q4_4_other q4_other q4_3_religious_books q4_5_no_for_all_options q4_6_books q6 q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q19_computer_with_internet q20_automobile q21_tractor q22_truck q23 q24 q25

*Making pcnts consistent with other data
gen n_res = 0
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
replace language = "Russian" if language == "R"
replace language = "Tajik" if language == "T"
drop consent
gen consent = 1
gen s_res = 1
gen lang_instr = "Tajik"

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*q4_1_newspapers q4_2_magazines q4_4_other q4_other q4_3_religious_books q4_5_no_for_all_options q4_6_books q6 q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q19_computer_with_internet q20_automobile q21_tractor q22_truck q23 q24 q25
numlabel, add
foreach var of varlist q4_1_newspapers q4_2_magazines q4_4_other q4_other q4_3_religious_books q4_5_no_for_all_options q4_6_books q6 q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q19_computer_with_internet q20_automobile q21_tractor q22_truck q23 q24 q25 {
	tab `var'
}
*Dropping variable coded for other q4_other q4_5_no_for_all_options
*Creating dummies for categorical variables:
tab q6, gen(q6_d)
foreach var of varlist  q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q19_computer_with_internet q20_automobile q21_tractor q22_truck {
	replace `var' = . if `var' == 3
}
gen roomspermember = q25/q23
mdesc roomspermember q6 q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q19_computer_with_internet q20_automobile q21_tractor q22_truck q6 q4_6_books q4_3_religious_books q4_1_newspapers q4_2_magazines
*q6 and q19 have high missing values. Dropping them.
*Filling in missing:
foreach var of varlist roomspermember q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q20_automobile q21_tractor q22_truck q4_6_books q4_3_religious_books q4_1_newspapers q4_2_magazines {
	bysort region school_code : egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')

	egen `var'_mean_cnt = mean(`var')
	
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean if missing(`var') & `var'_count > 10 & !missing(`var'_count)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
mdesc roomspermember q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q20_automobile q21_tractor q22_truck q4_6_books q4_3_religious_books q4_1_newspapers q4_2_magazines
alphawgt roomspermember q11_radio q12_home_telephone q13_mobile_phone q14_television q15_refrigerator q16_bicycle q17_motor_cycle q18_computer q20_automobile q21_tractor q22_truck q4_6_books q4_3_religious_books q4_1_newspapers q4_2_magazines [weight = wt_final], detail item
pca roomspermember_std q11_radio_std q12_home_telephone_std q13_mobile_phone_std q14_television_std q15_refrigerator_std q16_bicycle_std q17_motor_cycle_std q18_computer_std q20_automobile_std q21_tractor_std q22_truck_std q4_6_books_std q4_3_religious_books_std q4_1_newspapers_std q4_2_magazines_std
predict ESCS

*Generating Assets Variable:
gen radio_yn = q11_radio
gen telephone_yn = q12_home_telephone
gen mobile_yn = q13_mobile_phone
gen television_yn = q14_television
gen fridge_yn = q15_refrigerator
gen bicycle_yn = q16_bicycle
gen motorcycle_yn = q17_motor_cycle
gen computer_yn = q18_computer
gen automobile_yn = q20_automobile
gen tractor_yn = q21_tractor
gen truck_yn = q22_truck
gen books_yn = q4_6_books
gen religious_books_yn = q4_3_religious_books
gen newspapers_yn = q4_1_newspapers
gen magazines_yn = q4_2_magazines



gen country = "Tajikistan"
gen cntabb = "TJK"
gen idcntry = 762
save "${path}/CNT/TJK/TJK_2016_EGRA/TJK_2016_EGRA_v01_M_v01_A_BASE/TJK_2016_EGRA_v01_M_v01_A_BASE.dta", replace


keep country cntabb idcntry n_res r_res w s_res lang_instr year region school_code treat grade language urban consent lan_at_home tppri female  id wt_final *_zero cwpm cnonwpm vocab_word_score_pcnt oral_read_score_pcnt orf read_comp_score_pcnt list_comp_score_pcnt dict_score_pcnt clpm pa_init_letter_sound_score_pcnt *_yn roomspermember

codebook, compact
cf _all using "${path}/CNT/TJK/TJK_2016_EGRA/TJK_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/TJK/TJK_2016_EGRA/TJK_2016_EGRA_v01_M_v01_A_HAD.dta", replace

