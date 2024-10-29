*Liberia

global path = "N:\GDB\HLO_Database" // USER = SAI


*Data is corrupted by mi set. Remove from analysis. Not nationally representative anyway.



use "${gsdRawData}/EGRA/Liberia/Data/2010.dta", clear
*Renaming some variables:
ren sublvl1* sub*
ren addlvl1* add*
ren sublvl2* we_sub*
ren addlvl2* we_add*
ren (pa_df_init_snd_score pa_df_init_snd_score_zero pa_df_init_snd_score_pcnt mult_score mult_score_zero) (pa_init_sound_score pa_init_sound_score_zero pa_init_sound_score_pcnt we_mult_score we_mult_score_zero)
keep country country year date district language grade female age consent clpm cwpm cnonwpm orf pa_init_sound_score pa_init_sound_score_zero pa_init_sound_score_pcnt letter_score letter_score_zero fam_word_score fam_word_score_zero invent_word_score invent_word_score_zero read_comp_score_zero read_comp_score_pcnt num_id_score num_id_score_zero quant_comp_score quant_comp_score_zero miss_num_score miss_num_score_zero sub_score add_score sub_score_zero add_score_zero we_add_score we_add_score_zero we_sub_score we_sub_score_zero we_mult_score we_mult_score_zero frac_score frac_score_zero frac_score_pcnt frac_attempted 
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 0
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = language
drop district
replace country = "Liberia"
gen cntabb = "LBR"
gen idcntry = 430
*save "${path}\CNT\LBR\LBR_2010_EGRA\LBR_2010_EGRA_v01_M_v01_A_HAD.dta", replace


