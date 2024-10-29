
set seed 10051990
set sortseed 10051990

use "${path}/CNT/MKD/MKD_2015_EGRA/MKD_2015_EGRA_v01_M/Data/Stata/2015_Albanian.dta", clear
drop if Age == "405680212" | Age == "8, 5"
ren (Region Grade Age Preschool Text01_correctperminute masked_StudentID) (region grade age tppri orf id)
gen female = 1 if Gender == "Zh"
replace female = 0 if Gender == "M"
*Developing variables of interest:
gen oral_read_score_zero = (Text01_correct == 0)
gen oral_read_score_pcnt = (Text01_correct/59)*100
foreach var of varlist Question0* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if `var'_n == 99 | `var'_n == 999
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Question0*)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/8)*100
keep year region id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen w = 0
gen n_res = 1
gen r_res = 1
gen language = "Albanian"
gen lang_instr = "Albanian"
destring age, replace
save "${path}/TEMP/Macedonia_2015_albanian.dta", replace

use "${path}/CNT/MKD/MKD_2015_EGRA/MKD_2015_EGRA_v01_M/Data/Stata/2015_Macedonian.dta", clear
drop if Age == "7 '" | Age == "8 i pol"
ren (Region Grade Age Preschool Text01_correctperminute masked_StudentID) (region grade age tppri orf id)
gen female = 1 if Gender == "Zh"
replace female = 0 if Gender == "M"
*Developing variables of interest:
gen oral_read_score_zero = (Text01_correct == 0)
gen oral_read_score_pcnt = (Text01_correct/58)*100
foreach var of varlist Question0* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if inlist(`var'_n,99,999)
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Question0*)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/8)*100
keep year region id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen w = 0
gen n_res = 1
gen r_res = 1
gen language = "Macedonian"
gen lang_instr = "Macedonia"
destring age, replace
save "${path}\TEMP\Macedonia_2015_macedonian.dta", replace


use "${path}\TEMP/Macedonia_2015_albanian.dta", clear
append using  "${path}\TEMP/Macedonia_2015_macedonian.dta"

gen country = "Macedonia, Republic of"
gen cntabb = "MKD"
gen idcntry = 807
codebook, compact
cf _all using "${path}\CNT\MKD\MKD_2015_EGRA\MKD_2015_EGRA_v01_M_v01_A_HAD.dta"
save   "${path}\CNT\MKD\MKD_2015_EGRA\MKD_2015_EGRA_v01_M_v01_A_HAD.dta", replace
