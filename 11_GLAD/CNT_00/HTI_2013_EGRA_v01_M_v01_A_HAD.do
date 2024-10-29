
set seed 10051990
set sortseed 10051990


use "${path}/CNT/HTI/HTI_2013_EGRA/HTI_2013_EGRA_v01_M/Data/Stata/2013.dta", clear
*Data is weighted
*SES is available
ren (f_oral_vocab* dict_word_*) (f_vocab_word* dict_*)
ren s_9_END lan_at_home
keep country year region urban strata* month strata* fpc* cluster school_code ht_school_type id cluster fpc* grade age lan_at_home female start_time end_time language consent *clspm *clpm *cwpm *cnonwpm *orf *pa_init_sound_score *pa_init_sound_score_pcnt *pa_init_sound_score_zero *pa_init_sound_attempted *pa_init_sound_attempted_pcnt *letter_score *letter_score_pcnt *letter_score_zero *letter_attempted *letter_attempted_pcnt *letter_sound_score *letter_sound_score_pcnt *letter_sound_score_zero *letter_sound_attempted *letter_sound_attempted_pcnt *fam_word_score *fam_word_score_pcnt *fam_word_score_zero *fam_word_attempted *fam_word_attempted_pcnt *invent_word_score *invent_word_score_pcnt *invent_word_score_zero *invent_word_attempted *invent_word_attempted_pcnt *oral_read_score_pcnt *oral_read_score *oral_read_score_zero *oral_read_attempted *oral_read_attempted_pcnt *read_comp_score *read_comp_score_pcnt *read_comp_score_zero *read_comp_attempted *read_comp_attempted_pcnt *list_comp_score *list_comp_score_pcnt *list_comp_score_zero *list_comp_attempted *list_comp_attempted_pcnt *dict_score *dict_score_pcnt *dict_attempted *dict_attempted_pcnt *dict_score_zero *vocab_word_score *vocab_word_score_pcnt *vocab_word_attempted *vocab_word_attempted_pcnt *vocab_word_score_zero wt_final SES SES_quintiles lan_at_home 

foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 1
*Converting french variables into fr
ren f_* fr_*
tostring region, replace
replace region = "Cap-Haitien Corridor" if region == "1"
replace region = "Saint-Marc Corridor" if region == "3"
replace region = "Port-Au-Prince Corridor" if region == "2"
decode language, gen(language_s)
drop language
ren language_s language
gen s_res = 1
gen lang_instr = "French"
replace country = "Haiti"
gen cntabb = "HTI"
gen idcntry = 332
/*Identifying variables for ESCS:
*s_32_END s_37_END s_38_END s_39_END s_40_END s_41_END s_42_END s_43_END s_44_END s_45_END s_46_END s_47_END s_48_END s_49_54_toilet_1_END s_49_54_toilet_2_END s_49_54_toilet_3_END s_49_54_toilet_4_END s_49_54_toilet_5_END s_55_59_cooking_1_END s_55_59_cooking_2_END s_55_59_cooking_3_END s_55_59_cooking_4_END s_60_69_water_1_END s_60_69_water_2_END s_60_69_water_3_END s_60_69_water_4_END s_60_69_water_5_END s_60_69_water_6_END s_60_69_water_7_END s_60_69_water_8_END s_60_69_water_9_END s_70_74_made_from_1_END s_70_74_made_from_2_END s_70_74_made_from_3_END
foreach var of varlist s_32_END s_37_END s_38_END s_39_END s_40_END s_41_END s_42_END s_43_END s_44_END s_45_END s_46_END s_47_END s_48_END s_49_54_toilet_1_END s_49_54_toilet_2_END s_49_54_toilet_3_END s_49_54_toilet_4_END s_49_54_toilet_5_END s_55_59_cooking_1_END s_55_59_cooking_2_END s_55_59_cooking_3_END s_55_59_cooking_4_END s_60_69_water_1_END s_60_69_water_2_END s_60_69_water_3_END s_60_69_water_4_END s_60_69_water_5_END s_60_69_water_6_END s_60_69_water_7_END s_60_69_water_8_END s_60_69_water_9_END s_70_74_made_from_1_END s_70_74_made_from_2_END s_70_74_made_from_3_END {
	tab `var'
}
*Some items do not make sense or include others: s_46_END s_49_54_toilet_5_END s_55_59_cooking_4_END s_60_69_water_5_END
mdesc s_32_END s_37_END s_38_END s_39_END s_40_END s_41_END s_42_END s_43_END s_44_END s_45_END s_47_END s_48_END s_49_54_toilet_1_END s_49_54_toilet_2_END s_49_54_toilet_3_END s_49_54_toilet_4_END s_55_59_cooking_1_END s_55_59_cooking_2_END s_55_59_cooking_3_END s_60_69_water_1_END s_60_69_water_2_END s_60_69_water_3_END s_60_69_water_4_END s_60_69_water_6_END s_60_69_water_7_END s_60_69_water_8_END s_60_69_water_9_END s_70_74_made_from_1_END s_70_74_made_from_2_END s_70_74_made_from_3_END 
*Data missing for 2013:
*Only calculate ESCS for 2014:
*Dropped from the database as no reading comprehension score for french langauge.
*/

codebook, compact
cf _all using "${path}/CNT/HTI/HTI_2013_EGRA/HTI_2013_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/HTI/HTI_2013_EGRA/HTI_2013_EGRA_v01_M_v01_A_HAD.dta", replace

/*
//append
use "${gsdData}/0-RawOutput/EGRA_Haiti_2012_s.dta", replace
append using "${gsdData}/0-RawOutput/EGRA_Haiti_2012_s_fr.dta"
append using "${gsdData}/0-RawOutput/EGRA_Haiti_2014_s.dta"

replace country = "Haiti"
gen cntabb = "HTI"
gen idcntry = 332

save "${gsdData}/0-RawOutput/merged/Haiti.dta", replace
