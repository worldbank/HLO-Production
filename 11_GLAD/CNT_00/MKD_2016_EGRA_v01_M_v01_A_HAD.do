

set seed 10051990
set sortseed 10051990
use "${path}/CNT/MKD/MKD_2016_EGRA/MKD_2016_EGRA_v01_M/Data/Stata/2016_Albanian.dta", clear
drop year
gen year = 2016
replace Age = "7.5" if Age == "7,5"
replace Age = "7.7" if Age == "7,7"
replace Age = "8.5" if Age == "8,5"
destring Age, replace
ren (Region Grade Age Preschool Oral_read1_CPM masked_StudentID) (region grade age tppri orf id)
gen female = 1 if Gender == 1
replace female = 0 if Gender == 2
*Developing variables of interest:
gen oral_read_score_zero = (Oral_read1_score == 0)
gen oral_read_score_pcnt = (Oral_read1_score/67)*100
foreach var of varlist Read_comp1_question* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if `var'_n == 99
	replace `var'_n = 0 if missing(`var'_n)
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Read_comp1_question*)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/10)*100
keep year id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen w = 0
gen n_res = 1
gen r_res = 1
gen language = "Albanian"
gen lang_instr = "Albanian"
save "${path}\TEMP/Macedonia_2016_albanian.dta", replace

use "${path}/CNT/MKD/MKD_2016_EGRA/MKD_2016_EGRA_v01_M/Data/Stata/2016_Macedonian.dta", clear
drop year
gen year = 2016
replace Age = subinstr(Age,",",".",3)
destring Age, replace
ren (Region Grade Age Preschool Oral_read1_CPM masked_StudentID) (region grade age tppri orf id)
gen female = 1 if Gender == 1
replace female = 0 if Gender == 2
*Developing variables of interest:
gen oral_read_score_zero = (Oral_read1_score == 0)
gen oral_read_score_pcnt = (Oral_read1_score/67)*100
foreach var of varlist Read_comp1_question* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if `var'_n == 99
	replace `var'_n = 0 if missing(`var'_n)
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Read_comp1_question*)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/10)*100
keep year id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen w = 0
gen n_res = 1
gen r_res = 1
gen language = "Macedonian"
gen lang_instr = "Macedonian"
save "${path}\TEMP/Macedonia_2016_macedonian.dta", replace

use "${path}/CNT/MKD/MKD_2016_EGRA/MKD_2016_EGRA_v01_M/Data/Stata/2016_turkish.dta", clear
replace year = 2016 if missing(year)
ren (Region Grade Age Preschool Oral_read1_CPM masked_StudentID) (region grade age tppri orf id)
replace orf = 0 if missing(orf)
gen female = 1 if Gender == 1
replace female = 0 if Gender == 2
*Developing variables of interest:
gen oral_read_score_zero = (Oral_read1_score == 0)
gen oral_read_score_pcnt = (Oral_read1_score/68)*100
replace oral_read_score_pcnt = 0 if missing(oral_read_score_pcnt)
foreach var of varlist Read_comp1_question* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if `var'_n == 99
	replace `var'_n = 0 if missing(`var'_n)
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Read_comp1_question*)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/10)*100
keep year id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen w = 0
gen n_res = 1
gen r_res = 1
gen language = "Turkish"
gen lang_instr = "Turkish"
save "${path}\TEMP/Macedonia_2016_turkish.dta", replace

	use "${path}\TEMP/Macedonia_2016_albanian.dta", clear
	append using "${path}\TEMP/Macedonia_2016_macedonian.dta"
	append using "${path}\TEMP/Macedonia_2016_turkish.dta"
	
gen country = "Macedonia, Republic of"
gen cntabb = "MKD"
gen idcntry = 807
codebook, compact
cf _all using "${path}\CNT\MKD\MKD_2016_EGRA\MKD_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\MKD\MKD_2016_EGRA\MKD_2016_EGRA_v01_M_v01_A_HAD.dta", replace
