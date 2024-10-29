/******************************************************************************/
// "Core" HLO prep code.  This program is called by "wrapper" hlo_prep_DATE.do
// It takes HLO dataset loaded by "wrapper" code, collapses to country-year
// format, and then creates clean country-year time series of tests used
// in the HCI.  The wrapper programcalls this
// code three times to construct the HLO series used in HCI using (i) the point 
// estimate of HLO as well as (ii) upper bounds and (iii) lower bounds -- so as to generate
// uncertainty intervals for the overall HCI
// Written by:  Aart
// Last revised:  Sept 13
// Input data prepared by wrapper code:
// 		cntabb country year (country code, name, year) 
// 		test grade subject (test identifiers)
// 		score_`gender', HLO_`gender' (original score and HLO)
// 		d_index (doubloon index or exchange rate between tests)
// 		n_res_EGRA (dummy=1 if EGRA is nationally representative)
// Major changes since previous version:  Updated hlo_mf_note (lines 387-389) to new version of Harry's paper, now populates only if hlo_mf_fill~=.
/******************************************************************************/

/******************************************************************************/
// Collapse across subjects/grades, set variable names, check codes
/******************************************************************************/
// Collapsing across subjects, then levels
// Equally-weight across subjects in a given level (primary or secondary)
// Then equally-weight across levels
gen primary_secondary = (inlist(grade,"2-4","3","4","5","6"))
label define primary_secondary 0 "Secondary" 1 "Primary"
label values primary_secondary primary_secondary
// Generate primary and secondary score for each subject
collapse score_* d_index HLO_* , by(country cntabb year test subject primary_secondary n_res_EGRA)
// Average across primary and secondary for each subject
collapse score_* d_index HLO_* , by(country cntabb year test subject n_res_EGRA)
// Average across subjects
collapse score_* d_index HLO_* , by(country cntabb year test n_res_EGRA)

// Relabel variables to create stable names for subsequent code
rename cntabb wbcode  
rename HLO_mf hlo_mf_
rename HLO_m hlo_m_
rename HLO_f hlo_f_
rename score_mf os_mf_
rename score_m os_m_
rename score_f os_f_
rename d_index di_
rename n_res_EGRA egra_note_
rename test test_name


// Reshape to wide 
reshape wide hlo_mf_ hlo_m_ hlo_f_ os_mf_ os_m_ os_f_ di_ egra_note_, i(wbcode year) j(test_name) string
rename *, lower
gen egra_notes=egra_note_egra
drop egra_note_*
// Drop stuff before 2000, not needed for HCI exercise and too sparse anyhow
drop if year<2000

// Create separate variables for non-nationally-representative EGRAs (call these EGRANA)
// This makes it easier to prioritize nationally-representative EGRAs in code below
foreach var in hlo os {
	foreach gender in m f mf{
		gen `var'_`gender'_egranr=`var'_`gender'_egra if egra_notes==0
		replace `var'_`gender'_egra=. if egra_notes==0
		}
	}
gen di_egranr=di_egra if egra_notes==0
replace di_egra=. if egra_notes==0

// Relabel variables so that gender comes at the end, consistent with rest of HCI code
foreach test in pisa pirls timss llece sacmeq pasec egra egranr naeq lkana{
	foreach gender in m f mf{
		rename hlo_`gender'_`test' hlo_`test'_`gender'
		rename os_`gender'_`test' os_`test'_`gender'
		}
	}


/******************************************************************************/
// Save temporary version of dataset, then merge back into master dataset
// so that everything lines up with standard country x year panel used throughout
// HCI code
/******************************************************************************/
gen hlomarker=1  // marker for observations from original hlo dataset
sort wbcode year
save "$path\temp.dta", replace
clear
use "$masterdatafilename"
sort countrynumber year
xtset countrynumber year
merge 1:1 wbcode year using "$path\temp.dta"
tab wbcode if _merge==2
drop if _merge==2
drop _merge
erase "$path\temp.dta"
sort countrynumber year


