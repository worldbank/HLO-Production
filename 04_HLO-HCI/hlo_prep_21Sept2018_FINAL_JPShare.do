/******************************************************************************/
// Program to prepare data for human capital index
// This file prepares the HLO data
// Primary data source is input file provided by Harry/Noam/Aroob
// Written by:  Aart
// Last run:  Sept 20
// Code has two parts:  a separate "core" code that manipulates the data 
// into a clean country-year series for the HCI, and this
// code which serves as a "wrapper".  The "wrapper" allows me to call the core
// code multiple times, replacing the hlo scores with their lower and upper
// bounds, and to retrieve the corresponding clean time series of lower and
// upper bounds to include in the HCI
// This version shared with JP Azevedo on December 20th
/******************************************************************************/
clear
set more off

/******************************************************************************/
// Preliminaries
/******************************************************************************/
global path = "$clone"     //user = SAI

global masterdatafilename "$clone\01_input\masterdata.dta"
global coreprogramname "$clone\04_HLO-HCI\hlo_prep_core_21Sept2018_FINAL_JPShare.do" 
global inputfilename "$clone\41_HLO-HCI\Metadata_HLO_se.dta"

global outputfilename "$clone\41_HLO-HCI\HLO_v2018.dta"


/******************************************************************************/
// Load data, drop/rename variables
/******************************************************************************/
use "$inputfilename"

// Drop MLA testing program since we won't be using it
drop if test=="MLA"

// Fix country codes for South Sudan and Serbia
replace cntabb="SSD" if cntabb=="SOU"
replace cntabb="SRB" if cntabb=="SCG"

// Drop rows with empty observations corresponding to PASEC2014, Grade 2
// These look like a glitch...
drop if HLO==.


// Rename PASEC (Aroob has separate name for it because PASEC 2014 is harmonized
// separately from previous round of PASEC)
replace test="PASEC" if test=="PASEC_2014"

//  Short names for two national assessments
replace test="LKANA" if test=="National Assessment" & cntabb=="LKA"

// Restore original name for nationally-representative EGRA tests
gen n_res_EGRA=n_res if test=="EGRA"
drop n_res

// Drop "standard error" and "range" variables since I will use only lower and upper bounds
drop se*
drop *_se
drop *_range
// Drop variable with share of uncertainty coming from original scores
drop os_share
// Drop upper and lower bounds for original scores since I don't need them
drop score_*lower
drop score_*upper
// Drop other variables we don't need
drop score_se_check
// Rename m+f variables to add _mf explicitly
rename HLO HLO_mf
rename HLO_lower HLO_mf_lower
rename HLO_upper HLO_mf_upper
rename score score_mf

// NPL and SSD, no record-level data for tests so no standard errors and ranges
// Both are EGRA, so use average range for other EGRA countries

foreach gender in m f mf {
	qui gen xx=HLO_`gender'_upper-HLO_`gender'_lower if test=="EGRA"
	su xx
	qui replace HLO_`gender'_lower=HLO_`gender'-r(mean)/2 if (cntabb=="NPL" | cntabb=="SSD") & test=="EGRA"
	qui replace HLO_`gender'_upper=HLO_`gender'+r(mean)/2 if (cntabb=="NPL" | cntabb=="SSD") & test=="EGRA"
	drop xx
	}
// check it worked
//br cntabb year test grade subject HLO_mf HLO_mf_lower HLO_mf_upper if cntabb=="NPL" | cntabb=="SSD"

/******************************************************************************/
// Call "core" code to create the clean HLO series for the HCI
// Call "core" code three times, successively feeding it the HLO, the lower bound
// and the upper bound.  Note that core code expects to receive as input
// variables called HLO_`gender'.  So rename HLO_`gender'_lower/upper on second and third
// runs of the core code to feed in as HLO_`gender'.  The rename the output as the lower
// and upper bounds.  For second and third runs, save in a temporary database only
// the lower and upper bounds of the hlo series, then merge in at the end 
/******************************************************************************/
// First time:  using point estimate for HLO 
// Preserve dataset and drop lower and upper bounds and use only HLO_`gender' as input to core code
*/
preserve
drop HLO_*_lower HLO_*_upper
do "$coreprogramname"
keep wbcode year *_rep *_fill *_year *_source hlo_*_unused hlo_*_unused_source hlo_mf_note
save "$outputfilename", replace


// Second time:  using lower bound of HLO, this time keep only the resulting lower bound of clean HLO series
restore
preserve
foreach gender in m f mf{
	replace HLO_`gender'=HLO_`gender'_lower
	}
