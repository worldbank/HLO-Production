* Mali

set seed 10051990
set sortseed 10051990
use "${path}/CNT/MLI/MLI_2009_EGRA/MLI_2009_EGRA_v01_M/Data/Stata/2009.dta", clear

*Data is survey set.
gen w = 1
ren exit_interview20 tppri
keep w country year month cap fpc* school_code school_type id grade female age language clpm cwpm cnonwpm orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tppri wt_final w
*Sampling Method:
gen n_res = 0
*Confirm with wherever we got this data from that it is nationally representative.
gen r_res = 0
gen l_res = 1
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
gen lang_instr = "French"
decode language, gen(language_s)
drop language
ren language_s language
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
save "${path}\TEMP/EGRA_Mali_2009_s.dta", replace

use "${path}/CNT/MLI/MLI_2009_EGRA/MLI_2009_EGRA_v01_M/Data/Stata/2009_a.dta", clear
*Data is not survey set.
gen w = 0
ren (exit_interview_kindergarden masked_student_id masked_school_code) (tppri id school_code) 
keep w country year  school_type school_code id grade female age language orf oral_read_score_pcnt oral_read_score_zero tppri
replace oral_read_score_pcnt = oral_read_score_pcnt*100
*Sampling Method:
gen n_res = 0 
gen r_res = 0
gen s_res = 1
gen lang_instr = "French"
decode language, gen(language_s)
drop language
ren language_s language
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type

save "${path}\TEMP/EGRA_Mali_2009_a_s.dta", replace

use "${path}/CNT/MLI/MLI_2009_EGRA/MLI_2009_EGRA_v01_M/Data/Stata/2009_f.dta", clear
*Data is survey set.
gen w = 1
ren (district_svy curriculum masked_school_code masked_student_id) (su1 Strata1 school_code id) 
svyset su1 [pweight = wt_final], fpc(fpc1) || school_code, fpc(fpc2) strata(Strata1) || id, fpc(fpc3) strata(grade) singleunit(scaled) vce(linearized)
*Counldn't find because variables in french
keep w country year Strata1 grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero su1 Strata1 school_code id wt_final fpc* 
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
*Sampling Method:
gen n_res = 0 
gen r_res = 0
gen s_res = 1
gen lang_instr = "French"
decode language, gen(language_s)
drop language
ren language_s language
drop su1

***************************************************************
*Development of ESCS variable
***************************************************************

*Identifying variables:
*Variables not available
save "${path}\TEMP/EGRA_Mali_2009_f_s.dta", replace





	use "${path}\TEMP/EGRA_Mali_2009_s.dta"
	append using "${path}\TEMP/EGRA_Mali_2009_f_s.dta"
	append using "${path}\TEMP/EGRA_Mali_2009_a_s.dta"

gen idcntry = 466
gen cntabb = "MLI"
cf _all using "${path}\CNT\MLI\MLI_2009_EGRA\MLI_2009_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\MLI\MLI_2009_EGRA\MLI_2009_EGRA_v01_M_v01_A_HAD.dta", replace

