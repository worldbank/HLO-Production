*Nigeria
*English

set seed 10051990
set sortseed 10051990

use "${path}/CNT/NGA/NGA_2010_EGRA/NGA_2010_EGRA_v01_M/Data/Stata/2010.dta", clear
*Variables requested by Nadir are not available
keep country year month date state reg_treat district school_code school_type id grade female age language consent clpm cwpm cnonwpm orf letter_score letter_score_pcnt letter_score_zero letter_attempted letter_attempted_pcnt fam_word_score fam_word_score_pcnt fam_word_score_zero fam_word_attempted fam_word_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score oral_read_score_pcnt oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt wt_final reg_treat fpc1 fpc2 fpc3
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 0
gen r_res = 0
gen w = 1
drop language
gen language = "English"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
gen lang_instr = "English"

replace country = "Nigeria"
gen cntabb = "NGA"
gen idcntry = 566

codebook, compact
cf _all using "${path}\CNT\NGA\NGA_2010_EGRA\NGA_2010_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\NGA\NGA_2010_EGRA\NGA_2010_EGRA_v01_M_v01_A_HAD.dta", replace
