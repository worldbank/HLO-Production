*==============================================================================*
* Harmonized Learning Outcome (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 0121 DATA QUERY
* Authors: Felipe Puga Novillo (fpuganovillo@worldbank.org), EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 2024-November-11

/* Description: this do-file downloads the Country Level Outcomes (CLOs) from datalibweb. 
This is the first step in re-creating the WLD_ALL...dta file that is neccesary to replicate the 2020 HLO */
*==============================================================================*

* =========================================== *
* Create a cover database
* =========================================== *

* Confirm if you have the coverdatabase 
cap confirm file "${clone}/01_data/011_rawdata/Repository/clo_repository_all.dta"

* Download the repository of CLO available in DLW if you haven't already
if _rc != 0 {
	datalibweb, type(glad) module(CLO) repo(create test_${date}, replace)
	save "${clone}/01_data/011_rawdata/Repository/clo_repository_all.dta", replace
}

* Otherwise, just use the repository 
else {
	use "${clone}/01_data/011_rawdata/Repository/clo_repository_all.dta", clear
}

* Keep metadata at the region-year-assessment level 
keep if region == "OTHERS"

* Add PISA manually
local n = _N + 1
insobs 9
replace country 	= "WLD" 	if country 	== ""
replace survname 	= "PISA" 	if survname == ""
replace vermast		= "V01"		if vermast 	== ""
replace veralt	 	= "V01"		if veralt 	== ""

foreach year of numlist 2000 2003 2006 2009 2012 2015 2017 2018 2022 {
	replace years = "`year'" in `n'
	local n = `n' + 1
}

replace survname 	= "PISA-D" 	if survname == "PISA" & years == "2017"

* Register whether assessments have been downloaded 
cap gen downloaded = .

* =========================================== *
* Download assessments
* =========================================== *

* Loop over region-year-assessment
quietly {
	forvalues i = 1/`=_N' {
		
		* Preserve the cover database
		preserve 
		
		* Save parameters in locals 
		local country 		= country[`i']
		local year	 		= years[`i']
		local assessment	= survname[`i']
		local vermast		= vermast[`i']
		local veralt 		= veralt[`i']
		
		* Check if the assessment is already in the folder
		cap confirm file "${clone}/01_data/011_rawdata/CLO/`country'_`assessment'_`year'_`vermast'_`veralt'_clo.dta"
		
		* If not, dowwnload it via DLW
		if _rc != 0 {
			
			* Download via datalibweb
			cap dlw, country(`country') year(`year') type(GLAD) module(CLO) vermast(`vermast') veralt(`veralt') survey(`assessment') clear
			
			* If it cannot being downloaded
			if _rc != 0 {
				
				* Save local 
				local downloaded = 0
				
				* Continue with the next data point 
				restore
				continue
			}
			
			* If it was successfully downloaded 
			else if _rc == 0 {
				
				* Save local 
				local downloaded = 1
				
				* Save the database 
				save "${clone}/01_data/011_rawdata/CLO/`country'_`assessment'_`year'_`vermast'_`veralt'_clo.dta", replace
			}
			
		}
		
		* If it is already downloaded, continue 
		else {
			
			* Save local and continue with next datapoint
			local downloaded = 1
		
		}
		
		* Restore to the cover database
		restore
		
		* Register which data points were downloaded and which didn't
		replace downloaded = `downloaded' in `i'
	
	} // end of loop
	
} // end of quietly 

* Save the cover database
save "${clone}/01_data/011_rawdata/Repository/clo_repository_agg.dta", replace