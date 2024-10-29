*Tanzania :

set seed 10051990
set sortseed 10051990


use "${path}/CNT/TZA/TZA_2013_EGRA/TZA_2013_EGRA_v01_M/Data/Stata/2013.dta", clear

*Data is svyset and weighted:
ren wt_stage4 wt_final
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strat1) || stage2, fpc(fpc2) strata(strat2) || stage4, fpc(fpc4) strata(strat4) singleunit(scaled)
ren (wealthindex p_4) (tses0 tppri)
keep stage* strat* fpc* wt_final country school_code region urban date year month id female grade age tses0 e_clpm e_cwpm e_orf e_pa_init_sound_score_pcnt e_pa_init_sound_score_zero e_letter_score_pcnt e_letter_score_zero e_fam_word_score_pcnt e_fam_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero k_csspm k_cwpm k_cnonwpm k_orf k_syll_sound_score_pcnt k_syll_sound_score_zero k_fam_word_score_pcnt k_fam_word_score_zero k_invent_word_score_pcnt k_invent_word_score_zero k_oral_read_score_pcnt k_oral_read_score_zero k_read_comp_score_pcnt k_read_comp_score_zero k_list_comp_score_pcnt k_list_comp_score_zero k_dict_word_score_zero k_dict_word_score_pcnt caddpm csubpm quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero word_prob_score_pcnt word_prob_score_zero add_score_pcnt add_score_zero sub_score_pcnt sub_score_zero we_add_score_pcnt we_add_score_zero we_sub_score_pcnt we_sub_score_zero tppri p_18 p_21 p_22 p_23 p_24 p_25a p_25b p_25c p_25d p_25e p_25f p_25g p_25h p_25i
ren k_* *
gen n_res = 1
gen r_res = 0
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
gen language = "Kiswahili"
encode school_code, gen(school_code_n)
drop school_code
ren school_code_n school_code
bysort id: gen id_n = _n
drop id
ren id_n id
gen s_res = 1
gen lang_instr = "Kiswahili"
replace country = "Tanzania, United Republic of"
gen cntabb = "TZA"
gen idcntry = 834  

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*p_18 p_21 p_22 p_23 p_24 p_25a p_25b p_25c p_25d p_25e p_25f p_25g p_25h p_25i
numlabel, add
foreach var of varlist p_18 p_21 p_22 p_23 p_24 p_25a p_25b p_25c p_25d p_25e p_25f p_25g p_25h p_25i {
	tab `var'
	replace `var' = . if `var' == 888
}
*Creating dummies from categorical variables:
foreach var of varlist p_22 p_23 p_24 {
	tab `var', gen(`var'_d)
}
*Removing dummies for others: p_22_d6 p_23_d6 p_24_d5
drop p_22_d6 p_23_d6 p_24_d5
*Missings:
mdesc p_18 p_21 p_22 p_23 p_24 p_25a p_25b p_25c p_25d p_25e p_25f p_25g p_25h p_25i
*Filling in missings:
foreach var of varlist p_18 p_21 p_22_d* p_23_d* p_24_d* p_25a p_25b p_25c p_25d p_25e p_25f p_25g p_25h p_25i {
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
alphawgt p_18_std p_21_std p_22_d*_std p_23_d*_std p_24_d*_std p_25a_std p_25b_std p_25c_std p_25d_std p_25e_std p_25f_std p_25g_std p_25h_std p_25i_std [weight = wt_final], detail item
pca p_18_std p_21_std p_22_d*_std p_23_d*_std p_24_d*_std p_25a_std p_25b_std p_25c_std p_25d_std p_25e_std p_25f_std p_25g_std p_25h_std p_25i_std [weight = wt_final]
predict ESCS

*Generating Asset variables:
gen books_yn = p_18
gen electricity_yn = p_21
gen river_stream_yn = p_22_d1
gen well_borehole_yn = p_22_d2
gen tap_communal_yn = p_22_d3
gen tap_in_home_compound_yn = p_22_d4
gen tank_watertruck_yn = p_22_d5
gen firewood_yn = p_23_d1
gen coal_yn = p_23_d2
gen kerosene_yn = p_23_d3
gen gas_electric_yn = 1 if (p_23_d4 == 1 | p_23_d5 == 1)
replace gas_electric_yn = 0 if (p_23_d4 == 0 & p_23_d5 == 0)
gen bush_yn = p_24_d1
gen pit_toilet_yn = p_24_d2
gen toilet_yn = 1 if (p_24_d3 == 1 | p_24_d4 == 1)
replace toilet_yn = 0 if (p_24_d3 == 0 & p_24_d4 == 0)
gen radio_yn = p_25a
gen mobile_yn = p_25b
gen television_yn = p_25c
gen computer_yn = p_25d
gen fridge_yn = p_25e
gen bicycle_yn = p_25f
gen motorcycle_yn = p_25g
gen four_wheeler_yn = p_25h
gen animals_yn = p_25i

*Weight variables:
gen strata1 = strat1
encode stage1, gen(su1)
encode stage2, gen(su2)
gen strata2 = strat2
gen strata3 = strat4
gen su3 = stage4



save "${path}/CNT/TZA/TZA_2013_EGRA/TZA_2013_EGRA_v01_M_v01_A_BASE/TZA_2013_EGRA_v01_M_v01_A_BASE.dta", replace
keep cntabb idcntry n_res r_res w language s_res lang_instr strata* su* fpc* wt_final country school_code region urban date year month id female grade age tses0 e_clpm e_cwpm e_orf e_pa_init_sound_score_pcnt e_pa_init_sound_score_zero e_letter_score_pcnt e_letter_score_zero e_fam_word_score_pcnt e_fam_word_score_zero e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero csspm cwpm cnonwpm orf syll_sound_score_pcnt syll_sound_score_zero fam_word_score_pcnt fam_word_score_zero invent_word_score_pcnt invent_word_score_zero oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero list_comp_score_pcnt list_comp_score_zero dict_word_score_zero dict_word_score_pcnt caddpm csubpm quant_comp_score_pcnt quant_comp_score_zero miss_num_score_pcnt miss_num_score_zero word_prob_score_pcnt word_prob_score_zero add_score_pcnt add_score_zero sub_score_pcnt sub_score_zero we_add_score_pcnt we_add_score_zero we_sub_score_pcnt we_sub_score_zero tppri *_yn
 
codebook, compact
cf _all using "${path}/CNT/TZA/TZA_2013_EGRA/TZA_2013_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 strata* su* school_code id using "${path}/CNT/TZA/TZA_2013_EGRA/TZA_2013_EGRA_v01_M_v01_A_HAD.dta", update replace (nothing updated)
save "${path}/CNT/TZA/TZA_2013_EGRA/TZA_2013_EGRA_v01_M_v01_A_HAD.dta", replace
