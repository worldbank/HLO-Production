

set seed 10051990
set sortseed 10051990

use "${path}/CNT/BGD/BGD_2014_EGRA/BGD_2014_EGRA_v01_M/Data/Stata/2014_NNPS.dta", clear
gen n_res = 0
gen r_res = 0
gen year = 2014
*Renaming variables for appending:
decode division, gen(region)
ren (sex wpmc masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
keep year  date assess_time age grade female orf id school_code read? read?? comp? comp??
*Variables for analysis:
egen oral_read_score_sum = rowtotal(read*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/59)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum
keep year  date assess_time female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
save "${path}/TEMP/2014_NNPS_s.dta", replace

use "${path}/CNT/BGD/BGD_2014_EGRA/BGD_2014_EGRA_v01_M/Data/Stata/2014_NNPS_2.dta", clear
*Renaming variables for appending:
decode division, gen(region)
ren (sex fluency masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
keep year region  date assess_time age grade female orf id school_code read? read?? comp? comp??
*Variables for analysis:
egen oral_read_score_sum = rowtotal(read*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/83)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum
keep year region  date assess_time female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "NNPS"
save "${path}/TEMP/2014_NNPS_2_s.dta", replace

use "${path}/CNT/BGD/BGD_2014_EGRA/BGD_2014_EGRA_v01_M/Data/Stata/2014_NNPS_3.dta", clear
*Renaming variables for appending:
decode division, gen(region)
ren (sex wpmc masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
keep year  date assess_time age grade female orf id school_code read? read?? read??? comp? comp??
*Variables for analysis:
egen oral_read_score_sum = rowtotal(read*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/122)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum
keep year  date assess_time female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "NNPS"
save "${path}/TEMP/2014_NNPS_3_s.dta", replace
 
use "${path}/TEMP/2014_NNPS_s.dta", clear
append using "${path}/TEMP/2014_NNPS_2_s.dta"
append using  "${path}/TEMP/2014_NNPS_3_s.dta"

gen country = "Bangladesh"
gen cntabb = "BGD"
gen idcntry = 050
gen n = _n
codebook, compact
cf _all using "${path}/CNT/BGD/BGD_2014_EGRA/BGD_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/BGD/BGD_2014_EGRA/BGD_2014_EGRA_v01_M_v01_A_HAD.dta", replace
