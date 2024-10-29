/******************************************************************************/
// Purpose		: Prepares test score data for merge with HCI 2020 database
// Input data	: HLO_MEAN_DSEX_SE_25Mar2020.dta provided by Harry/Noam/Aroob
// Output data	: hlo.dta; hlo_8May2020.dta
// Last edited	: Aug 19, 2020
// Last run		: Aug 19, 2020
// Written by	: Ritika, based on Aart's 2018 versions

/* Structure of this do file:
1. Preliminaries
2. Identify new tests in the HLO metadata file relative to Aug 2018 version
3. Standardize variable names and clean up various issues in HLO metadata file
4. Collapse data across subject-grades
5. Combine test scores from different programs into smooth-as-possible unique country x year time series
6. Fill in missing data with lags
7. Label variables and save dataset
*/
/******************************************************************************/

*******************************************************************************/
// 1. Preliminaries
/******************************************************************************/
set more off
clear 
global path = "$clone"     //user = SAI

use "$clone\03_HLO\033_output\HLO_MEAN_DSEX_SE_v01.dta", clear
	
*******************************************************************************/
// 3. Standardize variable names and clean up various issues in HLO metadata file
*******************************************************************************/
	rename *, lower
	
	// Drop variables that are not required 
	//(standard errors, range, uncertainty coming from original scores, uncertainty intervals for original scores)
	drop se* *_range os_share score_*lower score_*upper hlo_se hlo_*_se
	
	// Standardize variable names
	rename cntabb wbcode
	rename hlo hlo_mf
	rename hlo_lower hlo_mf_lower
	rename hlo_upper hlo_mf_upper
	rename score score_mf
	
	foreach gen in mf m f {
		rename score_`gen' os_`gen'
	}
	
	rename d_index hlo_exrt
	rename d_index_se hlo_exrt_se
	
	// Fix country code for Serbia and Central African Republic
	replace wbcode="SRB" if wbcode=="SCG"
	replace wbcode="CAF" if wbcode=="CAR"
	
	// Drop separate values for ENG, NIR, SCD
	drop if wbcode=="ENG" | wbcode=="NIR" | wbcode=="SCD"
	
	// Drop PILNA countries that are not WB member countries
	drop if wbcode=="COK" | wbcode=="NIU" | wbcode=="TKL"
	
	// Drop MLA testing program since we won't be using it
	drop if test=="MLA"
	
	// Drop PISA-D testing program, except for BTN
	// Results from PISA-D vary a lot, especially for AFR countries where scores are 
	// below 200; we keep BTN though because we have no other test
	drop if year==2017 & test=="PISA" & wbcode=="ECU"
	drop if year==2017 & test=="PISA" & wbcode=="GTM"
	drop if year==2017 & test=="PISA" & wbcode=="HND"
	drop if year==2017 & test=="PISA" & wbcode=="KHM"
	drop if year==2017 & test=="PISA" & wbcode=="PRY"
	drop if year==2017 & test=="PISA" & wbcode=="SEN"
	drop if year==2017 & test=="PISA" & wbcode=="ZMB"


	// Rename PASEC (Aroob has separate name for it because PASEC 2014 is harmonized
	// separately from previous round of PASEC)
	replace test="PASEC" if test=="PASEC_2014"
	
	//  Short names for national assessments  
	// AK -- THIS IS A CASE WE WILL HAVE TO DISCUSS WITH COUNTRY TEAM SINCE A SUBSEQUENT NATIONAL ASSESSMENT WAS USED IN LEARNING POVERTY DATABASE
	replace test="Linked National Assessment" if test=="National Assessment" & wbcode=="LKA"
	
	// Identify non-nationally representative EGRAs 
	tab test if n_res==0 // 32 EGRAs (18 countries); 6 PISAs (4 countries); 1 PIRLS (1 country)
	replace test= "EGRANR" if test=="EGRA" & n_res==0
	drop n_res
	
	// NPL and SSD have no record-level data for tests so no standard errors and ranges
	// Both are EGRA, so use average range for other EGRA countries
		foreach gender in m f mf{
			qui gen xx=hlo_`gender'_upper-hlo_`gender'_lower if test=="EGRA"
			su xx
			qui replace hlo_`gender'_lower=hlo_`gender'-r(mean)/2 if (wbcode=="NPL" | wbcode=="SSD") & (test=="EGRA" | test=="EGRANR")
			qui replace hlo_`gender'_upper=hlo_`gender'+r(mean)/2 if (wbcode=="NPL" | wbcode=="SSD") & (test=="EGRA" | test=="EGRANR")
			drop xx
		}

	// check it worked -- it does
	//br wbcode year test grade subject hlo_mf hlo_mf_lower hlo_mf_upper if wbcode=="NPL" | wbcode=="SSD"

	// EL Salvador, remove TIMSS 2007 and keep LLECE 3rd grade reading
	// Also change test to EGRA NR in 2018
	// This is based on communication with the El Salvador team (see communication from Aug 16, 2020)
	
	drop if wbcode=="SLV" & test=="TIMSS" & year==2007
	drop if wbcode=="SLV" & test=="LLECE" & year==2006 & subject!="reading" 
	drop if wbcode=="SLV" & test=="LLECE" & year==2006 & grade=="6"
	replace test = "EGRANR" if wbcode=="SLV" & test=="EGRA" & year==2018
	//replace test = "LLECE-reading" if wbcode=="SLV" & test=="LLECE" & year==2006

	// Remove primary test scores from TIMSS for DZA, BIH, LBN, MKD, MAR, SAU, UKR
	// Modified on Aug 20, 2020 in order to make comparisons with HLO 2010 consistent
	*===============================================================================
	drop if grade<"7" & test=="TIMSS" & year==2007 & inlist(wbcode,"DZA","BIH","LBN", "MAR", "UKR") //Only affects Algeria, Morocco, and Ukarine
	drop if grade<"7" & test=="TIMSS" & year==2011 & inlist(wbcode,"MAR","SAU", "UKR","MKD") //Only affects Morocco and Saudi Arabia, others don't have test for primary
	drop if grade<"7" & test=="PIRLS" & year==2011 & inlist(wbcode,"MAR","SAU", "UKR","MKD") //Only affects Morocco and Saudi Arabia, others don't have test for primary

	order wbcode year test subject grade hlo* 


