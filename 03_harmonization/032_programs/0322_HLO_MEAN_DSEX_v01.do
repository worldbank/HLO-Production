*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 0322_HLO_MEAN_DSEX_v01
* Authors: Most of the code is from Aroob's HLO_v01 folder on the WBG Network, with some minor syntax changes by Justin (EduAnalytics team)
* Date created: 2024-November-13

/* Description: This do file harmonizes all country level means to HLO units  */

*==============================================================================*

use "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_final.dta", clear
*As Uzbekistan's assessment provides TIMSS-equivalent scores:
replace test = "TIMSS" if test == "NAS" & cntabb == "UZB"
*Merging with exchange rates to develop harmonized scores:
merge m:1 test grade subject using "${clone}/03_harmonization/031_rawdata/All_d_index.dta", assert(master match using) nogen keep(master match)
merge m:1 test using "${clone}/03_harmonization/033_output/pilna_d_index_se.dta", update assert(master match_update) nogen keep(master match_update)

*Generating HLOs:
gen HLO = score * d_index 
gen HLO_m = score_m * d_index
gen HLO_f = score_f * d_index 

*cf _all using "${path}\2-output\HLO_MEANS_DSEX_v01.dta", verbose
save "${clone}/03_harmonization/033_output/HLO_MEANS_DSEX_v01.dta", replace
