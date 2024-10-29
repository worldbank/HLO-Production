* Myanmar

set seed 10051990
set sortseed 10051990

use "${path}/CNT/MMR/MMR_2014_EGRA/MMR_2014_EGRA_v01_M/Data/Stata/2014.dta", clear
gen language = "Myanmar"
ren sq6_attend_pre_school tppri
ren sq1_home_language lan_at_home
recode wealthgr (0=1) (1 = 2) (2=3) (3=4) (4 = 5), gen(tses0)
*Year is missing
gen year = 2014
*Renaming Some variables:
ren (starttime uniquestudentid clnpm letter_name_attempted cfamwpm init_sound_score init_sound_attempted init_sound_score_att_pcnt init_sound_score_pcnt clspm_score clspm_score_attempted_pcnt cfamwpm_score cfamwpm_score_attempted_pcnt cnonwpm_attempted cnonwpm_score cnonwpm_score_attempted_pcnt orf_score orf_score_attempted_pcnt dict_word_attempted dict_word_score) (start_time id clpm letter_attempted cwpm pa_init_sound_score pa_init_sound_attempted pa_init_sound_attempted_pcnt pa_init_sound_score_pcnt letter_sound_score letter_sound_attempted_pcnt fam_word_score fam_word_attempted_pcnt invent_word_attempted invent_word_score invent_word_attempted_pcnt oral_read_score oral_read_attempted_pcnt dict_attempted dict_score)
*Renaming survey set variables:
ren (studentweight schoolsinstratum numberofpupilsenrolled) (wt_final fpc1 fpc2)
*Generating missing variables required for analysis:
gen oral_read_score_zero = (oral_read_score==0)
replace read_comp_score = 0 if missing(read_comp_score)
gen read_comp_score_zero = (read_comp_score==0)
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt)
keep year id consent school_code language date clpm fpc* stratum letter_attempted clspm letter_sound_attempted cwpm fam_word_attempted cnonwpm orf oral_read_attempted end_time letter_sound_score letter_sound_attempted_pcnt pa_init_sound_attempted pa_init_sound_score pa_init_sound_attempted_pcnt pa_init_sound_score_pcnt fam_word_score fam_word_attempted_pcnt invent_word_attempted invent_word_score invent_word_attempted_pcnt oral_read_attempted_pcnt read_comp_attempted read_comp_score read_comp_score_attempted_pcnt read_comp_score_pcnt list_comp_attempted list_comp_score list_comp_score_attempted_pcnt list_comp_score_pcnt dict_attempted dict_score female grade start_time wt_final lan_at_home oral_read_score_zero read_comp_score_zero tses0 sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove
svyset school_code [pweight = wt_final], fpc(fpc1) strata(stratum) || _n, fpc(fpc2) singleunit(scaled)
gen n_res = 0
gen r_res = 1
gen w = 1
gen s_res = 1
gen lang_instr = "Myanmar"
gen tlang = 1 if lan_at_home == 6
replace tlang = 0 if missing(tlang)

**********************************************************************
*Development of ESCS Variable
**********************************************************************
*Identification of variables:
*sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove

numlabel, add
foreach var of varlist sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove {
	tab `var'
}
*Creating dummies of categorical variables:
tab sq20_14cookingstove, gen(sq20_14cookingstove_d)
label var sq20_14cookingstove_d2 "Open Fire Stove (Non-Improved)"
label var sq20_14cookingstove_d3 "Charcoal Stove (Non-Improved)"
label var sq20_14cookingstove_d4 "Electric or Gas Stove (Improved)"
label var sq20_14cookingstove_d5 "Kerosene Oil Stove (Improved)"

mdesc sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove
*No missings

alphawgt sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove_d2 sq20_14cookingstove_d3 sq20_14cookingstove_d4 sq20_14cookingstove_d5 [weight = wt_final], detail item
foreach var of varlist sq20_1radio sq20_2television sq20_3bed sq20_4table sq20_5chair sq20_6clock sq20_7mobile_phone sq20_8bike sq20_9motorcycle sq20_10canoe_boat sq20_11implement_animal sq20_12implement_motorized sq20_13largeanimal sq20_14cookingstove_d2 sq20_14cookingstove_d3 sq20_14cookingstove_d4 sq20_14cookingstove_d5 {
	egen `var'_std = std(`var')
}

pca sq20_1radio_std sq20_2television_std sq20_3bed_std sq20_4table_std sq20_5chair_std sq20_6clock_std sq20_7mobile_phone_std sq20_8bike_std sq20_9motorcycle_std sq20_10canoe_boat_std sq20_11implement_animal_std sq20_12implement_motorized_std sq20_13largeanimal_std sq20_14cookingstove_d2_std sq20_14cookingstove_d3_std sq20_14cookingstove_d4_std sq20_14cookingstove_d5_std [weight = wt_final]
predict ESCS

*Generation of Asset variables:
gen radio_yn = sq20_1radio
gen television_yn = sq20_2television
gen bed_yn = sq20_3bed
gen study_table_yn = sq20_4table
gen study_chair_yn = sq20_5chair
gen clock_yn = sq20_6clock
gen mobile_yn = sq20_7mobile_phone
gen bicycle_yn = sq20_8bike
gen motorcycle_yn = sq20_9motorcycle 
gen canoe_yn = sq20_10canoe_boat
gen animal_yn = sq20_11implement_animal
gen four_wheeler_yn = sq20_12implement_motorized
gen large_animal_yn = sq20_13largeanimal
gen firewood_yn = sq20_14cookingstove_d2
gen coal_yn = sq20_14cookingstove_d3
gen gas_electric_stove_yn = sq20_14cookingstove_d4
gen kerosene_yn = sq20_14cookingstove_d5


gen country = "Myanmar"
gen cntabb = "MMR"
gen idcntry = 104

save "${path}/CNT/MMR/MMR_2014_EGRA/MMR_2014_EGRA_v01_M_v01_A_BASE/MMR_2014_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res r_res w s_res lang_instr tlang year id consent school_code language date clpm fpc* stratum letter_attempted clspm letter_sound_attempted cwpm fam_word_attempted cnonwpm orf oral_read_attempted end_time letter_sound_score letter_sound_attempted_pcnt pa_init_sound_attempted pa_init_sound_score pa_init_sound_attempted_pcnt pa_init_sound_score_pcnt fam_word_score fam_word_attempted_pcnt invent_word_attempted invent_word_score invent_word_attempted_pcnt oral_read_attempted_pcnt read_comp_attempted read_comp_score read_comp_score_attempted_pcnt read_comp_score_pcnt list_comp_attempted list_comp_score list_comp_score_attempted_pcnt list_comp_score_pcnt dict_attempted dict_score female grade start_time wt_final lan_at_home oral_read_score_zero read_comp_score_zero *_yn

codebook, compact
cf _all using "${path}/CNT/MMR/MMR_2014_EGRA/MMR_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/MMR/MMR_2014_EGRA/MMR_2014_EGRA_v01_M_v01_A_HAD.dta", replace



