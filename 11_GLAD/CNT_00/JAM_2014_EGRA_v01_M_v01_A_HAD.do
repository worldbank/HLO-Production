*Jamaica:
set seed 10051990
set sortseed 10051990

import excel using "${path}/CNT/JAM/JAM_2014_EGRA/JAM_2014_EGRA_v01_M/Data/Original/2014.xlsx", firstrow clear
ren (A SchoolNum) (id school_code)
gen female = 1 if Sex == "Female"
replace female = 0 if Sex == "Male"
ren Grade grade
gen read_comp_score_pcnt = (ComprehensionScore2/5)*100
replace read_comp_score_pcnt = 0 if ComprehensionScore1 == 0
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt) 
gen n_res = 0
gen r_res = 0
gen w = 0
gen lang = "English"
gen lang_instr = lang
keep school_code id lang lang_instr female grade read_comp_score_pcnt w n_res r_res
gen country = "Jamaica"
gen cntabb = "JAM"
gen idcntry = 388
gen year = 2014
*Variables for ESCS not available.

codebook, compact
cf _all using "${path}\CNT\JAM\JAM_2014_EGRA\JAM_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\JAM\JAM_2014_EGRA\JAM_2014_EGRA_v01_M_v01_A_HAD.dta", replace