/******************************************************************************/
// 4. Collapse data across subjects/grades
/******************************************************************************/
// Equally-weight across subjects in a given level (primary or secondary)
// Then equally-weight across levels

	// Generate variable for school level
	gen primary_secondary = (inlist(grade,"2-4","3","4","5","6"))
		label define primary_secondary 0 "Secondary" 1 "Primary"
		label values primary_secondary primary_secondary
		
// Generate primary and secondary score for each subject
// This collapeses 3 and 6 grade math and reading from LLECE; 
collapse hlo* os*, by(wbcode year test subject primary_secondary)

// Average across primary and secondary for each subject
// This collapses primary and secondary math and science from TIMSS
collapse hlo* os*, by(wbcode year test subject)

// Average across subjects
collapse hlo* os*, by(wbcode year test)


/******************************************************************************/
// 5. Combine test scores from different programs into smooth-as-possible unique country x year time series
// This is done in three steps:
// 5.1 Combine PISA/TIMSS/PIRLS
// 5.2 Combine PISA/TIMSS/PIRLS with regional programs (LLECE, SACMEQ, PASEC, PILNA) and EGRA
// 5.3 Miscellaneous special cases
// 5.4 Remove all the "unused" tests from the core series 
// 5.5 Collapse to country-year
/******************************************************************************/
// Generate variable to keep track of source test
	foreach gen in mf m f {
		gen source_`gen'=test
	}

/******************************************************************************/
// 5.1 Combine PISA/TIMSS/PIRLS
/******************************************************************************/
// Move BTN PISA-D 2017 to 2018 to align with the rest of PISA
	replace year=2018 if year==2017 & wbcode=="BTN"

// Combine PISA/TIMSS/PIRLS
// First move PIRLS to nearest TIMSS year and average
// Note that actual years of tests are:
// TIMSS 2003 2007 2011 2015; PIRLS 2001 2006 2011 2016
	replace year=2003 if year==2001 & test=="PIRLS"
	replace year=2007 if year==2006 & test=="PIRLS"
	replace year=2015 if year==2016 & test=="PIRLS"
	replace test="TIMSS/PIRLS" if test=="TIMSS" | test=="PIRLS"
	
collapse (mean) hlo_* os_* (firstnm)source_*, by(wbcode year test)  

	foreach gen in mf m f {
		replace source_`gen'=test 
	}

