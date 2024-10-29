set seed 10051990
set sortseed 10051990


//2015
use "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M\Data\Stata\2015_kyr_2.dta", clear
*Data is weighted:
gen w = 1
ren (treatment masked_SchoolID masked_StudentID AdminDate_year rpr_fluency rpq_score Q1 Q6) (strata1 school_code id year orf read_comp_score_pcnt lang_instr tbook)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized)
gen female = 0 if gender == "B"
replace female = 1 if gender == "G"
replace tbook = "" if tbook == "BLANK" | tbook == " 1-10 11-40 "
*Variables of Interest:
gen read_comp_score_zero = (total_rpq_correct == 0)
drop if grade == "BLANK"
destring grade, replace
keep language country year strata1 school_code id grade female orf read_comp_score_zero read_comp_score_pcnt lang_instr tbook  wt_final w
gen n_res = 0
gen r_res = 1 
gen s_res = 1
drop year 
gen year = 2015
save "${path}\TEMP\EGRA_Kyrgyzstan_2015_kyr_2_s.dta", replace

use "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M\Data\Stata\2015_kyr_4.dta", clear
*Data is weighted:
gen w = 1
ren (treatment masked_SchoolID masked_StudentID AdminDate_year rpr_fluency rpq_socre Q1 Q6) (strata1 school_code id year orf read_comp_score_pcnt lang_instr tbook)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized)
gen female = 0 if gender == "B"
replace female = 1 if gender == "G"
*Variables of Interest:
gen read_comp_score_zero = (total_rpq_correct == 0)
drop if grade == "BLANK"
destring grade, replace
replace tbook = "" if tbook == "BLANK" | tbook == " 1-10 11-40 "
keep language country year strata1 school_code id grade female orf read_comp_score_zero read_comp_score_pcnt lang_instr tbook  wt_final w
gen n_res = 0
gen r_res = 1 
gen s_res = 1
drop year 
gen year = 2015
save "${path}\TEMP\EGRA_Kyrgyzstan_2015_kyr_4_s.dta", replace

use "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M\Data\Stata\2015_rus_2.dta", clear
*Data is weighted:
gen w = 1
ren (treatment masked_SchoolID masked_StudentID AdminDate_year rpr_fluency rpq_score Q1 Q6) (strata1 school_code id year orf read_comp_score_pcnt lang_instr tbook)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized)
gen female = 0 if gender == "B"
replace female = 1 if gender == "G"
replace tbook = "" if tbook == "BLANK" | tbook == " 1-10 11-40 "

*Variables of Interest:
gen read_comp_score_zero = (total_rpq_correct == 0)
drop if grade == "4"
destring grade, replace
keep language country year strata1 school_code id grade female orf read_comp_score_zero read_comp_score_pcnt lang_instr tbook  wt_final w
gen n_res = 0
gen r_res = 1 
gen s_res = 1
drop year 
gen year = 2015
save "${path}\TEMP\EGRA_Kyrgyzstan_2015_rus_2_s.dta", replace

use "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M\Data\Stata\2015_rus_4.dta", clear
*Data is weighted:
gen w = 1
ren (treatment masked_SchoolID masked_StudentID AdminDate_year rpr_fluency rpq_socre Q1 Q6) (strata1 school_code id year orf read_comp_score_pcnt lang_instr tbook)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized)
gen female = 0 if gender == "B"
replace female = 1 if gender == "G"
*Variables of Interest:
gen read_comp_score_zero = (total_rpq_correct == 0)
drop if grade == "2"
destring grade, replace
replace tbook = "" if tbook == "BLANK" | tbook == " 1-10 11-40 "

keep language country year strata1 school_code id grade female orf read_comp_score_zero read_comp_score_pcnt lang_instr tbook  wt_final w
gen n_res = 0
gen r_res = 1 
gen s_res = 1
drop year 
gen year = 2015
save "${path}\TEMP\EGRA_Kyrgyzstan_2015_rus_4_s.dta", replace

use "${path}\TEMP\EGRA_Kyrgyzstan_2015_kyr_2_s.dta", clear
append using "${path}\TEMP\EGRA_Kyrgyzstan_2015_kyr_4_s.dta"
append using "${path}\TEMP\EGRA_Kyrgyzstan_2015_rus_2_s.dta"
append using "${path}\TEMP\EGRA_Kyrgyzstan_2015_rus_4_s.dta"

replace country = "Kyrgyzstan"
gen cntabb = "KGZ"
gen idcntry = 417

codebook, compact
cf _all using "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\KGZ\KGZ_2015_EGRA\KGZ_2015_EGRA_v01_M_v01_A_HAD.dta", replace

