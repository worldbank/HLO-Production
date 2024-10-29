** Macedonia

set seed 10051990
set sortseed 10051990

use "${gsdRawData}/EGRA/Macedonia/Data/2014.dta", clear
gen w = 0
ren (Region Grade Preschool OrFlu01_correctperminute masked_StudentID Age) (region grade tppri orf id age)
gen female = 1 if Gender == "Zh"
replace female = 0 if Gender == "M"
replace orf = missing(orf)
*Developing variables of interest:
gen oral_read_score_zero = (OrFlu01_correct == 0)
gen oral_read_score_pcnt = (OrFlu01_correct/166)*100
foreach var of varlist Compr0* {
	replace `var' = "0" if `var' == "notAsked"
	destring `var', gen(`var'_n)
	replace `var'_n = 0 if `var'_n == 999
	drop `var'
	ren `var'_n `var'
}
egen read_comp_score = rowtotal(Compr0?)
gen read_comp_score_zero = read_comp_score == 0
gen read_comp_score_pcnt = (read_comp_score_zero/7)*100
keep year region id grade female age tppri orf oral_read_score_zero oral_read_score_pcnt read_comp_score_pcnt read_comp_score_zero w
*2014 data is not complete. Also not sure about representation.

