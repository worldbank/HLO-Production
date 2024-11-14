*Author: Syedah Aroob Iqbal

/*This do file:
1)	Develops an exchange rate between PILNA and EGRA
2)  Develops standard error for exchange rate between PILNA and EGRA
*/

*Step 1:
*---------------------------------------------------------------------------
*Developing exchange rate:
*---------------------------------------------------------------------------
use "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_final.dta", clear


*keep only nationally representative:
keep if n_res == 1

*Keep only countries that have participated in both PILNA and EGRA:
gen PILNA = ( test == "PILNA" )
gen  EGRA = (test == "EGRA")
bysort cntabb: egen PILNA_exists = max(PILNA)
bysort cntabb: egen EGRA_exists = max(EGRA)
keep if PILNA_exists == 1 & EGRA_exists == 1
drop PILNA* EGRA*

*Keeping assessments that can be used for exchange rate (+-1 year around PILNA assessment years)
*Creating 3-year windows centered on PILNA years:
gen window = 1 if inlist(year,2014,2015,2016)
replace window = 2 if inlist(year,2017,2018,2019)

keep if !missing(window)


*Keeping only relevant variables:
keep cntabb window test grade subject score se n

*Changing EGRA's grade to 4 to allow exchange rate
replace grade = "4" if test == "EGRA"
*Linking with only grade 4 PILNA
keep if grade == "4"
drop grade

reshape wide score* se* n*, i(cntabb window subject) j(test) string
keep if !missing(scoreEGRA) & !missing(scorePILNA)
collapse score* se* n*, by(window subject) 

*Doubloon index for each cycle of PILNA:
gen d_index_pilna_egra = scoreEGRA/scorePILNA

collapse d_index_pilna_egra, by(subject)
gen test = "EGRA"
merge 1:m test subject using "${clone}/03_harmonization/031_rawdata/All_d_index.dta", keep(match) assert(using match) nogen keepusing(d_index d_index_se)
replace d_index = d_index*d_index_pilna_egra
keep subject test d_index
replace test = "PILNA"
save "${clone}/03_harmonization/temp/pilna_d_index.dta", replace

*Step 2:
*---------------------------------------------------------------------------
*Developing standard error for exchange rate for PILNA:
*---------------------------------------------------------------------------
use "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_final.dta", clear

*keep only nationally representative:
keep if n_res == 1 

set seed 10051990
set sortseed 10051990

*Assessment to be linked:
local assessment = "PILNA"
local reference_assessment = "EGRA"

*Limiting data to time-windows for linking: (+/- 1 year)
*Keeping assessments that can be used for exchange rate (+-1 year around PILNA assessment years)
*Creating 3-year windows centered on PILNA years:
levelsof year if test == "`assessment'", local(central_year)
gen window = .
foreach y of local central_year {
	replace window = `y' if inlist(year,`y'-1,`y',`y'+1)
}

keep if !missing(window)

*Keep only countries that have participated in both assessment and reference assessment in the two windows:
gen `assessment' = ( test == "`assessment'" )
gen `reference_assessment' = (test == "`reference_assessment'")
bysort cntabb window: egen `assessment'_exists = max(`assessment')
bysort cntabb window: egen `reference_assessment'_exists = max(`reference_assessment')
keep if `assessment'_exists == 1 & `reference_assessment'_exists == 1
drop `assessment'* `reference_assessment'*


*Generating grade window:
replace grade = "4" if test == "EGRA"

keep if grade == "4"
drop grade


*Keeping only relevant variables:
keep cntabb window test subject score se n

forvalues i = 1(1)100 {
	gen score_`i' = score + se*rnormal()
}
drop score se n
reshape wide score_* , i(cntabb window subject) j(test) string
collapse score_* , by(window subject) 

*Doubloon index for each cycle of PILNA:
forvalues i = 1(1)100 {
	gen d_index_`assessment'_`reference_assessment'`i' = score_`i'`reference_assessment'/score_`i'`assessment'
}
*Collapsing over both rounds
collapse d_index_`assessment'_`reference_assessment'*, by(subject)
if !inlist("`reference_assessment'","TIMSS","PIRLS") {
	gen test = "`reference_assessment'"
	merge 1:m test subject using "${clone}/03_harmonization/031_rawdata/All_d_index.dta", keep(match) assert(using match) nogen keepusing(d_index d_index_se)
	*Drawing 1000 values 
	forvalues i = 1(1)100 {
		gen d_index_`i' = d_index + d_index_se*rnormal()
		forvalues j = 1(1)100 {
			gen d_index_HLO_`i'_`j' = d_index_`i' * d_index_`assessment'_`reference_assessment'`j'
		}	
	}
}
egen d_index_`assessment'_HLO_se = rowsd(d_index_HLO*)
replace test = "`assessment'"
keep subject test d_index_`assessment'_HLO_se
ren d_index_`assessment'_HLO_se d_index_se
merge 1:1 test using "${clone}/03_harmonization/temp/pilna_d_index.dta", assert(match) nogen
*cf _all using "${path}\2-output\pilna_d_index_se.dta", verbose
save "${clone}/03_harmonization/033_output/pilna_d_index_se.dta", replace
