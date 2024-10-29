*****************************************************
*Author: Syedah Aroob Iqbal
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

*Compile and scale all EGRAs for HLO 2022

use "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production2\MHC-HLO-Production\11_GLAD/113_outputs/RWA/RWA_2018_EGRA/RWA_2018_EGRA_v01_M_wrk_A_GLAD_ALL.dta", clear 
save "$temp\WLD_ALL_EGRA_v01_M_v03_A_GLAD.dta", replace


******************************************************
*2) Scale EGRA Scores 
******************************************************
*Scaling was done pre 2018 so scaling such that the mean of 500 coincides with the mean of the pre-2018 compiled dataset for EGRA:
*Compile and scale all EGRAs for HLO 2022

local mean_EGRA_v01 = 29.36718
local std_EGRA_v01 = 34.96901 
drop if idgrade < 2 
drop if idgrade > 4 & !missing(idgrade)
drop if missing(score_egra_read)
*The harmonized learning outcomes database only uses grades 2-4:
gen read_comp_scaled = [(score_egra_read - `mean_EGRA_v01')/`std_EGRA_v01'] * 100 + 500
save "$output\WLD_All_EGRA_v01_M_v03_A_GLAD.dta", replace


*********************************************************
*3) Calculates reading scores for EGRA countries
*********************************************************
*/

*set trace on

	clear

	save "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.txt" , emptyok replace
			
	file open myfile using "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.txt", write replace

	file write myfile "countrycode" _tab "year"  _tab "nationally_representative" _tab "indicator" _tab "value" _tab "se" _tab "n" _n /*header */
			
	file close myfile

*Change the line below to first bring the file master_countrycode_list.dta from rawdata (Please include the details available in the file to be able to run the loop over the countrycodes.	

*set trace on
use "$output\WLD_ALL_EGRA_v01_M_v03_A_GLAD.dta", clear

*Setting locals:
levelsof countrycode, local(country)

local subject read 
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
										if inlist("`c'","RWA")  {
											svyset [pweight= learner_weight]
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
														
											file open myfile   using	 "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.txt", write append			

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
		
insheet using "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.txt", clear names
gen test = "EGRA"
cf _all using "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.dta", verbose
save "$output\WLD_All_EGRA_v01_M_v03_A_MEAN.dta", replace