// Next average TIMSS/PIRLS with PISA
duplicates tag wbcode year if (test=="PISA" | test=="TIMSS/PIRLS") & (year==2003 | year==2015), gen(x)
	replace test="PISA+TIMSS/PIRLS" if (test=="PISA" | test=="TIMSS/PIRLS") & (year==2003 | year==2015) & x==1
collapse (mean) hlo_* os_* (firstnm)source_*, by(wbcode year test)
	
	foreach gen in mf m f {
		replace source_`gen'= "PISA+TIMSS/PIRLS" if test=="PISA+TIMSS/PIRLS" 
	}

	rename source_* hlo_*_source
	
/******************************************************************************/
// 5.2 Combine PISA/TIMSS/PIRLS with regional programs (LLECE, SACMEQ, PASEC, PILNA) and EGRA
// Hierarchy of tests:  
//		Use PISA/TIMSS/PIRLS if available
// 		Use LLECE, SACMEQ, PASEC, PILNA if available
//		If country ONLY has EGRA, use EGRA
// 		If country has EGRA and other tests, use judgment, hardcoded below
// Implement this by generating an "unused" test series, into which we copy every 
// test we don't use.  In step 5.4 use this as marker to replace the hlo series as missing
/******************************************************************************/
// Generate variable to keep track of unused tests
	foreach gen in mf m f {
		gen hlo_`gen'_unused=.
		gen hlo_`gen'_unused_source=""
	}

// Check for LLECE coinciding with a PISA/TIMSS/PIRLS test in a given year (check manually with browse)
//bys wbcode: egen xx=count(test) if (test=="LLECE")
//bys wbcode: egen llece_ct=max(xx)
//drop xx
//br if llece_ct>0 & llece_ct~=.
//drop llece_ct
// Drop the few country-year observations which have LLECE in same year as PISA 2006
	foreach ct in ARG BRA CHL COL URY MEX {
		foreach gen in mf m f {
			replace hlo_`gen'_unused= hlo_`gen' if wbcode=="`ct'" & year==2006 & test=="LLECE"
			replace hlo_`gen'_unused_source=test if wbcode=="`ct'" & year==2006 & test=="LLECE"
		}
	}

// Check for SACMEQ coinciding with a PISA/TIMSS/PIRLS test in a given year (check manually with browse)
// Happens for ZAF, BWA with TIMSS 2007
//bys wbcode: egen xx=count(test) if (test=="SACMEQ")
//bys wbcode: egen sacmeq_ct=max(xx)
//drop xx
//br if sacmeq_ct>0 & sacmeq_ct~=.
//drop sacmeq_ct	
	foreach ct in BWA ZAF {
		foreach gen in mf m f {
			replace hlo_`gen'_unused= hlo_`gen' if wbcode=="`ct'" & year==2007 & test=="SACMEQ"
			replace hlo_`gen'_unused_source=test if wbcode=="`ct'" & year==2007 & test=="SACMEQ"
		}
	}

// Check for PASEC coinciding with a PISA/TIMSS/PIRLS test in a given year (check manually with browse)
// Does not happen
//bys wbcode: egen xx=count(test) if (test=="PASEC")
//bys wbcode: egen pasec_ct=max(xx)
//drop xx
//br if pasec_ct>0 & pasec_ct~=.
//drop pasec_ct

// Check for PILNA coinciding with a PISA/TIMSS/PIRLS test in a given year (check manually with browse)
// Does not happen
//bys wbcode: egen xx=count(test) if (test=="PILNA")
//bys wbcode: egen pilna_ct=max(xx)
//drop xx
//br if pilna_ct>0 & pilna_ct~=.
//drop pilna_ct	


