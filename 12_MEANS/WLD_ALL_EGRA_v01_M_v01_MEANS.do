*****************************************************
*Author: Syedah Aroob Iqbal & Katharina Ziegler
******************************************************

/*
This do file:
1) Append all EGRA GLADs
2) Scale all EGRA datasets to have a mean of 500 and a standard deviation of 100
3) Develop mean scores for all EGRAs.
*/

******************************************************
*1) Append all EGRA GLADs
******************************************************


*Reported results: 
import delimited "$means\121_inputs\reported_results_egras.csv", clear 
tostring year, replace
save "$means\121_inputs\reported_results_egras.dta", replace


import delimited using "$means\121_inputs\egras_2018_HCI.csv", clear
ren n_res nationally_representative
tostring year, replace
save "$means\121_inputs\egras_2018_HCI.dta", replace



log using "$means/120_documentation\EGRAs.smcl", replace

use "${means}\121_inputs\ccc.dta", clear

levelsof countrycode, local(ccc)


touch "$temp\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", replace

use "$temp\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear

foreach c of local ccc {
	
	forvalues year = 2000/2021 {
		
		capture noisily : append using "${input}/`c'/`c'_`year'_EGRA/`c'_`year'_EGRA_v01_M_wrk_A_GLAD_ALL.dta"

	}
}

save "$temp\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", replace
log close


*Bringing in EGRA using reports:
use "$temp\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear
*append using "$means\121_inputs\reported_results_egras.dta"




/*Checking number of observations with previous versions of EGRA databases.
use "$output\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear
gen N = 1
collapse (sum) N , by(countrycode)
ren countrycode cntabb
merge 1:1 cntabb using "${path}\temp\counts_HLO_EGRA_v00.dta"

*Checking counts with EGRA_v01.
use "$output\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear
gen N = 1
collapse (sum) N , by(countrycode)
merge 1:1 countrycode using "${path}\TEMP\counts_HLO_EGRA_v01.dta"


*Checking counts with EGRA_v02.
use "${path}\WLD\WLD_All_EGRA\WLD_All_EGRA_v02_M_v02_A_HAD.dta", clear
gen N = 1
collapse (sum) N , by(countrycode)
save "${path}\TEMP\counts_HLO_EGRA_v02.dta", replace
use "$output\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear
gen N = 1
collapse (sum) N , by(countrycode)
merge 1:1 countrycode using "${path}\TEMP\counts_HLO_EGRA_v02.dta"
*/

******************************************************
*2) Scale EGRA Scores 
******************************************************
*Scaling was done pre 2018 so restricting the dataset to the datasets included in the Human Capital Index 2018:
*Bringing in EGRAs list HCI 2018.
merge m:1 countrycode year nationally_representative using "$means\121_inputs\egras_2018_HCI.dta",
summarize score_egra_read if _merge == 3
center score_egra_read, standardize 
gen read_comp_scaled = c_score_egra_read*100+500

gen score_egra_read_100 = score_egra_read
drop score_egra_read
gen score_egra_read = read_comp_scaled

** Core Database
*English language instrument was conducted to only 6th graders.
drop if countrycode == "RWA" & year == "2011"
*drop if country == "Egypt" & year == 2011

* keep grade 2/3 to maximimze coverage-comparability tradeoff
keep if idgrade == 2 | idgrade == 3 | idgrade == 4

*keep nationally representative if nationally representative exists and non-nationally representative only if nationally representative does not exist.
bysort countrycode: egen nationally_representative_exists = max(nationally_representative == 1)
drop if nationally_representative != 1 & nationally_representative_exists == 1


*keep datasets in language of instruction where exists and keep datasets in languages other than languages of instruction if dataset in language of instruction does not exist.
gen d_language = (lang_instr == language)
replace d_language = 1 if countrycode == "TLS" // two languages of instruction;
replace d_language = 1 if countrycode == "PHL" // two languages of instruction;
bysort countrycode: egen d_lang_exists = max(d_language)
drop if d_language != 1 & d_lang_exists == 1

keep total countrycode year nationally_representative idschool idregion idlearner strata1 strata2 strata3 strata4 su1 su2 su3  su4 fpc1 fpc2 fpc3 fpc4 male age urban learner_weight regionally_representative idgrade language learner_weight escs score_egra_read_100 score_egra_read se d_language
save "$output\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", replace

/*
merge m:1 countrycode using "${path}\STANDARD\ccc_list.dta", assert(match using) keep(match) nogen
keep wbcountryname countrycode idcntry wbregion wbincomegroup wbmember  year n_res region idschool idstud strata strata1 strata2 strata3 strata4 su1 su2 su3  fpc1 fpc2 fpc3 fpc4 read_comp_scaled read_comp_score_pcnt tgirl tppri idgrade language weight ESCS w SCHESCS CNTESCS se d_language
order wbcountryname countrycode idcntry wbregion wbincomegroup wbmember  year n_res  region idschool idstud strata strata1 strata2 strata3 strata4 su1 su2 su3  fpc1 fpc2 fpc3 fpc4 read_comp_scaled read_comp_score_pcnt  tgirl tppri idgrade language weight ESCS w SCHESCS CNTESCS se d_language
*/