/******************************************************************************/
// Combining test scores from different programs into smooth-as-possible time series
// Created series is hlo_`gender' (with accompanying hlo_`gender'_source)
/******************************************************************************/

/******************************************************************************/
// Step 1:  Combine PISA/TIMSS/PIRLS.  Idea here is to shift PIRLS to nearest TIMSS
// year and average TIMSS+PIRLS.  Then for two years (2003 and 2015) when there are
// both PISA and TIMSS rounds, average PISA and TIMSS together 
/******************************************************************************/
// First align and average TIMSS and PIRLS since both done by same organization, same units
// and roughly on same four-year cycle -- align with TIMSS 4-year cycle 2003/2007/2011/2015
// Check years in which TIMSS and PIRLS done
tab year if hlo_timss_mf~=.
tab year if hlo_pirls_mf~=.

// Average together 2016 PIRLS and 2015 TIMSS, put in 2015
foreach gender in m f mf{
	qui gen xx=F.hlo_pirls_`gender' if year==2015
	qui egen hlo_timsspirls_`gender'=rowmean(hlo_timss_`gender' xx) if year==2015
	qui gen hlo_timsspirls_`gender'_source="TIMSS" if hlo_timss_`gender'~=. & xx==. & year==2015
	qui replace hlo_timsspirls_`gender'_source="PIRLS" if hlo_timss_`gender'==. & xx~=. & year==2015
	qui replace hlo_timsspirls_`gender'_source="TIMSS/PIRLS" if hlo_timss_`gender'~=. & xx~=. & year==2015
	qui drop xx
	}