// Identify countries with only EGRA (in which case we just use what we have)
// and countries with EGRA and other tests (in which case we decide on case-by-case basis)
	bys wbcode: egen xx=count(test) if (test=="EGRA" | test=="EGRANR") 
	bys wbcode: egen egra_ct=max(xx)		
	drop xx
	bys wbcode: egen xx=count(test)  		
	bys wbcode: egen test_ct=max(xx)
	drop xx
	tab wbcode if egra_ct>0 & egra_ct==test_ct  // List of countries where EGRA is the only test
	tab wbcode if egra_ct~=. & egra_ct<test_ct 	// List of countries which have EGRA and other tests
// Manually check each of these countries to decide which ones we drop the EGRAs from
// Use graphing tool at end of code to do this

// Drop EGRAs and use only core tests for a set of countries
	foreach ct in BDI EGY IDN JOR KEN MAR MKD MWI NIC SEN UGA ZMB {
		foreach gen in mf m f {
			replace hlo_`gen'_unused= hlo_`gen' if wbcode=="`ct'" & (test=="EGRA" | test=="EGRANR")
			replace hlo_`gen'_unused_source= test if wbcode=="`ct'" & (test=="EGRA" | test=="EGRANR")
		}
	}
// For all other countries we allow EGRA to be interspersed with other tests -- no action required
// AK: ONCE PILNA DATA COMES, NEED TO CHECK HOW EGRA FITS INTO PILNA SERIES FOR KIR, PNG, SLB, TON, TUV, VUT, WSM
// RD: CHECKED; EGRA FITS REASONABLY WELL INTO PILNA SERIES

