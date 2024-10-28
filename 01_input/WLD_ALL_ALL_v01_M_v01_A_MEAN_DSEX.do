*Author: Syedah Aroob Iqbal
*Brings in mean data from TIMSS 2019 and PASEC 2019 and append with the previous means database:

use "$clone\01_input\LLECE_2019_updated_V2.dta", clear
tostring grade, replace
save "$clone\01_input\LLECE_2019_updated_V2_to_append.dta", replace

*Preparing for append:
use "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_PASEC_LLECE_SEA_PLM.dta", clear
tostring grade, replace
keep if inlist(test,"PASEC")
append using "$clone\01_input\LLECE_2019_updated_V2_to_append.dta"
replace test = "LLECE" if missing(test)
save "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_PASEC_LLECE_toappend", replace


*Bringing LLECE 2013 data to check:
import excel "$clone\01_input\LLECE_2013.xlsx", sheet("Sheet1") firstrow clear
drop COUNTRY
tostring grade, replace
save "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_LLECE_2013_tocheck.dta", replace


use "N:\datalib-edu\HLO_Database\CNT\WLD\WLD_2019_TIMSS\WLD_2019_TIMSS_v01_M_v01_A_GLAD\Data\Harmonized\WLD_2019_TIMSS_v01_M_wrk_A_GLAD_CLO.dta", clear
*Keep only the variables required:
keep assessment year countrycode idgrade subgroup n_score_timss_math m_score_timss_math se_score_timss_math n_score_timss_science m_score_timss_science se_score_timss_science
reshape long m_score_timss_ n_score_timss_ se_score_timss_, i(countrycode year assessment idgrade subgroup) j(subject) string
*Assuming all countries have nationally representative data
gen n_res = 1
keep if inlist(subgroup,"all","male=0","male=1")
replace subgroup = "t" if subgroup == "all"
replace subgroup = "f" if subgroup == "male=0"
replace subgroup = "m" if subgroup == "male=1"
reshape wide m_score_timss_ n_score_timss_ se_score_timss_, i(countrycode year assessment idgrade subject) j(subgroup) string
ren (countrycode assessment idgrade) (cntabb test grade)
ren (m_score_timss_* n_score_timss_* se_score_timss_*) (score_* n_* se_*) 
ren *_t *
tostring grade, replace
append using "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta"
save "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022.dta", replace
append using "$clone\01_input\\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_PASEC_LLECE_toappend"
drop if test == "PASEC" & grade == "2"

preserve
append using "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_LLECE_2013_tocheck.dta"
keep if inlist(year,2013,2019) & inlist(test,"LLECE","LLECE_T")
ren (score se n) (score_t se_t n_t)
reshape wide score* se* n*, i(cntabb subject grade year) j(test) string
gen diff = score_tLLECE_T - score_tLLECE
kdensity diff
twoway (scatter score_tLLECE_T score_tLLECE, sort) (line score_tLLECE score_tLLECE, sort)
kdensity diff if subject == "math", addplot(kdensity diff if subject == "reading" || kdensity diff if subject == "science")
reg score_tLLECE score_tLLECE_T if subject == "math" & year == 2013
estimates store LLECE_math
predict score_LLECE_2013_c_2006_m if subject == "math" & year == 2013
twoway (scatter score_LLECE_2013_c_2006_m score_tLLECE, sort) (line score_tLLECE score_tLLECE, sort)
predict double resid_math if subject == "math" & year == 2013, residuals
kdensity resid_math
*Saving coefficients and constant:
matrix A = e(b)
scalar B_math = A[1,1]
scalar C_math = A[1,2]
reg score_tLLECE score_tLLECE_T if subject == "reading" & year == 2013
estimates store LLECE_reading
matrix B = e(b)
scalar B_reading = B[1,1]
scalar C_reading = B[1,2]
reg score_tLLECE score_tLLECE_T if subject == "science" & year == 2013
estimates store LLECE_science
matrix C = e(b)
scalar B_science = C[1,1]
scalar C_science = C[1,2]
replace score_tLLECE_T = score_tLLECE if year == 2019
replace score_tLLECE = B_math*score_tLLECE + C_math  if year == 2019 & subject == "math"
replace score_tLLECE = B_reading*score_tLLECE + C_reading  if year == 2019 & subject == "reading"
replace score_tLLECE = B_science*score_tLLECE + C_science if year == 2019 & subject == "science"
drop resid_math diff _est_*
reshape wide score* se* n*, i(cntabb subject grade) j(year)
graph dot score_tLLECE2013 score_tLLECE2019 score_tLLECE_T2013 score_tLLECE_T2019, over(cntabb)
restore

*Generate comparable scores from LLECE - 2019
gen score_tLLECE_T = .
foreach sub in "math" "reading" "science" {
	estimates restore LLECE_`sub'
	foreach var of varlist score score_f score_m {
		replace score_tLLECE_T = `var' if test == "LLECE" & year == 2019 & subject == "`sub'"
		predict `var'_LLECE_2019_`sub', 
		predict `var'_LLECE_2019_`sub'_se, stdp
	}
}
foreach var of varlist score score_f score_m {
	replace `var' = `var'_LLECE_2019_math if test == "LLECE" & year == 2019 & subject == "math"
	replace `var' = `var'_LLECE_2019_reading if test == "LLECE" & year == 2019 & subject == "reading"
	replace `var' = `var'_LLECE_2019_science if test == "LLECE" & year == 2019 & subject == "science"
}
replace se = se + score_LLECE_2019_math_se if test == "LLECE" & year == 2019 & subject == "math"
replace se = se + score_LLECE_2019_reading_se if test == "LLECE" & year == 2019 & subject == "reading"
replace se = se + score_LLECE_2019_science_se if test == "LLECE" & year == 2019 & subject == "science"
replace se_f = se_f + score_f_LLECE_2019_math_se if test == "LLECE" & year == 2019 & subject == "math"
replace se_f = se_f + score_f_LLECE_2019_reading_se if test == "LLECE" & year == 2019 & subject == "reading"
replace se_f = se_f + score_f_LLECE_2019_science_se if test == "LLECE" & year == 2019 & subject == "science"
replace se_m = se_m + score_m_LLECE_2019_math_se if test == "LLECE" & year == 2019 & subject == "math"
replace se_m = se_m + score_m_LLECE_2019_reading_se if test == "LLECE" & year == 2019 & subject == "reading"
replace se_m = se_m + score_m_LLECE_2019_science_se if test == "LLECE" & year == 2019 & subject == "science"

drop *LLECE*
cf _all using "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_P_L.dta"
save "$clone\01_input\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX_2022_P_L.dta", replace



