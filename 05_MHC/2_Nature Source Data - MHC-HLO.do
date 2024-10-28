/* =====================================================================================================

Title: Measuring Human Capital
Key Inputs:

		  Learning 
	----------------------

	[ ] HLO_nature.dta 			    --  New Method HLO data
	
=====================================================================================================**/

clear matrix
set mem 1000m
set matsize 10000
set more off

global path "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production\05_MHC"
use "$path/temp/HLO_nature.dta", replace

* gen dissaggregated data series using hierarchy of test

use "$path/temp/HLO_nature.dta", replace

	drop if country == "Yemen" & test != "EGRA" // take EGRA Yemen score
	drop if country == "England" | country == "Scotland" | country == "Northern Ireland" 
	replace test = "PASEC" if test == "PASEC_2014"
	replace grade = "4" if grade == "2-4"
	destring, replace
    drop if test == "NAEQ" // drop if test == "NAEQ" 
    drop if test == "MLA" // not included in HCI and not robust link, Eritrea only country from MLA
    		
    replace HLO_n = HLO if test == "National Assessment"
    replace test = "PISA" if test == "National Assessment" & level == "pri" // Sri Lanka PISA linked test
    replace level = "sec" if cntabb == "LKA" // Sri Lanka PISA linked test

    collapse HLO_n HLO_n_m HLO_n_f score, by(country cntabb year level test subject n_res)
	
	** exclusions
	drop if test == "PASEC" & subject == "math" // less robust link

	**
	reshape wide HLO_n HLO_n_m HLO_n_f score, i(country cntabb year level subject n_res) j(test) string

	** hierarchy of tests
	gen sourcetest = "TIMSS" if HLO_nTIMSS !=. 
	foreach var in HLO_n HLO_n_m HLO_n_f {
	gen n_`var' = `var'TIMSS 
	foreach test in PISA PIRLS LLECE SACMEQ PASEC EGRA {
	replace n_`var' = `var'`test' if n_`var'==. & `var'`test'~=.
	replace sourcetest = "`test'" if sourcetest == "" & `var'`test'~=.
	}
	}

	rename cntabb code
	rename n_HLO_n hlo
	rename n_HLO_n_f hlo_f
	rename n_HLO_n_m hlo_m

    foreach var in reading math science { 
    gen hlo_`var' = hlo if subject == "`var'"
    }

    foreach var in primary secondary { 
    gen hlo_`var' = hlo if level == "`var'"
    }

* generate adjusted SES china score
		local new = _N + 1
        set obs `new'
		replace code = "CHN" if code == ""
		replace year = 2015 if code == "CHN" & subject == ""
		replace level = "sec" if code == "CHN" & subject == ""
		replace hlo = 456 if code == "CHN" & subject == ""
		replace hlo_f = 456 if code == "CHN" & subject == ""
		replace hlo_m = 456 if code == "CHN" & subject == ""
		replace n_res = 1 if code == "CHN" & subject == ""
		replace sourcetest = "PISA and PIRLS, Extrapolated" if code == "CHN" & subject == ""
		replace country = "China" if code == "CHN" & subject == ""
		replace subject = "average" if code == "CHN" & subject == ""

    merge m:m code using "$path/051_input/inc_region.dta" // serbia & montenegro split mid 2000's so listed as seperate country before vs after
		replace region = "Europe & Central Asia" if code == "SCG"
		replace incomegroup = "Upper middle income" if code == "SCG"
    drop _merge
    drop if hlo == .
	
	duplicates drop 
    keep country code year subject level hlo hlo_m hlo_f n_res sourcetest region incomegroup
    sort code level subject year
	lab var code "Country code"
	lab var year "Year"
	lab var n_res "Nationally representative"
	lab var country "Country name"
	lab var subject "Subject (math, reading, science)"
	lab var level "Schooling level (primary or secondary)"
	lab var sourcetest "Achievement Test of Source Data"
	lab var hlo "Harmonized Learning Outcome (HLO)"
	lab var hlo_f "Harmonized Learning Outcome (HLO) - female"
	lab var hlo_m "Harmonized Learning Outcome (HLO) - male"
	
	** metadata
	save "$path/temp/metadata.dta", replace
	
	** merge in standard errors
	use "$path/temp/metadata.dta", replace
	merge 1:1 code year n_res subject level sourcetest using "$path/051_input/se.dta"
	drop if _merge ==2
	drop _merge
	lab var hlo_se "HLO Standard Error"
	lab var hlo_f_se "HLO Standard Error - female"
	lab var hlo_m_se "HLO Standard Error - male"
	order code country year subject level sourcetest n_res hlo hlo_se hlo_m hlo_m_se hlo_f hlo_f_se
    save "$path/temp/HLO_database.dta", replace
    export delimited "$path/temp/hlo_database.csv", replace
		
	** analysis file
	use "$path/temp/HLO_database.dta", replace

	sort code subject level year
	// if nationally rep whole series keep or only data point, if new in series with disagg drop
	drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] 
	// if nationally rep whole series keep or only data point, if new in series with disagg drop
	drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] 
	// if nationally rep whole series keep or only data point, if new in series with disagg drop
	drop if n_res == 0 & code[_n] == code[_n-1] & subject[_n] == subject[_n-1] & level[_n] == level[_n-1] & sourcetest[_n] != sourcetest[_n-1] 
	
	drop if code == "CHN" & n_res != 1 // drop non-national SES-adjusted China data point
	
    save "$path/temp/hlo_disag.dta", replace
	