// Average together 2011 PIRLS and TIMSS
foreach gender in m f mf{
	qui egen xx=rowmean(hlo_timss_`gender' hlo_pirls_`gender') if year==2011
	qui replace hlo_timsspirls_`gender'=xx if year==2011
	qui replace hlo_timsspirls_`gender'_source="TIMSS" if hlo_timss_`gender'~=. & hlo_pirls_`gender'==. & year==2011
	qui replace hlo_timsspirls_`gender'_source="PIRLS" if hlo_timss_`gender'==. & hlo_pirls_`gender'~=. & year==2011
	qui replace hlo_timsspirls_`gender'_source="TIMSS/PIRLS" if hlo_timss_`gender'~=. & hlo_pirls_`gender'~=. & year==2011
	qui drop xx
	}
// Average together 2007 TIMSS and 2006 PIRLS, put in 2007
foreach gender in m f mf{
	qui gen xx=L.hlo_pirls_`gender' if year==2007
	qui egen xxx=rowmean(hlo_timss_`gender' xx) if year==2007
	qui replace hlo_timsspirls_`gender'=xxx if year==2007
	qui replace hlo_timsspirls_`gender'_source="TIMSS" if hlo_timss_`gender'~=. & xx==. & year==2007
	qui replace hlo_timsspirls_`gender'_source="PIRLS" if hlo_timss_`gender'==. & xx~=. & year==2007
	qui replace hlo_timsspirls_`gender'_source="TIMSS/PIRLS" if hlo_timss_`gender'~=. & xx~=. & year==2007
	qui drop xx xxx
	}
// Average together 2003 TIMSS and 2001 PIRLS, put in 2003
foreach gender in m f mf{
	qui gen xx=L2.hlo_pirls_`gender' if year==2003
	qui egen xxx=rowmean(hlo_timss_`gender' xx) if year==2003
	qui replace hlo_timsspirls_`gender'=xxx if year==2003
	qui replace hlo_timsspirls_`gender'_source="TIMSS" if hlo_timss_`gender'~=. & xx==. & year==2003
	qui replace hlo_timsspirls_`gender'_source="PIRLS" if hlo_timss_`gender'==. & xx~=. & year==2003
	qui replace hlo_timsspirls_`gender'_source="TIMSS/PIRLS" if hlo_timss_`gender'~=. & xx~=. & year==2003
	qui drop xx xxx 
	}
// Check all the labels are assigned correctly
//list wbcode year hlo_timss_mf hlo_pirls_mf hlo_timsspirls_mf hlo_timsspirls_mf_source if hlo_timsspirls_mf_source~=""
//tab hlo_timsspirls_mf_source if year==2003
//tab hlo_timsspirls_mf_source if year==2007
//tab hlo_timsspirls_mf_source if year==2011
//tab hlo_timsspirls_mf_source if year==2015

// Finally average together TIMSS/PIRLS and PISA in 2003 and 2015 where both are available
foreach gender in m f mf{
	qui egen hlo_`gender'=rowmean(hlo_pisa_`gender' hlo_timsspirls_`gender')
	qui gen hlo_`gender'_source="PISA" if hlo_pisa_`gender'~=. & hlo_timsspirls_`gender'==.
	qui replace hlo_`gender'_source="TIMSS/PIRLS" if hlo_pisa_`gender'==. & hlo_timsspirls_`gender'~=.
	qui replace hlo_`gender'_source="PISA+TIMSS/PIRLS" if hlo_pisa_`gender'~=. & hlo_timsspirls_`gender'~=.
	}
	
// Check if labels are in correct years
//tab year if hlo_timsspirls_mf~=.
//tab year if hlo_pisa_mf~=.
//tab hlo_mf_source
//tab year if hlo_mf_source=="PISA"
//tab year if hlo_mf_source=="TIMSS/PIRLS"
//tab year if hlo_mf_source=="PISA+TIMSS/PIRLS"
drop hlo_timsspirls_*_source

/******************************************************************************/
// Step 2:  Add in regional tests (LLECE, SACMEQ and PASEC)
// Only for country/years where pisa/timss/pirls is missing, i.e. don't average
// This is relevant for 2006 LLECE round where 6 countries have PISA too
// And for BWA which has SACMEQ and TIMSS in same year
// Finally note that only one country (MUS) appears in PASEC and core international tests
/******************************************************************************/
foreach gender in m f mf{
	qui replace hlo_`gender'=hlo_llece_`gender' if hlo_`gender'==. & hlo_llece_`gender' ~=.
	qui replace hlo_`gender'=hlo_sacmeq_`gender' if hlo_`gender'==. & hlo_sacmeq_`gender'~=.
	qui replace hlo_`gender'=hlo_pasec_`gender' if hlo_`gender'==. & hlo_pasec_`gender'~=.
	qui replace hlo_`gender'_source="LLECE" if hlo_`gender'==hlo_llece_`gender' & hlo_`gender'~=. & hlo_llece_`gender'~=.
	qui replace hlo_`gender'_source="SACMEQ" if hlo_`gender'==hlo_sacmeq_`gender' & hlo_`gender'~=. & hlo_sacmeq_`gender'~=.
	qui replace hlo_`gender'_source="PASEC" if hlo_`gender'==hlo_pasec_`gender' & hlo_`gender'~=. & hlo_pasec_`gender'~=.
	}
// Count of observations based on core 6 tests by country
egen core_count_mf=count(hlo_mf), by(wbcode)


/******************************************************************************/
// Step 3:  Fill in hlo data from remaining tests (EGRA, EGRANR and national assessments)
/******************************************************************************/
// Generate series hlo_noncore_`gender' that combines EGRA and EGRANR
foreach gender in m f mf{
	qui gen hlo_noncore_`gender'=hlo_egra_`gender' if hlo_egra_`gender'~=.
	qui gen hlo_noncore_`gender'_source="EGRA" if hlo_egra_`gender'~=. & hlo_noncore_`gender'==hlo_egra_`gender'
	qui replace hlo_noncore_`gender'=hlo_egranr_`gender' if hlo_egranr_`gender'~=. & hlo_noncore_`gender'==.
	qui replace hlo_noncore_`gender'_source="EGRANR" if hlo_egranr_`gender'~=. & hlo_noncore_`gender'==hlo_egranr_`gender'
	}
// Generate variable noncore_count_mf counting up whether country has both 
// representative and non-representative EGRA  
foreach test in egra egranr{
	egen `test'_count_mf=count(hlo_`test'_mf), by(wbcode)
	replace `test'_count_mf=1 if `test'_count_mf>1 & `test'_count_mf~=.
	}
