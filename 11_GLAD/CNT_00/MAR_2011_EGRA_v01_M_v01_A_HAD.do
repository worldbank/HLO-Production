
set seed 10051990
set sortseed 10051990

* Morocco

use "${path}\CNT\MAR\MAR_2011_EGRA\MAR_2011_EGRA_v01_M\Data\Stata\2011.dta", clear
drop if missing(language)
keep country year month date grade id fpc* female age language consent clpm cnonwpm orf cmissnumpm cqcpm caddpm csubpm cnumidpm letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt num_id_score num_id_score_pcnt num_id_score_zero num_id_attempted num_id_attempted_pcnt quant_comp_score quant_comp_score_pcnt quant_comp_score_zero quant_comp_attempted quant_comp_attempted_pcnt miss_num_score miss_num_score_pcnt miss_num_score_zero miss_num_attempted miss_num_attempted_pcnt add_score add_score_pcnt add_score_zero add_attempted add_attempted_pcnt sub_score sub_score_pcnt sub_score_zero sub_attempted sub_attempted_pcnt school_code final_wt fpc1 
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
*Sampling Method:
gen n_res = 0
gen r_res = 0
gen w = 1

replace orf = 0 if missing(orf)
decode language, gen(language_s)
drop language
ren language_s language
ren final_wt wt_final
gen s_res = 1
gen lang_instr = "Arabic"
replace country = "Morocco"
gen cntabb = "MAR"
gen idcntry = 504
codebook, compact
cf _all using "${path}\CNT\MAR\MAR_2011_EGRA\MAR_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\MAR\MAR_2011_EGRA\MAR_2011_EGRA_v01_M_v01_A_HAD.dta", replace
