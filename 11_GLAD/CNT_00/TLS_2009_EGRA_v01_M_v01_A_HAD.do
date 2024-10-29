* Timor Leste
set seed 10051990
set sortseed 10051990

import excel using "${path}/CNT/TLS/TLS_2009_EGRA/TLS_2009_EGRA_v01_M/Data/Original/2009_2011.xlsx", firstrow sheet("2009") clear
gen year = 2009
*Variables requested by Nadir:
ren (preschool familylanguage) (tppri lan_at_home)
label define language 1 "Protugese" 2"Tetun" 3 "Other"
drop if missing(language)
label values lan_at_home language
*Survey structure and weights:
ren (school_no Gender_female weighttotal) (school_code female wt_final)
egen strata = group(grade female)
svyset school_code [pweight = wt_final] || _n, strata(strata) singleunit(scaled)
ds, not(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = 0 if `var' == 999
}
*Variables for analysis: 
ren PRspeed orf
replace orf = 0 if orf == 99
replace orf = 0 if missing(orf)
*Cleaning out improbable values:
replace orf = 0 if orf>200
gen oral_read_score_zero = (orf == 0)
foreach var of varlist PC1 PC2 PC3 PC4 PC5 PC6 {
	replace `var' = 0 if `var' == 990
	replace `var' = 0 if missing(`var')
}
egen read_comp_score = rowtotal(PC?) 
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/6)*100
gen list_comp_score_zero = (ListeningComprehension == 0)
gen list_comp_score_pcnt = (ListeningComprehension/5)*100
gen dict_score_zero = (Dictationscore == 0)
gen dict_score_pcnt = (Dictationscore/16)
keep year language grade tppri lan_at_home school_code female strata wt_final orf *_zero *_pcnt 
*oral_read_score_pcnt is missing:
gen n_res = 1
gen r_res = 0
gen w = 1
gen id = _n
gen s_res = 1
gen lang_instr = "Portugese/Tetun"

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
/*Eletricity Refrigerator TV Radio DVDplayer Stovegasorelectric Waterneedtobringwaterfrom Bicicle Car Motocycle Bathroominsidethehouse Mobilephone Waterfaucet
foreach var of varlist Eletricity Refrigerator TV Radio DVDplayer Stovegasorelectric Waterneedtobringwaterfrom Bicicle Car Motocycle Bathroominsidethehouse Mobilephone Waterfaucet {
	tab `var'
}
*/

gen country = "Timor-Leste"
gen cntabb = "TLS"
gen idcntry = 626

*Standardizing survey variables:
gen su1 = school_code
gen strata1 = strata

codebook, compact
cf _all using "${path}/CNT/TLS/TLS_2009_EGRA/TLS_2009_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/TLS/TLS_2009_EGRA/TLS_2009_EGRA_v01_M_v01_A_HAD.dta", replace