egen noncore_count_mf=rowtotal(egra_count_mf egranr_count_mf)

// For countries with no core tests, and either just EGRA or just EGRANR 
// (i.e. noncore_count_mf==1), simply use EGRA or EGRANR (no decision needed)
foreach gender in m f mf{
	qui replace hlo_`gender'=hlo_noncore_`gender' if hlo_`gender'==. & hlo_noncore_`gender'~=. & noncore_count_mf>=1 & noncore_count_mf~=. & core_count_mf==0
	qui replace hlo_`gender'_source=hlo_noncore_`gender'_source if hlo_`gender'==hlo_noncore_`gender' & hlo_noncore_`gender'~=. & hlo_`gender'~=.
	}
// Check it worked
//list wbcode year egra_count_mf egranr_count_mf if hlo_mf_source=="EGRA"
//list wbcode year egra_count_mf egranr_count_mf if hlo_mf_source=="EGRANR"

// For all other EGRA and EGRANR tests, we need to check manually how they fit with each other
// and with the core tests.  First generate list of countries in question
tab wbcode if noncore_count_mf>0 & noncore_count_mf~=. & core_count_mf>0 & core_count_mf~=.

// Decisions
// Use only core tests:  	BDI EGY IDN JOR KEN MAR MKD MWI NIC SEN UGA YEM ZMB
// Add in non core tests: 	COD GHA HND KGZ MLI PHL TZA

// Graphing tool to superimpose non-core sources on top of hlo based on core sources, use to help make the decisions in Step 3
//local ctry "ZMB"
//twoway (scatter hlo_mf year if wbcode=="`ctry'", connect(J) mlabel(hlo_mf_source) mlabangle(90) mlabposition(12) mlabgap(5)) ////
//		(scatter hlo_noncore_mf year if wbcode=="`ctry'", mlabel(hlo_noncore_mf_source) mlabangle(90) mlabposition(12) mlabgap(5))  ///
//		if year>=2000, yscale(range(200 700)) ylabel(200 300 400 500 600 700) title("Harmonized Learning Outcomes: `ctry'") ///
//		legend(label(1 "Combined HLO") label(2 "Non-Core HLO"))

// Implement decisions
gen add_noncore=1 if hlo_noncore_mf~=. & (wbcode=="COD" | wbcode=="GHA" | wbcode=="HND" | wbcode=="KGZ" | wbcode=="MLI" | wbcode=="PHL" | wbcode=="TZA") 
foreach gender in m f mf{
	replace hlo_`gender'=hlo_noncore_`gender' if hlo_`gender'==. & hlo_noncore_`gender'~=. & add_noncore==1
	replace hlo_`gender'_source=hlo_noncore_`gender'_source if hlo_`gender'==hlo_noncore_`gender' & hlo_noncore_`gender'~=. & add_noncore==1
	}
		
// Drop "non-core" variables since not used after this point
foreach gender in m f mf{
	drop hlo_noncore_`gender'
	drop hlo_noncore_`gender'_source
	}

/******************************************************************************/
// Step 4:  Bring in national assessments that have been linked through other means
// NOT DOING THIS FOR CHINA PENDING CONFIRMATION WE ACTUALLY HAVE THE RIGHT NUMBER
/******************************************************************************/	
foreach gender in m f mf{
	replace hlo_`gender'=hlo_naeq_`gender' if wbcode=="CHN" & year==2012
	replace hlo_`gender'_source="National" if wbcode=="CHN" & year==2012
	replace hlo_`gender'=hlo_lkana_`gender' if wbcode=="LKA" & year==2009
	replace hlo_`gender'_source="Linked National Assessment" if wbcode=="LKA" & year==2009
	}
	

/******************************************************************************/
// Step 5:  Miscellaneous overrides of the previous steps
/******************************************************************************/	
// Note that PISA scores for MYS in 2015 are not reported by PISA itself because of concerns about representativeness
// of set of schools participating (see email exchange with Gabriel Desmombynes Aug 25)
// Replace MYS HLO score with just TIMSS in 2015
// AS OF AUG 29 HLO DELIVERY THIS SECTION IS REDUNDANT BECAUSE MYS-PISA-2015 HAS BEEN DROPPED FROM INPUT DATASET
foreach gender in m f mf{
	qui replace hlo_`gender'=hlo_timss_`gender' if wbcode=="MYS" & year==2015
	qui replace hlo_`gender'_source="TIMSS" if wbcode=="MYS" & year==2015
	}

// Yemen TIMSS 2007 and 2011 score near 200 is implausibly low.  2011 TIMSS report indicates that the mean is not well-estimated because so many
// students did not register proficiency.  Override rule of using TIMSS over EGRA to put EGRA instead in 2011 and drop 2007 TIMSS.
foreach gender in m f mf{
	qui replace hlo_`gender'=hlo_egra_`gender' if wbcode=="YEM" & year==2011
	qui replace hlo_`gender'_source="EGRA" if wbcode=="YEM" & year==2011
	qui replace hlo_`gender'=. if wbcode=="YEM" & year==2007
	qui replace hlo_`gender'_source="" if wbcode=="YEM" & year==2007
	}

	
/******************************************************************************/
// Generate variable to keep track of un-used tests
/******************************************************************************/
foreach gender in m f mf{
	gen hlo_`gender'_unused=.
	gen hlo_`gender'_unused_source=""
	foreach test in llece sacmeq pasec egra egranr{
		qui replace hlo_`gender'_unused=hlo_`test'_`gender' if hlo_`test'_`gender'~=. & hlo_`gender'_source~=upper("`test'")
		qui replace hlo_`gender'_unused_source=upper("`test'") if hlo_`test'_`gender'~=. & hlo_`gender'_source~=upper("`test'")
		}
	}
