*Author: Syedah Aroob Iqbal

/*This do file:
1)	Develops exchange rate for Harmonized Learning Outcomes.
*/

global master_seed  10051990
set seed 10051990 
set sortseed 10051990   // Ensures reproducibility

use "$clone/01_input/WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta", clear

*-----------------------------------------
*  clean data
*-----------------------------------------

    keep if n_res == 1 | missing(n_res)
    replace n_res = 1
    replace year = 2012 if cntabb == "TGO" & test == "PASEC" & year == 2006	 // keep Togo for PASEC
    replace year = 2014 if cntabb == "MDG" & test == "PASEC_2014" & year == 2015
    drop if test == "SACMEQ" & cntabb == "ZAF" // not nationally representative
    drop if test == "PISA" & year == 2018 // newer data so exclude for now
    drop if inlist(test,"MLA","NAEQ","NAS","National Assessment")

    gen level = "pri" if inlist(grade,"2","2-4","3","4","5","6")
    replace level = "sec" if missing(level)
        *drop if grade == "2" | grade == "3"
      //  drop if test == "PASEC" & year < 2006
        replace year = 2006 if test == "PASEC" & year > 2000 & year < 2006

    keep cntabb test year subject level score se n

save "$clone/02_exchangerate/temp/master_exchangerate.dta", replace


	
use "$clone/02_exchangerate/temp/master_exchangerate.dta", clear

