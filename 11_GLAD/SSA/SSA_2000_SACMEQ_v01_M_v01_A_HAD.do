*****************************************************
*This do file:


*****************************************************



use "${path}\SSA\SSA_2000_SACMEQ\SSA_2000_SACMEQ_v01_M\Data\Stata\back_03_2000_06_9.dta", clear
gen SCORE_READING = zralocp
gen SCORE_MATH = zmalocp
gen LOW_READING_PROFICIENCY_WB = (zralevp >= 4) & !missing(zralevp)
gen LOW_READING_PROFICIENCY_UIS = (zralevp >= 3) & !missing(zralevp)

gen year = 2000

gen STUDENT_WEIGHT = pweight2
encode stratum, gen(IDSTRATA)
gen IDSTUD = idpupil
gen IDSCH = idschool
ren (idcntry country) (IDCNTRY WBCODE) 
*Zanzibar not merged. All others merged:
merge m:1 IDCNTRY using "${path}\STANDARD\wb_ids.dta", keep(master match) assert(master match using) nogen
gen IDGRADE = 6
*Correct WBCODEs:
replace WBCODE = "BWA" if WBCODE == "BOT"


*Generating student level variables:
gen ITSEX = zpsex

gen AGE = zpagemon/12
*Dolata S. states the ESCS variable to be zpsesscr
egen ESCS = std(zpsesscr)

gen ABSENCE_LAST_MONTH = pabsent
gen SPEAK_ENGLISH = zpenglis

gen STUDENT_ACCOMODATION = 1 if pstay == 1
replace STUDENT_ACCOMODATION = 0 if inlist(pstay,2,3,4)
label define STUDENT_ACCOMODATION 1 "With Parents" 0 "Relatives/Hostel/Alone"
label values STUDENT_ACCOMODATION STUDENT_ACCOMODATION

gen REGULAR_MEALS = zpregme

*Home level Variables:

gen HOME_INTEREST = zphmint

*Teacher Level Variables:
gen TCHSEX = zxsex
gen TCHAGE = zxagelvl
gen TCHEDU = xqacad
gen TEACHER_TRAINING = 1 if inlist(xqprof,3,4,5,6)
replace TEACHER_TRAINING = 0 if inlist(xqprof,1,2)
label define TEACHER_TRAINING 1 "One or more years of trianing" 0 "No or less than one year of training"
label values TEACHER_TRAINING TEACHER_TRAINING

gen TCH_ABSENTEEISM = stchpr02

gen TCHEXP = yexper
gen INSERVICE_COURSES = yinservc
gen TCHESCS = zxhpos13
*School Level Variables:
*School's average socio-economic status:
bysort IDCNTRY IDSCH: egen SCHESCS = mean(ESCS)
bysort IDCNTRY: egen CNTESCS = mean(ESCS)

gen TEACHER_LIVING_CONDITION = 1 if xliving == 4
replace TEACHER_LIVING_CONDITION = 0 if inlist(xliving,1,2,3)
label define TEACHER_LIVING_CONDITION 1 "Good" 0 "Not Good"
label values TEACHER_LIVING_CONDITION TEACHER_LIVING_CONDITION

*Frequency of testing:
gen FREQ_TESTING = 1 if inlist(ttestrea,4,5,6)
replace FREQ_TESTING = 0 if inlist(ttestrea,1,2,3)
label define FREQ_TESTING 1 "More than once per term" 0 "Once or less than once per term"
label values FREQ_TESTING FREQ_TESTING

*Frequency of meeting parents:
gen FREQ_MEET_PARENTS = 1 if xmeetpar == 4
replace FREQ_MEET_PARENTS = 0 if inlist(xmeetpar,1,2,3)
label define FREQ_MEET_PARENTS 1 "Meet parents at least once a month" 0 "Less than once a month"
label values FREQ_MEET_PARENTS FREQ_MEET_PARENTS 

*Frequency of homework 
gen FREQ_HW = 1 if phmwkr == 4
replace FREQ_HW = 0 if phmwkr < 4
label define FREW_HW 1 "Most days" 0 "Once or twice each week or less"
label values FREQ_HW FREQ_HW

*School Level Variables:
gen DSEX = zssex
gen DAGE = zsagelvl
gen DEDU = sqacadem
*Director's qualification:
gen DTRAINING = 1 if inlist(sqtt,3,4,5,6)
replace DTRAINING = 0 if inlist(sqtt,1,2)
label define DTRAINING 1 "One or more years of training" 0 "No or less than one year of training"
label values DTRAINING DTRAINING 

gen D_TCH_EXP = sexptch

gen URBAN = zsloc

gen STUDENT_ABSENTEEISM = spuppr02

gen SCHRCS = zsrtot22
gen CLSIZE = xclsize

*Generating Schooling building condition:
gen SCHOOL_CONDITION = 1 if scondit == 5
replace SCHOOL_CONDITION = 0 if inlist(scondit,1,2,3,4)
label define SCHOOL_CONDITION 1 "Good" 0 "Not Good"
label values SCHOOL_CONDITION SCHOOL_CONDITION

gen PUPIL_TEACHER_RATIO = zsptrati
gen SCHSIZE = sfenrol
gen PUPIL_TOILET_RATIO = zstratio


svyset IDSTUD [pweight=STUDENT_WEIGHT], strata(IDSTRATA)
save "${path}\SSA\SSA_2000_SACMEQ\SSA_2000_SACMEQ_v01_M_v01_A_HAD\SSA_2000_SACMEQ_v01_M_v01_A_HAD_BASE.dta", replace

keep year SCORE_READING SCORE_MATH LOW_READING_PROFICIENCY* zralevp STUDENT_WEIGHT IDSTRATA IDSTUD IDCNTRY WBCODE IDGRADE ESCS	///
	SCHESCS ITSEX AGE ABSENCE_LAST_MONTH SPEAK_ENGLISH STUDENT_ACCOMODATION REGULAR_MEALS HOME_INTEREST TCHSEX TCHAGE	///
	TEACHER_TRAINING TCHEDU TCHEXP INSERVICE_COURSES TCHESCS TEACHER_LIVING_CONDITION FREQ_TESTING DSEX DEDU DTRAINING	///
	D_TCH_EXP URBAN STUDENT_ABSENTEEISM SCHRCS CLSIZE SCHOOL_CONDITION FREQ_HW PUPIL_TEACHER_RATIO SCHSIZE PUPIL_TOILET_RATIO	///
	TCH_ABSENTEEISM IDSCH sreslog FREQ_MEET_PARENTS DAGE CNTESCS
save "${path}\SSA\SSA_2000_SACMEQ\SSA_2000_SACMEQ_v01_M_v01_A_HAD\SSA_2000_SACMEQ_v01_M_v01_A_HAD_ALL.dta", replace