list wbcode year hlo_mf_unused hlo_mf_unused_source if hlo_mf_unused~=.

/******************************************************************************/
// Summarize resulting coverage of combined series
/******************************************************************************/
/*
// Total number of tests
egen hlo_mf_count=rownonmiss(hlo_pisa_mf hlo_timss_mf hlo_pirls_mf hlo_sacmeq_mf hlo_pasec_mf hlo_llece_mf hlo_yl_mf hlo_sdi_mf hlo_egra_mf hlo_egranr_mf)
egen xx=sum(hlo_mf_count)
su xx
drop xx
// Unused tests
su hlo_mf_unused if hlo_mf_unused~=.
// Distribution of sources for hlo scores
tab hlo_mf_source
*/

/******************************************************************************/	
// Fill in missing data with lags
// First block below does so for numeric variables
// Second block does so for string variables which needs different [_n-i] syntax to generate lags of string variable containing source
// Stata cannot take lags of string variables using standard L. syntax
// Since no hlo data in 1950s for any country don't need to worry about [_n-i] "crossing" country observations
// Note that we go back 11 lags (to 2006) unlike for other HCI components
// This is to be able to include GAB, COM (2006 PASEC only) and CUB (2006 LLECE only)
/******************************************************************************/
// For numeric variables
foreach var in hlo_m hlo_f hlo_mf{
		qui gen xx_0=`var'
		qui gen `var'_year=year if `var'~=.
		qui gen `var'_fill=`var' if `var'~=.
		forvalues i=1/11{
			qui gen xx_`i'=xx_`=scalar(`i'-1)'
			qui replace xx_`i'=L`i'.`var' if xx_`i'==. & year<=2017
			qui replace `var'_year=L`i'.year if xx_`i'~=. & xx_`=scalar(`i'-1)'==. & year<=2017
			}
		qui replace `var'_fill=xx_11 if `var'==.
		qui gen `var'_rep=`var'
		qui drop xx*
	}

// For string variables
foreach gender in m f mf{
	qui gen hlo_`gender'_source_fill=hlo_`gender'_source if hlo_`gender'~=.
	forvalues i=1/11{
		qui replace hlo_`gender'_source_fill=hlo_`gender'_source[_n-`i'] if hlo_`gender'_year==L`i'.hlo_`gender'_year & hlo_`gender'_fill~=. & year<=2017
		}
	}

// Miscellaneous overrides of lag rule
// Mauritania can be include in HCI if we go back to PASEC 2004
foreach gender in m f mf{
	qui su hlo_pasec_`gender' if year==2004 & wbcode=="MRT"
	qui replace hlo_`gender'_fill=r(mean) if wbcode=="MRT" & year>=2004 & year<=2017
	qui replace hlo_`gender'_year=2004 if wbcode=="MRT" & year>=2004 & year<=2017
	qui replace hlo_`gender'_source_fill="PASEC" if wbcode=="MRT" & year>=2004 & year<=2017
	}
	
// Rename the _source and _source_fill variable to avoid confusion with other variable sets
// hlo_mf_src contains the test type in the year that the HLO is observed
// hlo_mf_source is the "filled in" version of hlo_mf_src
// Same test for both genders, preserve gender disaggregation of source variable only for convenience in code
foreach gender in m f mf{
	qui rename hlo_`gender'_source hlo_`gender'_src
	qui rename hlo_`gender'_source_fill hlo_`gender'_source
	}

/******************************************************************************/
// Check that _m and _f versions of filled-in hlo are filling in from
// the same source year, if not, drop the gender-disaggregated series 
// This matters for a few country-year-test observations where we have _mf
// but not _m and _f
/******************************************************************************/
foreach var in hlo{
	// indicators for years where there is a problem
	qui gen xx_`var'_m=1 if `var'_m_year~=`var'_mf_year & `var'_m_year~=. & `var'_mf_year~=. 
	qui gen xx_`var'_f=1 if `var'_f_year~=`var'_mf_year & `var'_f_year~=. & `var'_mf_year~=. 
	// display frequency of problem
	su `var'_mf_year xx_`var'_m xx_`var'_f
	// fix problem by dropping the disaggregated variables
	foreach gender in m f{
		qui replace `var'_`gender'_year=. if xx_`var'_`gender'==1
		qui replace `var'_`gender'_fill=. if xx_`var'_`gender'==1
		qui replace `var'_`gender'_source="" if xx_`var'_`gender'==1
		}
	drop xx_`var'_m xx_`var'_f
	}

/******************************************************************************/	
// Create a generic "Note" series to store qualifications about test scores
// No need to disaggregate by gender.  Report in country data tables
/******************************************************************************/	
gen hlo_mf_note="Patrinos and Angrist (2018)" if hlo_mf_fill~=.
replace hlo_mf_note="Patrinos and Angrist (2018).  Data refer to Shanghai." if wbcode=="CHN" & (year==2009 | year==2012)
replace hlo_mf_note="Patrinos and Angrist (2018).  Data refer to Beijing, Shanghai, Jiangsu and Guangdong." if wbcode=="CHN" & year==2015
	
/******************************************************************************/	
// Label key variables and export dataset for merging
/******************************************************************************/	
foreach gender in m f mf{
	label var hlo_`gender'_rep "Combined HLO series, gender=`gender', as reported"
	label var hlo_`gender'_fill "Combined HLO series, gender=`gender', gaps filled with lags"
	label var hlo_`gender'_year "Combined HLO series, gender=`gender', year of most recent estimate"
	label var hlo_`gender'_source "Name of testing program for combined HLO series, gender=`gender'"
	label var hlo_`gender'_unused "HLO not included in combined HLO series, gender=`gender'"
	label var hlo_`gender'_unused_source "Name of testing program for HLO not included in combined HLO series, gender=`gender'"
	}
label var hlo_mf_note "Generic source note for HLO data.  Also contains qualifier for non-representative China scores"


