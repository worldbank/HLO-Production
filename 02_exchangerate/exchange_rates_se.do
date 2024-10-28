*Author: Syedah Aroob Iqbal

/*This do file:
1)	Develops standard errors for exchange rate for Harmonized Learning Outcomes.
*/
clear
clear matrix
clear mata
set maxvar 120000
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
			

			*Keeping only relevant variables:
			keep cntabb window test subject level score se n
			
			collapse score se , by(cntabb window subject test level) 
			
			forvalues i = 1(1)100 {
				gen score_`i' = score + se*rnormal()
			}
			
			drop score se 
			reshape wide score_* , i(cntabb window subject level) j(test) string
			*Placeholder for replication:
			if "`assessment'" == "LLECE" & inlist("`s'","math","science") {
				expand 2 if cntabb == "CHL"
			}


			*keep if !missing(score_*`reference_assessment') & !missing(score_*`assessment')

			forvalues i = 1(1)100 {
				gen er_`assessment'_`reference_assessment'`i' = score_`i'`reference_assessment'/score_`i'`assessment'
			}
			collapse er_`assessment'_`reference_assessment'*, by(subject level)
			save "$clone/02_exchangerate/temp/exchangerate`assessment'_`reference_assessment'_`s'_se_int.dta", replace	

			
			if !inlist("`assessment'","PASEC","PASEC_2014","PILNA") {
			
				egen exchange_rate_`assessment'_se = rowsd(er_*)
				gen assessment = "`assessment'"
				keep assessment subject level exchange_rate_`assessment'_se
				save "$clone/02_exchangerate/temp/exchangerate`assessment'_`reference_assessment'_`s'_se.dta", replace	

			}
			
			if inlist("`assessment'","PASEC_2014") {
				local i_reference_assessment = "SACMEQ"
			
				merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`reference_assessment'_`i_reference_assessment'_`s'_se_int.dta", nogen
				
			
				*Drawing 100 values 
				forvalues i = 1(1)100 {
					forvalues j = 1(1)100 {
						gen er_`assessment'_`i_reference_assessment'_`i'_`j' = er_`assessment'_`reference_assessment'`i' * er_`reference_assessment'_`i_reference_assessment'`j'
					}	
				}
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
				
				if inlist("`assessment'","PASEC","PILNA") {
				
					merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`reference_assessment'_`f_reference_assessment'_`s'_se_int.dta"	, nogen		
					*Drawing 100 values 
					forvalues i = 1(1)100 {
						forvalues j = 1(1)100 {
							gen er_`assessment'_`f_reference_assessment'_`i'_`j' = er_`assessment'_`reference_assessment'`i' * er_`reference_assessment'_`f_reference_assessment'`j'
						}	
					}
				}
				
				if inlist("`assessment'","PASEC_2014") {
				
					merge 1:1 subject level using "$clone/02_exchangerate/temp/exchangerate`i_reference_assessment'_`f_reference_assessment'_`s'_se_int.dta"	, nogen		
					
					*Drawing 100 values 
					egen er_`assessment'_`i_reference_assessment'_se  = rowsd(er_`assessment'_`i_reference_assessment'*)
					egen mean_er_`assessment'_`i_reference_assessment' = rowmean(er_`assessment'_`i_reference_assessment'*)
					*drop er_`assessment'_`i_reference_assessment'_?*
					forvalues i = 1(1)100 {
						gen er_`assessment'_`i_reference_assessment'_`i' = mean_er_`assessment'_`i_reference_assessment' + er_`assessment'_`i_reference_assessment'_se*rnormal()
						forvalues j = 1(1)100 {
							gen er_`assessment'_`f_reference_assessment'_`i'_`j' = er_`assessment'_`i_reference_assessment'_`i' * er_`i_reference_assessment'_`f_reference_assessment'`j'
						}	
					}
				}
				egen exchange_rate_`assessment'_se = rowsd(er_`assessment'_`f_reference_assessment'_*)
				gen assessment = "`assessment'"
				keep assessment subject level exchange_rate_`assessment'_se
				save "$clone/02_exchangerate/temp/exchangerate`assessment'_`f_reference_assessment'_`s'_se.dta", replace	
			}
				
				
			restore
		}
	}
}

*Append all standard errors:
clear
touch "$clone/02_exchangerate/temp/exchangerate_se.dta", replace
foreach assessment in PISA LLECE SACMEQ PASEC PASEC_2014 EGRA PILNA {
	foreach s in reading math science {
		cap noisily: append using "$clone/02_exchangerate/temp/exchangerate`assessment'_PIRLS_`s'_se.dta" 
		cap noisily : append using "$clone/02_exchangerate/temp/exchangerate`assessment'_TIMSS_`s'_se.dta"
	}
}
keep assessment subject level exchange_rate_PISA_se exchange_rate_LLECE_se exchange_rate_SACMEQ_se exchange_rate_PASEC_se exchange_rate_PASEC_2014_se exchange_rate_EGRA_se exchange_rate_PILNA_se
egen exchangerate_se = rowtotal(exchange_rate*)
keep subject level assessment exchangerate_se
*cf _all using "$clone/02_exchangerate/output/exchange_rates_se.dta", verbose
save "$clone/02_exchangerate/output/exchange_rates_se.dta", replace
