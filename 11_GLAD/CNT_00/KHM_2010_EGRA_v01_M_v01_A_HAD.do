set seed 10051990
set sortseed 10051990



****Cambodia:
use "${path}\CNT\KHM\KHM_2010_EGRA\KHM_2010_EGRA_v01_M\Data\Stata\2010.dta", clear
*Develop variables of interest:
egen read_comp_score = rowtotal(SOPHY?)
gen read_comp_score_zero = (read_comp_score == 0)
gen read_comp_score_pcnt = (read_comp_score/5)*100
ren (SCHOOL GRADE) (school_code grade)
keep school grade read_comp_score_pcnt read_comp_score_zero
gen year = 2010
bysort school_code: gen id = _n
gen n_res = 1 
gen r_res = 1
gen w = 0

gen country = "Cambodia"
gen cntabb = "KHM"
gen idcntry = 116
gen language = "Khmer"
gen lang_instr = language
ds school_code id, not
display r(varlist)
codebook, compact
cf _all using "${path}\CNT\KHM\KHM_2010_EGRA\KHM_2010_EGRA_v01_M_v01_A_HAD.dta" 
save "${path}\CNT\KHM\KHM_2010_EGRA\KHM_2010_EGRA_v01_M_v01_A_HAD.dta", replace