/******************************************************************************/
// 5.3 Remove all the "unused" tests from the core series and collapse to country-year
/******************************************************************************/
// Finally, go through all the HLO variables and set to missing for cases where we moved data to hlo_unused
	foreach var in hlo_exrt hlo_exrt_se {
		foreach hlo in hlo os {
			foreach gen in mf m f {
				foreach ub in upper lower {
					replace `var'= . if hlo_mf_unused!=. 
					replace `hlo'_`gen'= . if hlo_mf_unused!=.
					replace hlo_`gen'_`ub'= . if hlo_mf_unused!=.
					replace hlo_`gen'_source= "" if hlo_mf_unused!=.
					replace test= "" if hlo_mf_unused!=.
				} //END UB
			} //END GEN
		} //END HLO
	} //END VAR

// Doublecheck to be sure that each country-year observation has only one test after all these changes
// Last checked:  Feb 2, 2020 -- OK
//egen xx=count(hlo_mf), by(wbcode year)
//tab xx

/******************************************************************************/
// 5.4 Special Cases 
/******************************************************************************/
// UPDATE INDIA SCORES BASED ON DIALOGUE WITH COUNTRY TEAM
// Special Case: India
// INDIA scores
local IND_hlo = 399
local IND_y   = 2017
local IND_s NAS (Extrapolated)

// First move PISA 2009 that was non-representative to an unused test
	foreach gen in mf m f {
		replace hlo_`gen'_unused= hlo_`gen' if wbcode=="IND" & year==2009 & test=="PISA"
		replace hlo_`gen'_unused_source= test if wbcode=="IND" & year==2009 & test=="PISA"
	}
	
	foreach var in hlo_exrt hlo_exrt_se {
		foreach hlo in hlo os {
			foreach gen in mf m f {
				foreach ub in upper lower {
					replace `var'= . if hlo_mf_unused!=. 
					replace `hlo'_`gen'= . if hlo_mf_unused!=.
					replace hlo_`gen'_`ub'= . if hlo_mf_unused!=.
					replace hlo_`gen'_source= "" if hlo_mf_unused!=.
					replace test= "" if hlo_mf_unused!=.
				} // end of ub
			} //end of gen
		} //end of hlo
	} //end of var

// Next replace with extrapolated data  
// USE 399 AS A PLACEHOLDER BUT UPDATE ONCE DIALOGUE WITH INDIA TEAM CLOSES
set obs `=_N+1'
	replace wbcode="IND" if wbcode==""
	replace year=`IND_y' if wbcode=="IND" & year==.
	foreach gender in m f mf{
		replace hlo_`gender'        = `IND_hlo' if wbcode=="IND" & year==`IND_y'
		replace hlo_`gender'_lower  = `IND_hlo' if wbcode=="IND" & year==`IND_y'
		replace hlo_`gender'_upper  = `IND_hlo' if wbcode=="IND" & year==`IND_y'
		replace hlo_`gender'_source = "`IND_s'" if wbcode=="IND" & year==`IND_y'
	}
	replace test = "`IND_s'" if wbcode=="IND" & year==`IND_y'

// Special Case:  Yemen	
// Yemen TIMSS 2007 and 2011 score near 200 is implausibly low.  2011 TIMSS report indicates that the mean is not well-estimated because so many
// students did not register proficiency.  Override rule of using TIMSS over EGRA to put EGRA instead in 2011 and drop 2007 TIMSS.
// Drop the few country-year observations which have LLECE in same year as PISA/TIMSS/PIRLS
	foreach gen in mf m f {
		replace hlo_`gen'_unused= hlo_`gen' if wbcode=="YEM" & (year==2007 | year==2011) & test=="TIMSS/PIRLS"
		replace hlo_`gen'_unused_source= test if wbcode=="YEM" & (year==2007 | year==2011) & test=="TIMSS/PIRLS"
	}

	foreach var in hlo_exrt hlo_exrt_se {
		foreach hlo in hlo os {
			foreach gen in mf m f {
				foreach ub in upper lower {
					replace `var'= . if hlo_mf_unused!=. 
					replace `hlo'_`gen'= . if hlo_mf_unused!=.
					replace hlo_`gen'_`ub'= . if hlo_mf_unused!=.
					replace hlo_`gen'_source= "" if hlo_mf_unused!=.
					replace test= "" if hlo_mf_unused!=.
				}
			}
		}
	}

// Special Case:  China
// Drop China since we did not use PISA-based scores in HCI, replace with PISA/PIRLS extrapolation  
	drop if wbcode=="CHN" & test=="NAEQ"
	replace test= "PISA (Shanghai Only)" if wbcode=="CHN" & (year==2009 | year==2012)
	replace test= "PISA (Beijing-Shanghai-Jiangsu-Guangdong Only)" if wbcode=="CHN" & (year==2015)
	replace test= "PISA (Beijing-Shanghai-Jiangsu-Zhejiang Only)" if wbcode=="CHN" & (year==2018)
	foreach yr in 2009 2012 2015 2018 {
		foreach gen in mf m f {
			replace hlo_`gen'_unused= hlo_`gen' if wbcode=="CHN" & year==`yr'
			replace hlo_`gen'_unused_source= test if wbcode=="CHN" & year==`yr'
		}
	}
	
	foreach var in hlo_exrt hlo_exrt_se {
		foreach hlo in hlo os {
			foreach gen in mf m f {
				foreach ub in upper lower {
					replace `var'= . if hlo_mf_unused!=. 
					replace `hlo'_`gen'= . if hlo_mf_unused!=.
					replace hlo_`gen'_`ub'= . if hlo_mf_unused!=.
					replace hlo_`gen'_source= "" if hlo_mf_unused!=.
					replace test= "" if hlo_mf_unused!=.
				}
			}
		}
	}

// Next replace with extrapolated data  
// Use 441 as midpoint, 432 and 449 as range, as documented in China note (Feb 5, 2020)
// This is for gender-combined.  In 2015 PISA the gender disaggregated rates are same for boys and girls (rounded to zero decimal places) at 532
// Based on this make assumption that gender-disaggregated extrapolated performance is same for boys and girls
	foreach gender in m f mf{
		replace hlo_`gender'=. if wbcode=="CHN" & year==2015
		replace hlo_`gender'=441 if wbcode=="CHN" & year==2015
		replace hlo_`gender'_lower=. if wbcode=="CHN" & year==2015
		replace hlo_`gender'_lower=432 if wbcode=="CHN" & year==2015
		replace hlo_`gender'_upper=449 if wbcode=="CHN" & year==2015
		replace hlo_`gender'_source="PISA/PIRLS (Extrapolated)" if wbcode=="CHN" & year==2015
	}
	replace test="PISA/PIRLS (Extrapolated)" if wbcode=="CHN" & year==2015
			
/******************************************************************************/
// 5.5 Collapse to country-year
/******************************************************************************/			
// Collapse data to create single sountry-year observations
collapse (mean) hlo_exrt hlo_exrt_se hlo_mf hlo_mf_lower hlo_mf_upper ///
	hlo_m hlo_m_lower hlo_m_upper hlo_f hlo_f_lower hlo_f_upper ///
	os_mf os_m os_f hlo_mf_unused hlo_m_unused hlo_f_unused ///
	(firstnm) test hlo_mf_source hlo_m_source hlo_f_source ///
	hlo_mf_unused_source hlo_m_unused_source hlo_f_unused_source , by(wbcode year)  

// Order data
order wbcode year test  ///		
	hlo_mf hlo_mf_lower hlo_mf_upper hlo_mf_source ///
	hlo_m hlo_m_lower hlo_m_upper hlo_m_source ///
	hlo_f hlo_f_lower hlo_f_upper hlo_f_source ///
	hlo_mf_unused hlo_mf_unused_source ///
	hlo_m_unused hlo_m_unused_source ///
	hlo_f_unused hlo_f_unused_source ///	
	os_mf os_m os_f hlo_exrt hlo_exrt_se	
	
	
/******************************************************************************/	
// 6. Fill in missing data with lags
/******************************************************************************/
// First block below does so for numeric variables
// Second block does so for string variables which needs different [_n-i] syntax to generate lags of string variable containing source
// Stata cannot take lags of string variables using standard L. syntax
// Since no hlo data in 1950s for any country don't need to worry about [_n-i] "crossing" country observations
// Note that we go back 11 lags (to 2006) unlike for other HCI components
// Did this in 2018 to be able to include 2006 data for Gabon, Comoros and Cuba
// Now this override is implemented below.  But leave 11 year lag to avoid confusion when comparing with previous versions of dataset
// AK: ONCE WE HAVE FINISHED WITH COMPARISONS TO 2018 VERSION OF DATA, REMOVE 11-YEAR LAG

// Merge test scores with master data
	merge 1:1 wbcode year using "$clone\01_input\masterdata.dta"
		drop _merge

// Fill in lags
	xtset countrynumber year

// For numeric variables
	foreach var in hlo_m hlo_f hlo_mf ///
		hlo_m_upper hlo_f_upper hlo_mf_upper ///
		hlo_m_lower hlo_f_lower hlo_mf_lower {
			qui gen xx_0=`var'
			qui gen `var'_year=year if `var'~=.
			qui gen `var'_fill=`var' if `var'~=.
			
			forvalues i=1/11{
				qui gen xx_`i'=xx_`=scalar(`i'-1)'
				qui replace xx_`i'=L`i'.`var' if xx_`i'==. & year<=2019
				qui replace `var'_year=L`i'.year if xx_`i'~=. & xx_`=scalar(`i'-1)'==. & year<=2019
			}
			
			qui replace `var'_fill=xx_11 if `var'==.
			qui gen `var'_rep=`var'
			qui drop xx*
	}
	
// For string variables
	foreach gender in m f mf{
		qui gen hlo_`gender'_source_fill=hlo_`gender'_source if hlo_`gender'~=.
		forvalues i=1/11{
			qui replace hlo_`gender'_source_fill=hlo_`gender'_source[_n-`i'] if hlo_`gender'_year==L`i'.hlo_`gender'_year & hlo_`gender'_fill~=. & year<=2019
		}
	}

// Miscellaneous overrides of lag rule.  Verified Feb 2 2020 that these overrides are still needed  
// Mauritania can be included in HCI if we go back to PASEC 2004
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2004 & wbcode=="MRT" & test=="PASEC"
			qui replace `var'_fill=r(mean) if wbcode=="MRT" & year>=2004 & year<=2019
		}
		qui replace hlo_`gender'_year=2004 if wbcode=="MRT" & year>=2004 & year<=2019
		qui replace hlo_`gender'_source_fill="PASEC" if wbcode=="MRT" & year>=2004 & year<=2019
	}
	// Gabon can be included in HCI if we go back to PASEC 2006
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2006 & wbcode=="GAB" & test=="PASEC"
			qui replace `var'_fill=r(mean) if wbcode=="GAB" & year>=2006 & year<=2019
		}
		qui replace hlo_`gender'_year=2006 if wbcode=="GAB" & year>=2006 & year<=2019
		qui replace hlo_`gender'_source_fill="PASEC" if wbcode=="GAB" & year>=2006 & year<=2019
	}
	// Comoros can be included in HCI if we go back to PASEC 2006
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2006 & wbcode=="COM" & test=="PASEC"
			qui replace `var'_fill=r(mean) if wbcode=="COM" & year>=2006 & year<=2019
		}
		qui replace hlo_`gender'_year=2006 if wbcode=="COM" & year>=2006 & year<=2019
		qui replace hlo_`gender'_source_fill="PASEC" if wbcode=="COM" & year>=2006 & year<=2019
	}
	// Guinea can be included in HCI if we go back to PASEC 2006
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2006 & wbcode=="GIN" & test=="PASEC"
			qui replace `var'_fill=r(mean) if wbcode=="GIN" & year>=2006 & year<=2019
		}
		qui replace hlo_`gender'_year=2006 if wbcode=="GIN" & year>=2006 & year<=2019
		qui replace hlo_`gender'_source_fill="PASEC" if wbcode=="GIN" & year>=2006 & year<=2019
	}
	// Cuba can be included in HCI if we go back to LLECE 2006
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2006 & wbcode=="CUB" & test=="LLECE"
			qui replace `var'_fill=r(mean) if wbcode=="CUB" & year>=2006 & year<=2019
		}
		qui replace hlo_`gender'_year=2006 if wbcode=="CUB" & year>=2006 & year<=2019
		qui replace hlo_`gender'_source_fill="LLECE" if wbcode=="CUB" & year>=2006 & year<=2019
	}
	// Mozambique can be included in HCI if we go back to SACMEQ 2007
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2007 & wbcode=="MOZ" & test=="SACMEQ"
			qui replace `var'_fill=r(mean) if wbcode=="MOZ" & year>=2007 & year<=2019
		}
		qui replace hlo_`gender'_year=2007 if wbcode=="MOZ" & year>=2007 & year<=2019
		qui replace hlo_`gender'_source_fill="SACMEQ" if wbcode=="MOZ" & year>=2007 & year<=2019
	}
	// Mongolia can be included in HCI if we go back to TIMSS/PIRLS 2007
	foreach gender in m f mf{
		foreach var in hlo_`gender' hlo_`gender'_upper hlo_`gender'_lower {
			qui su `var' if year==2007 & wbcode=="MNG" & test=="TIMSS/PIRLS"
			qui replace `var'_fill=r(mean) if wbcode=="MNG" & year>=2007 & year<=2019
		}
		qui replace hlo_`gender'_year=2007 if wbcode=="MNG" & year>=2007 & year<=2019
		qui replace hlo_`gender'_source_fill="TIMSS/PIRLS" if wbcode=="MNG" & year>=2007 & year<=2019
	}

// Rename the _source and _source_fill variable to avoid confusion with other variable sets
// hlo_mf_src contains the test type in the year that the HLO is observed
// hlo_mf_source is the "filled in" version of hlo_mf_src
// Same test for both genders, preserve gender disaggregation of source variable only for convenience in code
	foreach gender in m f mf{
		qui rename hlo_`gender'_source hlo_`gender'_src
		qui rename hlo_`gender'_source_fill hlo_`gender'_source
	}
	
	foreach ub in lower upper {
		foreach gender in m f mf{
			qui rename hlo_`gender'_`ub' hlo_`gender'_`ub'_b
			qui rename hlo_`gender'_`ub'_fill hlo_`gender'_`ub'
		}
	}

