*****************************************************
*This do file:


*****************************************************

global path = "N:\GDB\HLO_Database"

use "${path}\SSA\SSA_2007_SACMEQ\SSA_2007_SACMEQ_v01_M\Data\Stata\back_03_2007_06_9.dta", clear
gen SCORE_READING = zralocp
gen SCORE_MATH = zmalocp
gen LOW_READING_PROFICIENCY_WB = (zralevp >= 4) & !missing(zralevp)
gen LOW_READING_PROFICIENCY_UIS = (zralevp >= 3) & !missing(zralevp)

gen year = 2007

gen STUDENT_WEIGHT = pweight2
encode stratum, gen(IDSTRATA)
gen IDSTUD = idpupil
ren (idcntry country jschlid) (IDCNTRY WBCODE IDSCHOOL) 
*Zanzibar not merged. All others merged.
merge m:1 IDCNTRY using "${path}\STANDARD\wb_ids.dta",  assert(master match using) keep(master match) nogen
gen IDGRADE = 6

gen AGE = zpagemon/12

*Correct WBCODEs:
replace WBCODE = "BWA" if WBCODE == "BOT"

*Dolata S. states the ESCS variable to be zpsesscr
egen ESCS = std(zpsesscr)

bysort IDCNTRY IDSCHOOL: egen SCHESCS = mean(ESCS)
bysort IDCNTRY: egen CNTESCS = mean(ESCS)


svyset IDSTUD [pweight=STUDENT_WEIGHT], strata(IDSTRATA)
save "${path}\SSA\SSA_2007_SACMEQ\SSA_2007_SACMEQ_v01_M_v01_A_HAD\SSA_2007_SACMEQ_v01_M_v01_A_HAD_BASE.dta", replace

keep AGE year SCORE_READING SCORE_MATH LOW_READING_PROFICIENCY* zralevp STUDENT_WEIGHT IDSTRATA IDSTUD IDCNTRY WBCODE IDGRADE ESCS SCHESCS CNTESCS
save "${path}\SSA\SSA_2007_SACMEQ\SSA_2007_SACMEQ_v01_M_v01_A_HAD\SSA_2007_SACMEQ_v01_M_v01_A_HAD_ALL.dta", replace


