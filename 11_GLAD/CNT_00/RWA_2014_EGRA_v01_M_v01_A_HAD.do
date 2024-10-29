set seed 10051990
set sortseed 10051990


use "${path}/CNT/RWA/RWA_2014_EGRA/RWA_2014_EGRA_v01_M/Data/Stata/2014.dta", clear
append using "${path}/CNT/RWA/RWA_2015_EGRA/RWA_2015_EGRA_v01_M/Data/Stata/2015.dta"
append using "${path}/CNT/RWA/RWA_2016_EGRA/RWA_2016_EGRA_v01_M/Data/Stata/2016.dta"
replace country = "Rwanda"
replace year = 2016 if missing(year)
*Survey set:
ren (final_weight encrypted_school_code student_id) (wt_final school_code id)
drop strata3
egen strata3 = group(grade female)
*Province not available
svyset district [pweight = wt_final], strata(state)  || school_code , strata(district) || id, strata(strata3) singleunit(scaled)
*Generating variables missing for analysis:
gen oral_read_score_zero = (oral_read_score == 0)
gen read_comp_score_zero = (read_comp_score == 0)
*Relabelling variables:
gen urban_n = 0 if urban == "rural"
replace urban_n = 2 if urban == "peri-urban"
replace urban_n = 1 if urban == "urban"
labmask urban_n, values(urban)
drop urban
ren urban_n urban
replace female = "1" if female == "Female"
replace female = "0" if female == "Male"
destring female, replace
keep country year month date state region district school_code urban strata3 id grade female age language orf oral_read_score_pcnt read_comp_score_pcnt wt_final oral_read_score_zero read_comp_score_zero
gen n_res = 1
gen r_res = 0
gen w = 1
encode school_code, gen(school_code_n)
drop school_code
ren school_code_n school_code
bysort id: gen id_n = _n
drop id
ren id_n id
gen s_res = 1
gen lang_instr = "English"
*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*Variables not available.

gen cntabb = "RWA"
gen idcntry = 646

*Standardizing survey variables:
encode state, gen(state_n)
encode district, gen(district_n)
gen su1 = district_n
gen strata1 = state_n
gen su2 = school_code
gen strata2 = district_n
gen su3 = id 
drop region
codebook, compact
drop state district
svyset su1 [pweight = wt_final], strata(strata1)  || su2 , strata(strata2) || id, strata(strata3) singleunit(scaled)
cf _all using "${path}\CNT\RWA\RWA_2014_EGRA\RWA_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\RWA\RWA_2014_EGRA\RWA_2014_EGRA_v01_M_v01_A_HAD.dta", replace