drop hlo_*_upper_* hlo_*_lower_*
	
// Check that _m and _f versions of filled-in hlo are filling in from
// the same source year, if not, drop the gender-disaggregated series 
// This matters for a few country-year-test observations where we have _mf
// but not _m and _f		
// RD: THIS HAPPENS FOR ALL PISA 2018 NOW SINCE WE DON'T HAVE THE GENDER-DISAGG SERIES YET
// ALSO FOR NEW EGRAS FOR GMB(2013, 2016), HTI(2015,2016), WHERE WE DON'T HAVE THE DISAGG SERIES YET
// ONLY CASES THAT WILL STAY ARE SACMEQ 2013 (BWA, KEN, LSO, MWI, MUS, NAM, SYC, ZAF, SWZ, UGA, ZMB, ZWE)
	foreach var in hlo{
		// indicators for years where there is a problem
		qui gen xx_`var'_m=1 if `var'_m_year~=`var'_mf_year & `var'_m_year~=. & `var'_mf_year~=. 
		qui gen xx_`var'_f=1 if `var'_f_year~=`var'_mf_year & `var'_f_year~=. & `var'_mf_year~=. 
		// display frequency of problem
		su `var'_mf_year xx_`var'_m xx_`var'_f
		// fix problem by dropping the disaggregated variables
		foreach gender in m f{
			qui replace `var'_`gender'_year   = .  if xx_`var'_`gender'==1
			qui replace `var'_`gender'_fill   = .  if xx_`var'_`gender'==1
			qui replace `var'_`gender'_lower  = .  if xx_`var'_`gender'==1
			qui replace `var'_`gender'_upper  = .  if xx_`var'_`gender'==1
			qui replace `var'_`gender'_source = "" if xx_`var'_`gender'==1
		}
		drop xx_`var'_m xx_`var'_f
	}


/******************************************************************************/
// 7.  Label variables and save dataset
// AK: NOTES BELOW WILL NEED TO BE UPDATED DEPENDING ON HOW EXACTLY NOAM AND HARRY DOCUMENT THE UPDATED DATABASE
/******************************************************************************/
// Create a generic "Note" series to store qualifications about test scores
// No need to disaggregate by gender.  Report in country data tables
	gen hlo_mf_note="Patrinos and Angrist (2018)" if hlo_mf_fill~=.
//UPDATE CHINA AND INDIA NOTES
	
// Label key variables and export dataset for merging
	foreach gender in m f mf{
		label var hlo_`gender'_rep "Combined HLO series, gender=`gender', as reported"
		label var hlo_`gender'_fill "Combined HLO series, gender=`gender', gaps filled with lags"
		label var hlo_`gender'_lower "Combined HLO series, Lower Bound, gender=`gender', gaps filled with lags"
		label var hlo_`gender'_upper "Combined HLO series, Upper Bound, gender=`gender', gaps filled with lags"
		label var hlo_`gender'_year "Combined HLO series, gender=`gender', year of most recent estimate"
		label var hlo_`gender'_source "Name of testing program for combined HLO series, gender=`gender'"
	}
	label var hlo_mf_note "Generic source note for HLO data.  Also contains qualifier for non-representative China and India scores"

// Save dataset
sa "$clone\04_HLO-HCI\043_output\hlo_20Aug2020.dta", replace	
sa "$clone\04_HLO-HCI\043_output\hlo.dta", replace	

// Compare with previous version of dataset
// cf _all using "$prev", verbose 
// Changes are all PILNA, manual overrides for CHN, MRT, GAB, COM, CUB

/******************************************************************************/
// Graphing tool to look at resulting HLO time series
/******************************************************************************/

/*
local ctry "WSM"
twoway (scatter hlo_mf year if wbcode=="`ctry'", /*connect(J) lwidth(thick)*/ mlabel(hlo_mf_source) mlabangle(90) mlabposition(12) mlabgap(5) ) ///
		(scatter hlo_mf year if wbcode=="`ctry'" & hlo_new==1, /*connect(J) lwidth(thick)*/ mlabel(hlo_mf_source) mlabangle(90) mlabposition(12) mlabgap(5) ) ///
		(scatter hlo_mf_unused year if wbcode=="`ctry'", mlabel(hlo_mf_unused_source) mlabangle(90) mlabposition(12) mlabgap(5))  ///
		(line hlo_mf_fill year if wbcode=="`ctry'")if year>=2005 & year<=2020, ///
		yscale(range(200 700)) ylabel(200 300 400 500 600 700) title("Harmonized Learning Outcomes: `ctry'") ///
		legend(label(1 "Combined HLO") label(2 "New Test") label(3 "Unused Tests") label(4 "Combined HLO")) xline(2010) xline(2017) xline(2019)
STOP
*/



