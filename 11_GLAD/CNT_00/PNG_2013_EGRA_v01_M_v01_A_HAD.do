
set seed 10051990
set sortseed 10051990

use "${path}/CNT/PNG/PNG_2013_EGRA/PNG_2013_EGRA_v01_M/Data/Stata/2013_WHP.dta", clear
*Variables requested by Nadir:
*Not available
*Renaming some variables:
ren (unfam_word_attempted unfam_word_score reading_attempted reading_score) (invent_word_attempted invent_word_score oral_read_attempted oral_read_score)
ren cphonpm clspm
*Analysis variables not available:
*Generating oral_read_score_pcnt
foreach var of varlist read_word* {
	replace `var' = 0 if `var' != 1
}
egen oral_read_score_pcnt = rowtotal(read_word*)
replace oral_read_score_pcnt = (oral_read_score_pcnt/59)*100
gen oral_read_score_zero = (orf == 0)
*Generating read_comp_score_zero:
gen read_comp_score_zero = (read_comp_score == 0)
replace read_comp_score_pcnt = read_comp_score_pcnt*100
keep country year month date urban id grade section female age school_code language consent list_comp_score list_comp_score_pcnt letter_attempted letter_score init_sound_score init_sound_score_pcnt letter_sound_attempted letter_sound_score fam_word_attempted fam_word_score invent_word_attempted invent_word_score oral_read_attempted oral_read_score read_comp_score read_comp_score_pcnt read_comp_attempted dict_score dict_score_pcnt clpm clspm  cwpm cnonwpm orf oral_read_score_pcnt oral_read_score_zero read_comp_score_zero
gen n_res = 0
gen r_res = 1
gen w = 0
gen region = "WHP"
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = language

replace country = "Papua New Guinea"
gen cntabb = "PNG"
gen idcntry = 598

codebook, compact
cf _all using "${path}\CNT\PNG\PNG_2013_EGRA\PNG_2013_EGRA_v01_M_v01_A_HAD"
save "${path}\CNT\PNG\PNG_2013_EGRA\PNG_2013_EGRA_v01_M_v01_A_HAD", replace
