** BANGLADESH
set seed 10051990
set sortseed 10051990

// 2015
use "${path}/CNT/BGD/BGD_2015_EGRA/BGD_2015_EGRA_v01_M/Data/Stata/2015_CHT.dta", clear
*Renaming variables for appending:
ren (sex Total_wordsread_min masked_StudentID masked_SchoolCode) (female orf id school_code)
*Variables for analysis:
gen oral_read_score_zero = (Total_wordsread == 0)
gen oral_read_score_pcnt = (Total_wordsread/122)*100 if grade == 3
replace oral_read_score_pcnt = (Total_wordsread/58)*100 if grade == 1
replace oral_read_score_pcnt = (Total_wordsread/83)*100 if grade == 2
egen read_comp_score_sum = rowtotal(comp?)
replace read_comp_score_sum = read_comp_score_sum + comp10
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum
keep female orf id school_code grade age oral_read* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen year = 2015
gen study = "CHT"
gen region = "Chittagong Hill District"
save "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_CHT.dta", replace

use "${path}/CNT/BGD/BGD_2015_EGRA/BGD_2015_EGRA_v01_M/Data/Stata/2015_NNPS.dta", clear
*Renaming variables for appending:
decode division, gen(region)
ren (sex fluency masked_StudentID masked_SchoolCode _class) (female orf id school_code grade)
keep year region  date assess_time female age orf id school_code grade read? read?? read??? comp? comp??
drop read2u* reader
*Variables for analysis:
egen oral_read_score_sum = rowtotal(read*)
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/122)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum
keep year region  date assess_time female orf age id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "NNPS"
save "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_NNPS.dta", replace

use "${path}/CNT/BGD/BGD_2015_EGRA/BGD_2015_EGRA_v01_M/Data/Stata/2015_RCT.dta", clear
*According to Shahana with UNICEF Bangladesh, the observations for which class is missing are not real data:
drop if missing(class)
gen year = 2015
*Renaming variables for appending:
ren (sex masked_StudentID masked_SchoolCode class) (female id school_code grade)
keep year  date female age grade id school_code reading_? reading_?? comp? comp?? reading_time_used
*Variables for analysis:
egen oral_read_score_sum = rowtotal(reading_?)
egen oral_read_score_sum1= rowtotal(reading_??)
replace oral_read_score_sum = oral_read_score_sum + oral_read_score_sum1
gen orf = (oral_read_score_sum/reading_time_used)*60
gen oral_read_score_zero = (oral_read_score_sum == 0)
gen oral_read_score_pcnt = (oral_read_score_sum/59)*100
egen read_comp_score_sum = rowtotal(comp*)
gen read_comp_score_zero = (read_comp_score_sum == 0)
gen read_comp_score_pcnt = (read_comp_score_sum/10)*100
drop read_comp_score_sum oral_read_score_sum*
keep year   date female age orf id school_code grade oral_* read_comp*
gen language = "Bangla"
gen s_res = 1
gen lang_instr = "Bangla"
gen n_res = 0
gen r_res = 0
gen w = 0
gen study = "RCT"
save "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_RCT.dta", replace

use "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_CHT.dta", clear
append using "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_NNPS.dta"
append using "${path}\TEMP\TEMP_All_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD_RCT.dta"


gen country = "Bangladesh"
gen cntabb = "BGD"
gen idcntry = 050
gen n = _n

codebook, compact
cf _all using "${path}\CNT\BGD\BGD_2015_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BGD\BGD_2015_EGRA\BGD_2015_EGRA_v01_M_v01_A_HAD.dta", replace

