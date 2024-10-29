set seed 10051990
set sortseed 10051990


use "${path}/CNT/BGD/BGD_2016_EGRA/BGD_2016_EGRA_v01_M/Data/Stata\2016_GPS.dta", clear
drop if year < 2015
*Renaming variables for appending:
ren Division region
replace wpmc = 0 if missing(wpmc)
ren (sex wpmc masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
*Variables for analysis:
egen oral_read_score_sum = rowtotal(reading?)
egen oral_read_score_sum2 = rowtotal(reading??)
egen oral_read_score_sum3 = rowtotal(reading???)
replace oral_read_score_sum = oral_read_score_sum + oral_read_score_sum2 + oral_read_score_sum3
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/122)*100 if grade == 3
replace oral_read_score_pcnt = (oral_read_score_sum/83)*100 if grade == 2
egen read_comp_score_sum = rowtotal(comp?)
replace read_comp_score_sum = read_comp_score_sum + comp10
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum*
keep year region female orf id age grade school_code region oral_read* read_comp*
gen n_res = 0
gen r_res = 0
gen w = 0
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen study = "GPS"
save "${path}/TEMP/2016_GPS_s.dta", replace

use "${path}/CNT/BGD/BGD_2016_EGRA/BGD_2016_EGRA_v01_M/Data/Stata\2016_NNPS.dta", clear
*Renaming variables for appending:
ren division region
ren (sex wpmc masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
keep year region age grade female orf id school_code reading? reading?? reading??? comp__? comp__??
*Variables for analysis:
egen oral_read_score_sum = rowtotal(reading*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/122)*100 if grade == 3
replace oral_read_score_pcnt = (oral_read_score_sum/83)*100 if grade == 2
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum
keep year  region female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "NNPS"
save "${path}\TEMP/2016_NNPS_s.dta", replace

use "${path}/CNT/BGD/BGD_2016_EGRA/BGD_2016_EGRA_v01_M/Data/Stata\2016_RCT.dta", clear
*According to Shahana at UNICEF Bangladesh, all the data where consent is not equal to 1 should be dropped.
drop if mid_consent != "yes"
ren mid_* *
drop if missing(class)
drop if class == 0
*Renaming variables for appending:
ren (sex wpmc1 masked_StudentID class) (female orf id grade)
keep year  school_code consent female age grade reading1_? reading1_?? comp1_? comp1_?? orf id 
drop reading1_3
*Variables for analysis:
replace orf = 0 if missing(orf)
egen oral_read_score_sum = rowtotal(reading*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/77)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum*
keep year   female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "RCT"
save "${path}/TEMP/2016_RCT_s.dta", replace

use "${path}/TEMP/2016_GPS_s.dta", clear
append using "${path}/TEMP/2016_NNPS_s.dta"
append using "${path}/TEMP/2016_RCT_s.dta"


gen country = "Bangladesh"
gen cntabb = "BGD"
gen idcntry = 050
gen n = _n

codebook, compact
cf _all using  "${path}\CNT\BGD\BGD_2016_EGRA\BGD_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BGD\BGD_2016_EGRA\BGD_2016_EGRA_v01_M_v01_A_HAD.dta", replace 

