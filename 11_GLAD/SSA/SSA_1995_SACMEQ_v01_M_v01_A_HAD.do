*****************************************************
*This do file:


*****************************************************

import delimited "N:\GDB\WorldBank_GLAD_workingcopy\GLAD\01_harmonization/011_rawdata/master_countrycode_list.csv",  clear
keep if (assessment == "SACMEQ") & (year == 1995)
// Most assessments use the numeric idcntry_raw but a few (ie: PASEC 1996) have instead idcntry_raw_str
if use_idcntry_raw_str[1] == 1 {
	drop   idcntry_raw
	rename idcntry_raw_str idcntry_raw
}
keep idcntry_raw national_level countrycode
*Find an ADM code for Zanzibar
save "${path}\TEMP\countrycode_list.dta", replace

use "${path}\SSA\SSA_1995_SACMEQ\SSA_1995_SACMEQ_v01_M\Data\Stata\back_03_1995_06_9.dta", clear

		*<_idcntry_raw_>
		clonevar idcntry_raw = idcountr
		label var idcntry_raw "Country ID, as coded in rawdata"
		*</_idcntry_raw_>

gen SCORE_READING = xralocp
gen LOW_READING_PROFICIENCY = (xralevp >= 4) & !missing(xralevp)
gen year = 1995

gen STUDENT_WEIGHT = pweight1
gen strata1 = idstrat
gen double IDSTUDENT = idpupil
gen IDSCHOOL = idschool
gen iddistrict = iddistri
gen IDGRADE = 6
gen IDCNTRY = idcntry

*Genearting student level variables:

gen ITSEX = xpsex
gen AGE = xpagemon/12
*Dolata S. states the ESCS variable to be zpsesscr
egen ESCS = std(xpsesscr)

bysort idcntry_raw: egen CNTESCS = mean(ESCS)

gen ABSENCE_LAST_MONTH = pabsent
gen SPEAK_ENGLISH = xpenglis

gen STUDENT_ACCOMODATION = 1 if pstay == 1
replace STUDENT_ACCOMODATION = 0 if inlist(pstay,2,3,4)
label define STUDENT_ACCOMODATION 1 "With Parents" 0 "Relatives/Hostel/Alone"
label values STUDENT_ACCOMODATION STUDENT_ACCOMODATION

gen REGULAR_MEALS = xpregme

*Home Level Variables:
gen HOME_INTEREST = xphmint

*Genearting Teacher Level Variables for Analysis:
gen TCHSEX = xtsex
gen TCHAGE = xtagelvl
gen TCHEDU = 1 if tqprimar == 7 & tqsecond < 5
replace TCHEDU = 2 if tqsecond == 5 & tqpostse <2
replace TCHEDU = 3 if tqpostse >= 2 & !missing(tqpostse)
label define TCHEDU 1 "Primary" 2 "Secondary" 3 "Senior Secondary"
label values TCHEDU TCHEDU 

gen TEACHER_TRAINING = 1 if inlist(tqprofes,3,4,5,6)
replace TEACHER_TRAINING = 0 if inlist(tqprofes,1,2)
label define TEACHER_TRAINING 1 "More than 1 year of training" 0 "No or less than 1 year of training"
label values TEACHER_TRAINING TEACHER_TRAINING 

gen TCH_ABSENTEEISM = sprobtab

gen TCHEXP = tnumyrs
gen INSERVICE_COURSES = tinserv

egen INSPECTION_VISIT = rowtotal(tinspv95 tinspv94 tinspv93)

gen TCHESCS = xthposto

gen TEACHER_ACCOMODATION = 1 if tprovide == 1
replace TEACHER_ACCOMODATION = 0 if inlist(tprovide,2,3,4,5)
label define TEACHER_ACCOMODATION 1 "Own" 0 "School/Local/Government/Other"
label values TEACHER_ACCOMODATION TEACHER_ACCOMODATION

*Generating variable for teachers' living condition:
gen TEACHER_LIVING_CONDITION = 1 if tcondliv == 4
replace TEACHER_LIVING_CONDITION = 0 if inlist(tcondliv,1,2,3)
label define TEACHER_LIVING_CONDITION 1 "Good" 0 "Not Good"
label values TEACHER_LIVING_CONDITION TEACHER_LIVING_CONDITION

*Frequency of testing:
gen FREQ_TESTING = 1 if inlist(ttesting,4,5,6)
replace FREQ_TESTING = 0 if inlist(ttesting,1,2,3)
label define FREQ_TESTING 1 "More than once per term" 0 "Once or less than once per term"
label values FREQ_TESTING FREQ_TESTING

