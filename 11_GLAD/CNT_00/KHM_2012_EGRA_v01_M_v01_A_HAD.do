
set seed 10051990
set sortseed 10051990

*import excel using "${gsdRawData}\EGRA\Cambodia\Data\2012_1_2.xlsx", firstrow clear sheet("EGRA PILOT GR 1_2")
use "${path}\CNT\KHM\KHM_2012_EGRA\KHM_2012_EGRA_v01_M\Data\Stata\2012_1_2.dta", clear
drop if GRADE == 9
*Develop variables of interest:
foreach var of varlist SOPHY? {
	destring `var', replace
}
egen read_comp_score = rowtotal(SOPHY?)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/5)*100
ren (SCHOOL GRADE) (school_code grade)
keep school_code grade read_comp_score_pcnt read_comp_score_zero
gen year = 2012
bysort school_code: gen id = _n
gen n_res = 1 
gen r_res = 1
gen w = 0
save "${path}\TEMP\EGRA_Cambodia_2012_1_2_s.dta", replace


*import excel using "${gsdRawData}\EGRA\Cambodia\Data\2012_3_6.xlsx", firstrow clear sheet("EGRA PILOT GR 3_6")
use "${path}\CNT\KHM\KHM_2012_EGRA\KHM_2012_EGRA_v01_M\Data\Stata\2012_3_6.dta", clear
*Develop variables of interest:
foreach var of varlist SOPHY? {
	destring `var', replace
	*Assuming 9 is no response:
	replace `var' = 0 if `var' == 9
}
egen read_comp_score = rowtotal(SOPHY?)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/5)*100
ren (SCHOOL GRADE) (school_code grade)
keep school_code grade read_comp_score_pcnt read_comp_score_zero
gen year = 2012
bysort school_code: gen id = _n
gen n_res = 1 
gen r_res = 1
gen w = 0
save "${path}/TEMP/EGRA_Cambodia_2012_3_6_s.dta", replace


use "${path}/TEMP/EGRA_Cambodia_2012_1_2_s.dta", clear
append using "${path}/TEMP/EGRA_Cambodia_2012_3_6_s.dta"

gen country = "Cambodia"
gen cntabb = "KHM"
gen idcntry = 116
gen language = "Khmer"
gen lang_instr = language
cf _all using "${path}\CNT\KHM\KHM_2012_EGRA\KHM_2012_EGRA_v01_M_v01_A_HAD.dta"

save "${path}\CNT\KHM\KHM_2012_EGRA\KHM_2012_EGRA_v01_M_v01_A_HAD.dta", replace 

