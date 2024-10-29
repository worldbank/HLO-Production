* PNG:

set seed 10051990
set sortseed 10051990

use "${path}\CNT\PNG\PNG_2011_EGRA\PNG_2011_EGRA_v01_M/Data/Stata/2011_Madang.dta", clear
*Renaming some variables:
ren cphonpm clspm
ren WEIGHT_Madang wt_final
*Analysis variables not available:
*Generating oral_read_score_pcnt
*Replacing non-response by 0:
foreach var of varlist read_word* {
	replace `var' = 0 if `var' != 1
}
egen oral_read_score_pcnt = rowtotal(read_word*)
replace oral_read_score_pcnt = (oral_read_score_pcnt/59)*100
gen oral_read_score_zero = (orf == 0)
*Generating read_comp_score_zero:
replace read_comp_score = 0 if missing(read_comp_score)
gen read_comp_score_zero = (read_comp_score == 0)
keep country year month date school_code region district urban id grade female start_time age end_time  consent oral_read_score_pcnt oral_read_score_zero read_comp_score_zero letter_attempted letter_score init_sound_score init_sound_score_pcnt letter_sound_attempted letter_sound_score fam_word_score fam_word_attempted unfam_word_attempted unfam_word_score reading_attempted read_comp_score read_comp_score_pcnt read_comp_attempted list_comp_score list_comp_score_pcnt dict_score dict_score_pcnt clpm cwpm cnonwpm orf wt_final
replace read_comp_score_pcnt = read_comp_score_pcnt*100
svyset school_code [pweight = wt_final] || id , strata(grade)  singleunit(scaled)
gen n_res = 0
gen r_res = 1
gen w = 1
drop region
gen region = "Madang"
drop district
gen language = "English"
gen s_res = 1
gen lang_instr = "English"
replace year = 2011 if missing(year)
replace country = "Papua New Guinea"
gen cntabb = "PNG"
gen idcntry = 598

codebook, compact
cf _all using "${path}\CNT\PNG\PNG_2011_EGRA\PNG_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\PNG\PNG_2011_EGRA\PNG_2011_EGRA_v01_M_v01_A_HAD.dta", replace


