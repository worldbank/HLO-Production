*******************************************************************************  
**************************** PASEC DATABASE      ******************************
****************************                     ******************************
*******************************************************************************
/*This do file:
1)	Develops PASEC 2014 database
*/

set seed 10051990
set sortseed 10051990

*Open all data and upper case the variables:

use "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M\Data\Stata\PASEC2014_GRADE2.dta", clear
gen IDGRADE = 2
append using "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M\Data\Stata\PASEC2014_GRADE6.dta"
replace IDGRADE = 6 if missing(IDGRADE)

*Generating variable for AGE:
gen AGE = qe61 if IDGRADE == 6
replace AGE = qe21 if missing(AGE) & IDGRADE == 2

forvalues i = 1/5 {
	gen LOW_READING_PROFICIENCY_UIS`i' = (LECT_PV`i' >= 540) if IDGRADE == 2
}

forvalues i = 1/5 {
	replace LOW_READING_PROFICIENCY_UIS`i' = (LECT_PV`i' >= 441.7) if IDGRADE == 6 & missing(LOW_READING_PROFICIENCY_UIS`i')
}

forvalues i = 1/5 {
	gen LOW_READING_PROFICIENCY_WB`i' = (LECT_PV`i' >= 540) if IDGRADE == 2
}

forvalues i = 1/5 {
	replace LOW_READING_PROFICIENCY_WB`i' = (LECT_PV`i' >= 518.4) if IDGRADE == 6 
}


*Generating variable for gender:
gen ITSEX = 1 if qe62 == 2 // female = 1, male = 0
replace ITSEX = 0 if qe62 == 1

*Generating variable for Early Childhood education:
gen ECE = 1 if qe63 == 1
replace ECE = 0 if qe63 == 2


*Generating variable for number of books:
gen NBOOKS = qe620

*Generating variable for Socio-Economic Status:
foreach var of varlist qe621* qe622* qe624 qe625 qe626 qe627 qe628 qe616* {
	replace `var' = 0 if `var' == 2
	tab `var'
	egen `var'_std = std(`var')
}

tab NBOOKS, gen(dNBOOKS)
foreach var of varlist dNBOOKS* {
	egen `var'_std = std(`var')
}
gen hhsize = qe629


egen hedu = rowtotal(qe616a qe616b)

tab qe623, gen(wall)

pca dNBOOKS*_std qe621*_std qe622*_std qe624_std qe625_std qe626_std qe627_std qe628_std qe616*_std 
predict SES_check_assets
drop *_std

mca NBOOKS qe621* qe622* qe624 qe625 qe626 qe627 qe628 qe616* 
predict SES_check_assets_mca

mca NBOOKS qe621* qe622* qe624 qe625 qe626 qe627 qe628 qe616a qe616b 
predict SES_check_assets_mca1



irt 2pl dNBOOKS* qe621* qe622* qe624 qe625 qe626 qe627 qe628 qe616* 
mca NBOOKS qe616a qe616b
predict SES_check_mca

 

*polychoricpca hedu HOMEPOS [weight = rwgt0], score(SES_check_assetindex) nscore(1)

*polychoricpca hedu NBOOKS [weight = rwgt0], score(SES_check) nscore(1)



*SES description is available in Cambodia Analysis:
*Using principal component analysis:
egen ESCS = std(SES)
*Replacing missing values:
bysort PAYS ID_ECOLE IDGRADE: egen ESCS_mean = mean(ESCS)
bysort PAYS IDGRADE: egen ESCS_mean_cnt = mean(ESCS)
replace ESCS = ESCS_mean if IDGRADE == 6 & missing(ESCS)
replace ESCS = ESCS_mean_cnt if IDGRADE == 6 & missing(ESCS)


*The data contain assets and housing conditions

*Standardization of variables:
ren rwgt0 STUDENT_WEIGHT
ren rwgt* WEIGHT_REPLICATE*
ren LECT_PV* SCORE_READING*
ren MATHS_PV* SCORE_MATH*
ren (ID_ECOLE ID_ELEVE) (IDSCHOOL IDSTUD)
*Country codes:
recode ID_PAYS (1= 204) (2=854) (3=108) (4=120) (5=178) (6=384) (7=562) (8=686) (9=148) (10=768), gen(IDCNTRY)

bysort IDCNTRY IDSCHOOL IDGRADE: egen SCHESCS = mean(ESCS)
bysort IDCNTRY IDGRADE: egen CNTESCS = mean(ESCS)

merge m:1 IDCNTRY using "${path}\STANDARD\wb_ids.dta", keep(master match) assert(master match using) nogen
_cf using "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M_v01_A_BASE\SSA_2014_PASEC_v01_M_v01_A_BASE.dta"
save "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M_v01_A_BASE\SSA_2014_PASEC_v01_M_v01_A_BASE.dta", replace
keep WBCODE WBCOUNTRYNAME IDCNTRY IDSCHOOL IDSTUD IDGRADE ITSEX SCORE* LOW* STUDENT_WEIGHT*  ESCS JKZONE JKREP WEIGHT* SCHESCS CNTESCS
gen year = 2014
codebook, compact
cf _all using "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M_v01_A_HAD\SSA_2014_PASEC_v01_M_v01_A_HAD.dta"
save "${path}\SSA\SSA_2014_PASEC\SSA_2014_PASEC_v01_M_v01_A_HAD\SSA_2014_PASEC_v01_M_v01_A_HAD.dta", replace


