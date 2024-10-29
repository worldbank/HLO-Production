//2011
set seed 10051990
set sortseed 10051990

\\wbgfscifs01\GEDEDU\GDB\HLO_Database\CNT
import excel using "${path}/CNT/TLS/TLS_2011_EGRA/TLS_2011_EGRA_v01_M/Data/Original/2009_2011.xlsx", firstrow sheet("2011") clear
gen year = 2011
*Survey set and weight:
ren (school_id weighttotal2 student_grade gender_female) (school_code wt_final grade female)
*Portugese results are not reliable so dropped (According to "Tetum Pilot Results")
drop if language == "Portuguese"
svyset school_code [pweight = wt_final] || _n, strata(grade) singleunit(scaled)
*Variables for analysis
ren PRspeed orf
replace orf = 0 if orf == 999
gen oral_read_score_zero = (orf == 0)
gen read_comp_score_zero = (PassageComprehension == 0)
gen read_comp_score_pcnt = (PassageComprehension/6)
gen list_comp_score_pcnt = (ListeningComprehension/5)
gen list_comp_score_zero = (ListeningComprehension == 0)
keep year language school_code wt_final grade female orf *_zero *_pcnt 
*Making pcnts consistent with other data
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
gen n_res = 1
gen r_res = 0
gen w = 1
gen id = _n
gen s_res = 1
gen lang_instr = "Portugese/Tetun"



gen country = "Timor-Leste"
gen cntabb = "TLS"
gen idcntry = 626

*Standardizing survey variables:
gen su1 = school_code
gen strata1 = grade

codebook, compact
cf _all using "${path}\CNT\TLS\TLS_2011_EGRA\TLS_2011_EGRA_v01_M_v01_A_HAD.dta"

save "${path}\CNT\TLS\TLS_2011_EGRA\TLS_2011_EGRA_v01_M_v01_A_HAD.dta", replace
