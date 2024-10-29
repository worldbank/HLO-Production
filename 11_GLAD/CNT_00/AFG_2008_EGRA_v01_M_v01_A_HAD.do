set seed 10051990
set sortseed 10051990

// 2008
import excel "${path}/CNT/AFG/AFG_2008_EGRA/AFG_2008_EGRA_v01_M/Data/Original/2008.xls", clear firstrow 
save "${path}/CNT/AFG/AFG_2008_EGRA/AFG_2008_EGRA_v01_M/Data/Stata/2008.dta", replace
ren (Grade StudentID Age WordsCorrect) (grade id age orf)
gen female = 1 if Gender == "Female"
replace female = 0 if Gender == "Male"
gen oral_read_score_zero = (orf == 0 )
drop if AnsCorrect == 6 | AnsCorrect == 21
gen read_comp_score_zero = (AnsCorrect == 0)
gen read_comp_score_pcnt = (AnsCorrect/5)*100
keep grade id age female orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero 
gen w = 0 
gen n_res = 0
gen r_res = 0
gen language = "Dari/Pushto"
gen lang_instr = "Dari/Pushto"
destring, replace
gen year = 2008
drop if missing(grade)

gen country = "Afghanistan"
gen cntabb = "AFG"
gen idcntry = 004
gen n = _n
codebook, compact
cf _all using "${path}/CNT/AFG/AFG_2008_EGRA/AFG_2008_EGRA_v01_M_v01_HAD.dta"
save "${path}/CNT/AFG/AFG_2008_EGRA/AFG_2008_EGRA_v01_M_v01_HAD.dta", replace
