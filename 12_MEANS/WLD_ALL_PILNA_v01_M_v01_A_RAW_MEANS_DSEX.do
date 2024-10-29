*To do: skip if a particular subject scores are missing
*==============================================================================*
*
*Steps:
*0) Creating an appended PILNA file
*1)	Rescaling scores to have a standard deviation of 100
*2) Separating scores and levels by subgroups of traitvars
*4) Creating txt file for each indicator
*5) Calculate statistics by subgroups of traitvars
*===============================================================================*
global path = "N:\GDB\HLO_Database\"

clear
save "$path\temp\EAP_All_PILNA_v01_M_v01_A_RAW_CI.txt" , emptyok replace
		
file open myfile using "$path\temp\EAP_All_PILNA_v01_M_v01_A_RAW_CI.txt", write replace

file write myfile "countrycode" _tab "year" _tab  "idgrade"  _tab "nationally_representative"  _tab "indicator" _tab  "value" _tab "se" _tab "n" _n /*header */
		
file close myfile

*Step 0 :Appending all PILNA data files:

*use "N:\GDB\Personal\WB504672\GLAD-Production\01_harmonization\013_outputs\EAP\EAP_2012_PILNA/EAP_2012_PILNA_v01_M_wrk_A_GLAD_ALL_RAW.dta", clear
use "N:\GDB\Personal\WB504672\GLAD-Production\01_harmonization\013_outputs\EAP\EAP_2015_PILNA/EAP_2015_PILNA_v01_M_wrk_A_GLAD_ALL_RAW.dta", clear
append using "N:\GDB\Personal\WB504672\GLAD-Production\01_harmonization\013_outputs\EAP\EAP_2018_PILNA/EAP_2018_PILNA_v01_M_wrk_A_GLAD_ALL_RAW.dta"

*There are substantial drop-out rates to allow linking with grades 2,3 using EGRA
drop if idgrade == 6
*Keeping only national level observations:
bysort countrycode year: egen national_exists = max(national_level)
drop if national_level == 0 & national_exists == 1

local subject "read lit writ"

*Creating local for plausible values:
 local pvvalues 1 
 
 set trace on
 *Rescaling PILNA data to have a standard deviation of 100 and mean of 500
foreach sub of local subject {
	foreach i of local pvvalues {
		center score_pilna_`sub'_`i', standardize
		gen rs_score_pilna_`sub'_`i' = c_score_pilna_`sub'_`i'*100 + 500
	}
}
		
*local traitvars total male urban native escs* ece language school_type city school_type_o
local traitvars total male

levelsof countrycode, local (cnt)
set trace on
foreach cc of local cnt {
	levelsof year if countrycode == "`cc'", local(yr)
	
	foreach year of local yr {
	
		levelsof idgrade if countrycode == "`cc'" & year == `year', local(grade)
	
		foreach g of local grade {
	
			preserve


			keep if countrycode == "`cc'" & year == `year' & idgrade == `g'

			count
			if r(N) > 0 {


			/*---------------------------------------------------------------------------------
			* 2) Creating binary variables for levels
			*---------------------------------------------------------------------------------
			foreach var of varlist level* {
				replace `var' = "" if `var' == "-99"
				replace `var' = "below1b" if `var' == "<1b"
				replace `var' = "below1" if `var' == "<1"
				replace `var' = "below1c" if `var' == "<1c"
			}

			foreach sub of local subject {
				levelsof level_pilna_`sub'_1, local(lev)
				foreach l of local lev {
					foreach i of local pvvalues {
						gen blev`l'_pilna_`sub'_`i' = (level_pilna_`sub'_`i' == "`l'") & !missing(level_pilna_`sub'_`i')
						label variable blev`l'_pilna_`sub'_`i' "PILNA proficiency level `l' of `sub'_`i'"
							}
				}
			}		

		*/
			*--------------------------------------------------------------------------------
			* 3) Separating indicators by trait groups
			*--------------------------------------------------------------------------------
			
				gen total = 1
				label define total 1 "total"
				label values total total
								
				foreach sub of local subject {
					foreach indicator in rs_score  {
						capture confirm variable `indicator'_pilna_`sub'_1
						if !_rc {

							foreach trait of local traitvars  {
							capture confirm variable `trait' 
								if !_rc { 
									mdesc `trait'
									
									if r(percent) != 100 {
									
										foreach i of local pvvalues {
											separate(`indicator'_pilna_`sub'_`i'), by(`trait') gen(`indicator'`sub'`i'`trait')
											ren `indicator'`sub'`i'`trait'* `indicator'`sub'`trait'*_`i'	
										}
										
						*-----------------------------------------------------------------------------
						*4) *Calculation of indicators by subgroups of traitvars
						*-----------------------------------------------------------------------------
										levelsof `trait', local(lev)
										foreach lv of local lev {
											local label: label (`trait') `lv'

												*Actual population unknown for non-census countries
												*Applying finite population correction
												svyset [pweight=learner_weight], fpc(fpc)
												svy: mean `indicator'`sub'`trait'`lv'_* 
											

											
											* Create variables to store estimates (mean and std error of mean) and num of obs (N)
											matrix pv_mean = e(b)
											matrix pv_var  = e(V)
											local  m_`indicator'`sub'`label'  = pv_mean[1,1]
											local  se_`indicator'`sub'`label' = sqrt(pv_var[1,1])
											local  n_`indicator'`sub'`label'  = e(N)
											
											summarize national_level
											local n_res = r(mean)
											
											save "$path\temp\EAP_`year'_PILNA_v01_M_v01_A_RAW_CI_`cc'_`indicator'`sub'`label'.txt" , emptyok replace
					
											file open ccindfile using "$path\temp\EAP_`year'_PILNA_v01_M_v01_A_RAW_CI_`cc'_`indicator'`sub'`label'.txt", write replace
											
											file write ccindfile "countrycode" _tab "year" _tab  "idgrade"  _tab "national_level" _tab "indicator" _tab  "value" _tab "se" _tab "n" _n /*header */

											file write ccindfile "`cc'" _tab "`year'" _tab "`g'" _tab "`n_res'" _tab "`indicator'`sub'`label'" _tab "`m_`indicator'`sub'`label''" _tab "`se_`indicator'`sub'`label''" _tab  "`n_`indicator'`sub'`label''"  _n
													
											file close ccindfile
																			
											file open myfile   using	 "$path\temp\EAP_All_PILNA_v01_M_v01_A_RAW_CI.txt", write append			

											file write myfile "`cc'" _tab "`year'" _tab "`g'" _tab  "`n_res'" _tab "`indicator'`sub'`label'" _tab "`m_`indicator'`sub'`label''" _tab "`se_`indicator'`sub'`label''" _tab  "`n_`indicator'`sub'`label''"  _n

											file close myfile

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
}
insheet using "$path\temp\EAP_All_PILNA_v01_M_v01_A_RAW_CI.txt", clear names
gen test = "PILNA"
replace indicator = substr(indicator,4,.)
cf _all using "$path\EAP\EAP_All_PILNA_v01_M_v01_A_RAW_MEAN_DSEX.dta", verbose
save "$path\EAP\EAP_All_PILNA_v01_M_v01_A_RAW_MEAN_DSEX.dta", replace