drop HLO_*_lower HLO_*_upper
do "$coreprogramname"
foreach gender in m f mf{
	rename hlo_`gender'_fill hlo_`gender'_lower
	label var hlo_`gender'_lower "Combined HLO series, Lower Bound, gender=`gender', gaps filled with lags"
	}
keep wbcode year hlo_*_lower
save "$path\temp_lower.dta", replace

// Third time:  using upper bound of HLO, this time keep only the resulting upper bound of clean HLO series
restore
preserve
foreach gender in m f mf{
	replace HLO_`gender'=HLO_`gender'_upper
	}
drop HLO_*_lower HLO_*_upper
do "$coreprogramname"
foreach gender in m f mf{
	rename hlo_`gender'_fill hlo_`gender'_upper
	label var hlo_`gender'_upper "Combined HLO series, Upper Bound, gender=`gender', gaps filled with lags"
	}
keep wbcode year hlo_*_upper
save "$path\temp_upper.dta", replace

// Merge lower and upper bounds into main dataset
restore
clear
use "$outputfilename"
merge 1:1 wbcode year using "$path\temp_lower.dta"
tab _merge
drop _merge
sort wbcode year
merge 1:1 wbcode year using "$path\temp_upper.dta"
tab _merge
drop _merge
sort wbcode year
*/
/******************************************************************************/	
// Adding in extrapolated data for China to make more nationally representative
// Extrapolations based on note with Harry&Co
/******************************************************************************/	
// first copy hlo into unused test and source
foreach gender in m f mf{
	qui replace hlo_`gender'_unused=hlo_`gender'_rep if wbcode=="CHN"
	qui replace hlo_`gender'_unused_source="PISA (Shanghai Only)" if wbcode=="CHN" & hlo_`gender'_rep~=. & (year==2009 | year==2012)
	qui replace hlo_`gender'_unused_source="PISA (Beijing-Shanghai-Jiangsu-Guangdong Only)" if wbcode=="CHN" & hlo_`gender'_rep~=. & year==2015
	}
// Next erase combined HLO series data for China
foreach gender in m f mf{
	replace hlo_`gender'_rep=. if wbcode=="CHN"
	replace hlo_`gender'_fill=. if wbcode=="CHN"
	replace hlo_`gender'_year=. if wbcode=="CHN"
	*replace hlo_`gender'_lower=. if wbcode=="CHN"
	*replace hlo_`gender'_upper=. if wbcode=="CHN"
	replace hlo_`gender'_source="" if wbcode=="CHN"
	}
// Next replace with extrapolated data
// Use 456 as midpoint, 449 and 462 as range, as documented in China note
// This is for gender-combined.  In 2015 PISA the gender disaggregated rates are same for boys and girls (rounded to zero decimal places) at 532
// Based on this make assumption that gender-disaggregated extrapolated performance is same for boys and girls
foreach gender in m f mf{
	replace hlo_`gender'_rep=456 if wbcode=="CHN" & year==2015
	replace hlo_`gender'_fill=456 if wbcode=="CHN" & year>=2015 & year<=2017
	*replace hlo_`gender'_lower=449 if wbcode=="CHN" & year>=2015 & year<=2017
	*replace hlo_`gender'_upper=462 if wbcode=="CHN" & year>=2015 & year<=2017
	replace hlo_`gender'_year=2015 if wbcode=="CHN" & year>=2015 & year<=2017
	replace hlo_`gender'_source="PISA/PIRLS (Extrapolated)" if wbcode=="CHN" & year>=2015 & year<=2017
	}
replace hlo_mf_note="World Bank Staff-Extrapolated National Average based on PISA 2012 (Shanghai) PISA 2015 (B-S-J-G) and 2015 PIRLS-type assessment in Gao et. al. 2017 (Shaanxi, Jiangxi and Guizhou)" if wbcode=="CHN" & year>=2015 & year<=2017
replace hlo_mf_note="" if wbcode=="CHN" & (year<2015 | year>2017)	

// check it worked -- it does
//br if wbcode=="CHN" & year>=2000


save "$outputfilename", replace
erase "$path\temp_lower.dta"
erase "$path\temp_upper.dta"


// JP this last line is me checking that this creates exactly the right dataset we used
// You don't have access to these paths -- but rest assured it checks out
//cf * using "C:\Users\wb74439\WBG\Ritika Dsouza - HCI Data\3_HLO\hlo_data_21Sept2018.dta", all