*********************************************************
*3) Calculates reading scores for EGRA countries
*********************************************************
*/

*set trace on

	clear

	save "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.txt" , emptyok replace
			
	file open myfile using "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.txt", write replace

	file write myfile "countrycode" _tab "year"  _tab "nationally_representative" _tab "indicator" _tab "value" _tab "se" _tab "n" _n /*header */
			
	file close myfile

*Change the line below to first bring the file master_countrycode_list.dta from rawdata (Please include the details available in the file to be able to run the loop over the countrycodes.	

*set trace on
use "$output\WLD_ALL_EGRA_v01_M_v01_A_GLAD.dta", clear

*use "${means}/121_inputs/master_countrycode_list.dta",  clear
*keep if assessment== "EGRA" & region=="WLD"

*Setting locals:
levelsof countrycode, local(country)

local subject read read_100
local traitvars total male

foreach c of local country {
	display "`c'"
	
	levelsof year if countrycode == "`c'", local(yr)
	
	foreach y of local yr {
		
		levelsof nationally_representative if year == "`y'" & countrycode == "`c'" , local(n_res)
	
		foreach n of local n_res {

			preserve
			
			keep if countrycode == "`c'" & year == "`y'" & nationally_representative == `n' 
			
			tab year
			display "`c'" "`y'" `n'

	
	*use "${clone}/01_harmonization/013_outputs/`c'/`c'_`y'_EGRA/`c'_`y'_EGRA_v01_M_wrk_A_GLAD_ALL", replace
	*--------------------------------------------------------------------------------
	* 3) Separating indicators by trait groups
	*--------------------------------------------------------------------------------
								
			foreach sub of local subject {
				display "`sub'"
				foreach indicator in score {
					capture confirm variable `indicator'_egra_`sub'
					display _rc
				
					if !_rc {
					
						foreach trait of local traitvars  {
						capture confirm variable `trait'
						display _rc
						if _rc == 0 {
							mdesc `trait'
							return list
							if r(percent) != 100 { 
								separate(`indicator'_egra_`sub'), by(`trait') gen(`indicator'`sub'`trait')
	*-----------------------------------------------------------------------------
	*4) *Calculation of indicators by subgroups of traitvars
	*-----------------------------------------------------------------------------
								levelsof `trait', local(lev)
								foreach lv of local lev {
									local label: label (`trait') `lv'
					
										*Setting survey structure
										if inlist("`c'","AFG", "AGO", "ATG", "BGD", "DMA")  {
											svyset [pweight= learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'","GRD","HND", "JAM", "KHM", "KNA", "LAO", "LCA") {
										
											svyset [pweight= learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'","MKD","MWI","SDN", "SEN", "TON", "TUV", "VCT", "VUT", "WSM")  {
										
											svyset [pweight= learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "GHA"){
											svyset su1 [pweight= learner_weight], strata(strata1) || su2, strata(strata2)  singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'",  "SLE"){
											svyset su1 [pweight= learner_weight], strata(strata1) || su2, strata(strata2)  singleunit(scaled) 
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "GUY"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) || su3,  strata(strata3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "IND", "TZA"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) || su4, fpc(fpc4) strata(strata4) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "IRQ" ){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) || su3, fpc(fpc3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'","LBR") {
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "PHL", "SLV" ){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) || su3, fpc(fpc3) strata(strata3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "PHL", "YEM", "ZMB" ){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) || su3, fpc(fpc3) strata(strata3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "JOR" ){
											svyset su1 [pweight = learner_weight],  strata(strata1) || su2, fpc(fpc2) strata(strata2) || su3, fpc(fpc3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "KEN", "NPL", "EGY", "NIC"){
											svyset su1 [pweight = learner_weight], strata(strata1) fpc(fpc1) || su2, strata(strata2) fpc(fpc2)  singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "KGZ", "TJK"){
											svyset su1 [pweight = learner_weight], strata(strata1) vce(linearized)

											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "KIR"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "MAR"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) || su2, strata(strata2) fpc(fpc2) singleunit(scaled)  vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "RWA"){
											svyset [pweight = learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "PAK"){
											svyset [pweight = learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "SLB"){
											svyset su1 [pweight = learner_weight], strata(strata1) || su2 || su3
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "TLS"){
											svyset su1 [pweight = learner_weight] || su2 , strata(strata2) singleunit(scaled)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "UGA"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2)  || su3, fpc(fpc3) strata(strata3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "BDI") & inlist("`y'", "2011"){
											svyset su1 [pweight= learner_weight], fpc(fpc1) strata(strata1) vce(linearized) 

											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "BDI") & inlist("`y'", "2012"){
											svyset [pweight= learner_weight]
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "COD") & inlist("`y'", "2010"){
											svyset [pweight= learner_weight]
											svy: mean `indicator'`sub'`trait'`lv' 

										}
										if inlist("`c'", "COD") & inlist("`y'", "2012"){
											svyset su1 [pweight= learner_weight], strata(strata1) fpc(fpc1) || su2, strata(strata2) fpc(fpc2) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 

										}
										if inlist("`c'", "COD") & inlist("`y'", "2015"){
											svyset su1 [pweight= learner_weight], strata(strata1) fpc(fpc1) || su2, strata(strata2) fpc(fpc2) || su3, strata(strata3) fpc(fpc3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "ETH") & inlist("`y'", "2010"){
											svyset su1 [pweight= learner_weight], strata(strata1) fpc(fpc1) || su2, strata(strata2) fpc(fpc2) || su3, strata(strata3) fpc(fpc3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "ETH") & inlist("`y'", "2018"){
											svyset su1 [pweight= learner_weight], strata(strata1) || su2, strata(strata2)  singleunit(scaled) 
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "GMB") & inlist("`y'","2007","2009","2011") {
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1)  || su2, fpc(fpc2) strata(strata2) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "HTI") & inlist("`y'", "2012"){
											svyset su1 [pw=learner_weight], strata(strata1) fpc(fpc1) ||su2, strata(strata2) fpc(fpc2) vce(linearized) singleunit(scaled)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "HTI") & inlist("`y'", "2013"){
											svyset su1 [pweight= learner_weight], strata(strata1) fpc(fpc1) || su2, strata(strata2) fpc(fpc2) || su3, strata(strata3) fpc(fpc3) singleunit(centered) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "HTI") & inlist("`y'", "2015", "2016"){
											svyset [pweight = learner_weight]
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "MLI") & inlist("`y'", "2009"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) || su2, fpc(fpc2) strata(strata2) || su3, fpc(fpc3) strata(strata3) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										} 
										if inlist("`c'", "MLI") & inlist("`y'", "2015"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv'
										} 
										if inlist("`c'", "MMR") & inlist("`y'", "2014"){
											svyset su1 [pweight = learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "MMR") & inlist("`y'", "2015"){
											svyset su1 [pweight = learner_weight],  strata(strata1) singleunit(scaled) vce(linearized)
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "NGA") & inlist("`y'", "2010"){
											svyset su1 [pw=learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) || su3, fpc(fpc3) strata(strata3) vce(linearized) singleunit(scaled)
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "NGA") & inlist("`y'", "2014"){
											svyset su1 [pw=learner_weight], fpc(fpc1) strata(strata1) || su2, fpc(fpc2) strata(strata2) vce(linearized) singleunit(scaled)
											svy: mean `indicator'`sub'`trait'`lv'
										}
										if inlist("`c'", "PNG") & inlist("`y'", "2011"){
											svyset su1 [pweight = learner_weight], strata(strata1) || su2,  strata(strata2) singleunit(scaled) 
											svy: mean `indicator'`sub'`trait'`lv' 
										}
										if inlist("`c'", "PNG") & inlist("`y'", "2012","2013"){
											svyset [pweight = learner_weight]
											svy: mean `indicator'`sub'`trait'`lv'
										}
										display _rc
										if _rc == 0 {
										
											matrix pv_mean = e(b)
											matrix pv_var  = e(V)
											
											
											matrix list pv_var
											
											local  m_`indicator'`sub'`label'  = pv_mean[1,1]
											local  se_`indicator'`sub'`label' = sqrt(pv_var[1,1])
											local  n_`indicator'`sub'`label'  = e(N)
											display `m_`indicator'`sub'`label''
														
											file open myfile   using	 "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.txt", write append			

											file write myfile "`c'" _tab "`y'" _tab "`n'" _tab "`indicator'`sub'`label'" _tab "`m_`indicator'`sub'`label''" _tab "`se_`indicator'`sub'`label''" _tab  "`n_`indicator'`sub'`label''"  _n

											file close myfile
										}
									
									}
								}
							}
						}
					}
				}
			}
		}
		restore
	}
}
		
insheet using "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.txt", clear names
gen test = "EGRA"
cf _all using "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.dta", verbose
save "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.dta", replace

*Preparing for checking:
use "$means\121_inputs\WLD_All_EGRA_v01_M_v01_A_MEANS.dta", clear
ren n_res nationally_representative
merge 1:m countrycode year nationally_representative using "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.dta"
br countrycode year nationally_representative read_comp_score_pcnt value if indicator == "scoreread_100total" & !missing(read_comp_score_pcnt)
assert round(value) == round(read_comp_score_pcnt) if indicator == "scoreread_100total" & !missing(read_comp_score_pcnt)
br countrycode year indicator nationally_representative read_comp_score_pcnt value if round(value) != round(read_comp_score_pcnt) & indicator == "scoreread_100total" & !missing(read_comp_score_pcnt)


*Checking means:
use "$output\WLD_All_EGRA_v01_M_v01_A_MEAN.dta", clear
destring year, replace
ren value value_new
merge 1:1 countrycode year nationally_representative indicator using "${path}\WLD\WLD_ALL_EGRA\WLD_All_EGRA_v02_M_v02_A_MEAN.dta", 
clear

use "${path}\TEMP\WLD_All_EGRA_v01_M_v01_A_MEAN.dta", clear