set trace on
foreach assessment in PISA LLECE SACMEQ PASEC PASEC_2014 EGRA PILNA {
	levelsof subject if test == "`assessment'", local(sub)
	foreach s of local sub {
		levelsof level if test == "`assessment'" & subject == "`s'", local(lev) 
		foreach l of local lev {
			*local s = "math"
			*local lev = "sec"
			preserve
			gen anchor_assessment = (test == "`assessment'")
			keep if subject == "`s'" & level == "`l'"	
			
			*--------------------------------------------------------
			*Assigning reference assessment for each test
			*--------------------------------------------------------
			if "`l'" == "pri" & "`s'" == "reading" {
				local reference_assessment = "PIRLS"
			}
			else if "`l'" == "pri" & inlist("`s'","math","science") {
				local reference_assessment = "TIMSS"
			}
			else if "`l'" == "sec" & inlist("`s'","reading") {
				local reference_assessment = "PISA" 
			}
			else if "`l'" == "sec" & inlist("`s'","math","science") {
				local reference_assessment = "TIMSS" 
			}
			if inlist("`assessment'","PASEC") {	
				local reference_assessment = "SACMEQ"
			}
			if "`assessment'" == "PASEC_2014" {
				local reference_assessment = "PASEC" 
			}
			if "`assessment'" == "PILNA" {
				local reference_assessment = "EGRA" 
			}
			
			keep if inlist(test,"`assessment'","`reference_assessment'")

			
			*--------------------------------------------------------
			*Documenting match years 
			*--------------------------------------------------------
			
			*Limiting data to time-windows for linking: 
			*Keeping assessments that can be used for exchange rate 
			*Creating 5-year windows centered on assessment years:		
			
			*Document year_match for each assessment:
			if "`assessment'" == "PISA" {
				gen window = 1 if inlist(year,1999,2000)
				replace window = 2 if inlist(year,2003)
				replace window = 3 if inlist(year,2006,2007)
				replace window = 4 if inlist(year,2009,2011,2012)
				replace window = 5 if inlist(year,2015)
			}
			
			if "`assessment'" == "LLECE" {
				gen window = 1 if inlist(year,2006,2007)
				replace window = 2 if inrange(year,2011,2016)
			}
			
			if "`assessment'" == "SACMEQ" {
				gen window = 1 if inrange(year,2007,2013)
			}
			
			if "`assessment'" == "PASEC" {
				gen window = 1 if inrange(year,2004,2010)
				replace window =2 if inlist(year,2013,2014)
			}
			
			*Only Togo was conducted in 2012 and 2014: Using Togo as the country to calculate exchange rate.
			if "`assessment'" == "PASEC_2014" {
				gen window = 1 if inrange(year,2012,2014) & cntabb == "TGO"
			}
			
			*Morocco data is no nationally representative and therefore not used for linking
			if "`assessment'" == "EGRA" {
				gen window = 1 if inrange(year,2008,2016) & cntabb != "MAR" 
			}
			
			if "`assessment'" == "PILNA" {
				gen window = 1 if inlist(year,2014,2015,2016)
				replace window = 2 if inlist(year,2017,2018,2019)
			}
			
			keep if !missing(window)
			count
			
			*-------------------------------------------------------
			*Calculating Exchange rates
			*---------------------------------------------------------
			
			*Keep only countries that have participated in both assessment and reference assessment in the windows:
			gen reference_assessment = (test == "`reference_assessment'")
			bysort cntabb window: egen assessment_exists = max(anchor_assessment)
			bysort cntabb window: egen reference_assessment_exists = max(reference_assessment)
			keep if assessment_exists == 1 & reference_assessment_exists == 1
			drop assessment* reference_assessment*
			
			save "$clone/02_exchangerate/temp/`assessment'_`s'_`l'_windows.dta", replace

			*Keeping only relevant variables:
			keep cntabb window test subject level score se n
			
			*Collapsing scores by window for each country: 
			collapse score* se* n*, by(cntabb window subject test level)
			
			reshape wide score* se* n*, i(cntabb window subject level) j(test) string
			keep if !missing(score`reference_assessment') & !missing(score`assessment')
			
			collapse score* se* n*, by(window subject level) 
			
			*Doubloon index for each cycle of assessment:
			gen exchange_rate_`assessment'_`reference_assessment' = score`reference_assessment'/score`assessment'

			collapse exchange_rate_`assessment'_`reference_assessment', by(subject level)
			gen assessment = "`assessment'"
			gen reference_assessment = "`reference_assessment'"
			save "$clone/02_exchangerate/temp/exchangerate`assessment'_`reference_assessment'_`s'.dta", replace
			
			*For PASEC 2014: Multiplying with first PASEC to SACMEQ Exchange rate
			if inlist("`assessment'","PASEC_2014") {
				local i_reference_assessment = "SACMEQ"
			
				merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`reference_assessment'_`i_reference_assessment'_`s'.dta", nogen
				gen exchange_rate_`assessment'_`i_reference_assessment' = exchange_rate_`assessment'_`reference_assessment'*exchange_rate_`reference_assessment'_`i_reference_assessment'
			}
			
			*Multipling with the final reference assessment to obtain final exchange rates.
			
			if inlist("`assessment'","PASEC","PASEC_2014","PILNA") {
				if "`l'" == "pri" & "`s'" == "reading" {
					local f_reference_assessment = "PIRLS"
				}
				else if "`l'" == "pri" & inlist("`s'","math","science") {
					local f_reference_assessment = "TIMSS"
				}
				else if "`l'" == "sec" & inlist("`s'","reading") {
					local f_reference_assessment = "PISA" 
				}
				else if "`l'" == "sec" & inlist("`s'","math","science") {
					local f_reference_assessment = "TIMSS" 
				}
				
				gen f_reference_assessment = "`f_reference_assessment'"
				if inlist("`assessment'","PASEC","PILNA") {
				
					merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`reference_assessment'_`f_reference_assessment'_`s'.dta"	, nogen			
					gen exchange_rate_`assessment'_`f_reference_assessment' = exchange_rate_`assessment'_`reference_assessment'*exchange_rate_`reference_assessment'_`f_reference_assessment'
				}
				
				if inlist("`assessment'","PASEC_2014") {
				
					merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`i_reference_assessment'_`f_reference_assessment'_`s'.dta"	, nogen			
					gen exchange_rate_`assessment'_`f_reference_assessment' = exchange_rate_`assessment'_`i_reference_assessment'*exchange_rate_`i_reference_assessment'_`f_reference_assessment'
				}
				keep subject level assessment f_reference_assessment exchange_rate_`assessment'_`f_reference_assessment'
			}
			save "$clone/02_exchangerate/temp/exchangerate`assessment'_`f_reference_assessment'_`s'.dta", replace
			restore
		}
	}
}

*Combining all assessments' exchange rates:
clear
touch "$clone/02_exchangerate/temp/d_index.dta", replace
foreach assessment in PISA LLECE SACMEQ PASEC PASEC_2014 EGRA PILNA {
	foreach s in reading math science {
		cap noisily: append using "$clone/02_exchangerate/temp/exchangerate`assessment'_PIRLS_`s'.dta" 
		cap noisily : append using "$clone/02_exchangerate/temp/exchangerate`assessment'_TIMSS_`s'.dta"
	}
}
replace reference_assessment = f_reference_assessment if missing(reference_assessment)
drop f_reference_assessment
egen exchangerate = rowtotal(exchange_rate*)
keep subject level assessment reference_assessment exchangerate
cf _all using "$clone/02_exchangerate/023_output/exchange_rates.dta", verbose
save "$clone/02_exchangerate/023_output/exchange_rates.dta", replace
