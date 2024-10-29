set seed 10051990
set sortseed 10051990


// 2007
import excel "${path}/CNT/AFG/AFG_2007_EGRA/AFG_2007_EGRA_v01_M/Data/Original/2007.xls", clear firstrow 
save "${path}/CNT/AFG/AFG_2007_EGRA/AFG_2007_EGRA_v01_M/Data/Stata/2007.dta", replace
drop if missing(Grade)
ren (Grade StudentID Age TotalStoryWordsCorrectin1min) (grade id age orf)
gen female = 1 if Gender == "Female"
replace female = 0 if Gender == "Male"
destring TotalStoryWordsAttmeptedin1min, replace
gen oral_read_score_zero = (orf == 0 )
gen read_comp_score_zero = (TotalAnswersCorrect == 0)
gen read_comp_score_pcnt = (TotalAnswersCorrect/10)*100
keep grade id age female orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero 
gen w = 0 
gen n_res = 0
gen r_res = 0
gen language = "Dari/Pushto"
gen lang_instr = "Dari/Pushto"
destring, replace
gen year = 2007
drop if missing(grade)

gen country = "Afghanistan"
gen cntabb = "AFG"
gen idcntry = 004
gen n = _n
codebook, compact
cf _all using "${path}/CNT/AFG/AFG_2007_EGRA/AFG_2007_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/AFG/AFG_2007_EGRA/AFG_2007_EGRA_v01_M_v01_A_HAD.dta", replace
