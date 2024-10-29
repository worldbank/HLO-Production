
set seed 10051990
set sortseed 10051990


* Solomon Islands
 
import excel using "${path}/CNT/SLB/SLB_2017_EGRA\SLB_2017_EGRA_v01_M/Data/Original/2017.xlsx", firstrow clear
replace year = 2017 if year == 2016
drop orf
ren (SchoolID weight gender readcomp_pcnt readcomp_zero orf_correct orf_zero) (school_code wt_final female read_comp_score_pcnt read_comp_score_zero orf oral_read_score_zero)
bysort school_code id: gen id_n = _n
drop id
ren id_n id
gen n_res = 1 
gen r_res = 1
gen w = 1
*Develop variables of interest:
keep Province school_code grade age female year id n_res r_res wt_final orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero w
svyset school_code [pweight = wt_final], strata(Province) || grade || female
gen language = "English"
gen lang_instr = language
ren Province region
gen country = "Solomon Islands"
gen cntabb = "SLB"
gen idcntry = 090
*Standardizing survey variables:
encode region, gen(region_n)
gen su1 = school_code
gen strata1 = region_n
gen su2 = grade
gen su3 = female
svyset su1 [pweight = wt_final], strata(strata1) || su2 || su3

*codebook, compact
cf _all using "${path}\CNT\SLB\SLB_2017_EGRA\SLB_2017_EGRA_v01_M_v01_A_HAD"

save "${path}\CNT\SLB\SLB_2017_EGRA\SLB_2017_EGRA_v01_M_v01_A_HAD", replace