*Frequency of meeting parents:
gen FREQ_MEET_PARENTS = 1 if tmeetpar == 4
replace FREQ_MEET_PARENTS = 0 if inlist(tmeetpar,1,2,3)
label define FREQ_MEET_PARENTS 1 "Meet parents at least once a month" 0 "Less than once a month"
label values FREQ_MEET_PARENTS FREQ_MEET_PARENTS 

*Frequency of homework 
gen FREQ_HW = 1 if phmwkget == 4
replace FREQ_HW = 0 if phmwkget < 4
label define FREW_HW 1 "Most days" 0 "Once or twice each week or less"
label values FREQ_HW FREQ_HW

*Generating School Level Variables for Analysis:

*Schools average socio-economic status:
bysort IDSCH : egen SCHESCS = mean(ESCS)

*Gen URBAN
gen URBAN = inlist(slocatio,3,4)
replace URBAN = 0 if inlist(slocatio,1,2)

gen DSEX = xssex

gen DAGE = xsagelvl

gen DEDU = 1 if inrange(xsqyrsed,7,11)
replace DEDU = 2 if inlist(xsqyrsed,12,13) 
replace DEDU = 3 if xsqyrsed > 13 & !missing(xsqyrsed)

gen STUDENT_ABSENTEEISM = sprobpab

*Generating Schooling building condition:
gen SCHOOL_CONDITION = 1 if sbldgcon == 5
replace SCHOOL_CONDITION = 0 if inlist(sbldgcon,1,2,3,4)
label define SCHOOL_CONDITION 1 "Good" 0 "Not Good"
label values SCHOOL_CONDITION SCHOOL_CONDITION

*Director's qualification:
gen DTRAINING = 1 if inlist(sqprofes,3,4,5,6)
replace DTRAINING = 0 if inlist(sqprofes,1,2)
label define DTRAINING 1 "One or more years of training" 0 "No or less than one year of training"
label values DTRAINING DTRAINING 

gen D_TCH_EXP = syrteach

*School Resources:
foreach var of varlist sres* slibbook saddbook {
	tab `var'
}
*alphawgt sres* slibbook saddbook [weight = STUDENT_WEIGHT], detail item std gen(SRCS)

gen CLASSROOM_FURNITURE = xtclfurn

gen SCHRCS = xsrestot

gen CLSIZE = xtclassp

gen PUPIL_TEACHER_RATIO = xsptrati
gen SCHSIZE = xstotenr
gen PUPIL_TOILET_RATIO = xstratio

svyset IDSCH [pweight=STUDENT_WEIGHT], strata(strata1)
merge m:1 idcntry_raw using "${path}\TEMP/countrycode_list.dta", keep(match) assert(match using) nogen
save "${path}\SSA\SSA_1995_SACMEQ\SSA_1995_SACMEQ_v01_M_v01_A_HAD\SSA_1995_SACMEQ_v01_M_v01_A_HAD_BASE.dta", replace

keep year SCORE_READING LOW_READING_PROFICIENCY xralevp STUDENT_WEIGHT strata1 IDSTUD idcntry_raw IDGRADE ESCS SCHESCS ///
	TCHEDU INSPECTION_VISIT STUDENT_ACCOMODATION TEACHER_ACCOMODATION URBAN FREQ_TESTING FREQ_MEET_PARENTS TEACHER_LIVING_CONDITION ///
	SCHOOL_CONDITION ITSEX AGE ABSENCE_LAST_MONTH SPEAK_ENGLISH HOME_INTEREST TCHSEX TCHAGE TEACHER_TRAINING TCHEXP INSERVICE_COURSES TCHESCS	///
	DSEX DAGE DEDU DTRAINING D_TCH_EXP STUDENT_ABSENTEEISM CLASSROOM_FURNITURE SCHRCS CLSIZE FREQ_HW PUPIL_TEACHER_RATIO SCHSIZE PUPIL_TOILET_RATIO	///
	TCH_ABSENTEEISM IDSCH sreslog REGULAR_MEALS CNTESCS idstrat idregion iddistrict idcntry IDCNTRY national_level countrycode
save "${path}\SSA\SSA_1995_SACMEQ\SSA_1995_SACMEQ_v01_M_v01_A_HAD\SSA_1995_SACMEQ_v01_M_v01_A_HAD.dta", replace

	


