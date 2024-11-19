*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 0122_PREPARE
* Authors: Felipe Puga Novillo (fpuganovillo@worldbank.org), EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 2024-November-11

/* Description: this do-file prepares the dataset to be comparable with 
'WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta', located in the network. */
*==============================================================================*

* =========================================== *
* Append the asssessments 
* =========================================== *

* Create an empty temporal database
clear 
tempfile db_clo db_pisa
save `db_clo', emptyok
save `db_pisa', emptyok

* Load the cover database
use "${clone}/01_data/011_rawdata/Repository/clo_repository_agg.dta", clear

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
		
		* Load the assessments
		use "${clone}/01_data/011_rawdata/CLO/`country'_`assessment'_`year'_`vermast'_`veralt'_clo.dta", clear
		
		* For assessments other than PISA 
		if !inlist("`assessment'", "PISA", "PISA-D") | ("`assessment'" == "PISA" & year == 2022) {
			
			* Generate survey ID
			gen surveyid = "`country'_`year'_`assessment'_`vermast'_`veralt'"
			cap gen assessment = "`assessment'"
			
			* Keep subgroups of interest
			keep if inlist(subgroup, "all", "male=0", "male=1")
			
			* Create 'grade' for PISA 2022
			cap gen idgrade = 0
			cap rename (*scie) (*science)
			
			* Keep and order variables of interest 
			keeporder countrycode year idgrade subgroup surveyid code assessment m_score* se_score* n_score*
			
			* Lower case for assessment
			local assessment = lower("`assessment'")
			
			* Rename mean, SE, and sample size 
			rename *`assessment'_* **
			
			* Save the resulting database in the temporal file 
			append using `db_clo'
			save `"`db_clo'"', replace 
		
		}
		
		else if ("`assessment'" == "PISA" & year != 2022) | "`assessment'" == "PISA-D" {
			
			* Keep subgroups of interest 
			keep if escsqn == "pooled" & urban == "pooled"
			
			* Keep and order variables of interest 
			keeporder idcntry_raw year idgrade subject male assessment survey code b_score_mean se_score_mean N_score
			
			* Save the resulting database in the temporal file 
			append using `db_pisa'
			save `"`db_pisa'"', replace 
		}
		
		* Restore to the cover database
		restore
		
	} // end of loop
	
} // end of quietly 

* =========================================== *
* Transform the database to be similar to 
* WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX 
* =========================================== *

* Load the temporal database with CLO
use `db_clo', clear

* Rename variables related to subject 
rename (*_read *_math *_science) (*1 *2 *3)

* Reshape the database to have the datapoints by subject
reshape long m_score se_score n_score, i(countrycode year surveyid idgrade subgroup) j(i)
drop if m_score == .

* Create the variable 'subject' 
gen subject 	= "reading" if i == 1
replace subject = "math" 	if i == 2
replace subject = "science" if i == 3

* Generate a variable to reshape with respect to subgroup 
encode subgroup, gen(j)

* Drop variables we won't use 
drop i subgroup

* Reshape the database to have indicators by gender 
reshape wide m_score se_score n_score, i(countrycode year surveyid idgrade subject) j(j)

* Rename variables related to gender first
rename (*1 *2 *3) (*_clo *_f_clo *_m_clo)

* Rename variables to be similar with the DSEX database
rename (m_score* se_score* n_score* countrycode assessment idgrade) ///
	(score* se* n* cntabb test grade)
	
* Order the database 
order cntabb test year subject grade score_clo se_clo n_clo score_m_clo se_m_clo n_m_clo score_f_clo se_f_clo n_f_clo 

* Save in a temporal database
save `db_clo', replace 

* =========================================== *
* Add the PISA CLOs
* =========================================== *

* Load the temporal database with CLO
use `db_pisa', clear

* Rename variables 
rename (idcntry_raw idgrade b_score_mean se_score_mean N_score assessment survey) ///
	(cntabb grade score se n test surveyid)

* Generate columns ID
gen 	j = 1 if male == "pooled"
replace j = 2 if male == "female"
replace j = 3 if male == "male"

* Drop variables we will not use
drop male

* Reshape the database so we have indicators by subject
reshape wide score se n, i(cntabb year subject) j(j)

* Rename variables related to gender 
rename (*1 *2 *3) (*_clo *_f_clo *_m_clo)

* Include grade for PISA
replace grade = 8

* Drop data points with missin values 
drop if score_clo == .

* Save the resulting database in a temporal file
save `db_pisa', replace

* Append datasets
use `db_clo', clear
append using `db_pisa'

* Changes to match with DSEX
replace test = "PASEC_2014" if test == "PASEC" & year == 2014
replace test = "PISA" if test == "PISA-D"
replace subject = "reading" if subject == "read"
replace grade = 8 if (cntabb == "ARM" & grade == 9 & year == 2011 & test == "TIMSS") | test == "PISA"
replace cntabb = "ENG" if cntabb == "GBR" & inlist(test, "PIRLS", "TIMSS")
replace cntabb = "SCD" if cntabb == "SRB" & year == 2003 & test == "TIMSS"
replace cntabb = "ROU" if test == "PISA" & cntabb == "ROM"
replace cntabb = "SCG" if test == "PISA" & cntabb == "YUG"
replace cntabb = "TWN" if test == "PISA" & cntabb == "TAP"
replace cntabb = "CHN" if test == "PISA" & inlist(cntabb, "QCN", "QCH", "QCI", "QCN")
replace cntabb = "VEN" if test == "PISA" & cntabb == "QVE"
replace cntabb = "XKX" if test == "PISA" & cntabb == "KSV"

* Convert 'grade' to string
tostring grade, replace	

* Compress the dataset 
compress 

* Save the resulting database
save "${clone}/01_data/013_output/WLD_ALL_ALL_clo.dta", replace 