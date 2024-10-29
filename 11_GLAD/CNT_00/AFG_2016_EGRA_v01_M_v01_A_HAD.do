set seed 10051990
set sortseed 10051990


use "${path}/CNT/AFG/AFG_2016_EGRA/AFG_2016_EGRA_v01_M/Data/Stata/2016_dari.dta", clear
ren (School_code Urbanicity_cd readcomp_pct orf_correct orf_zero readcomp_zero info_2) (school_code urban read_comp_score_pcnt orf oral_read_score_zero read_comp_score_zero age)  
gen oral_read_score_pcnt = (orf/54)*100
gen language = "Dari"
recode info_1 (0 = 1 "Female") (1= 0 "Males"), gen(female)
drop grade
recode info_3 (1=2) (2=3) (3=4) (4=5), gen(grade)
keep school_code Region urban language id age grade female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
gen w = 0 
gen n_res = 1
gen r_res = 1
gen lang_instr = language
bysort id: gen id_n = _n
drop id
ren id_n id
gen year = 2016
drop if missing(grade)

gen country = "Afghanistan"
gen cntabb = "AFG"
gen idcntry = 004
gen n = _n
save "${path}/TEMP/EGRA_Afghanistan_2016_dari_s.dta", replace

use "${path}/CNT/AFG/AFG_2016_EGRA/AFG_2016_EGRA_v01_M/Data/Stata/2016_pushto.dta", clear
ren (LOI_cd Urbanicity_cd RC_Percent SumORF ORF_Zero ORF_percent Info_2) (lang_instr urban read_comp_score_pcnt orf oral_read_score_zero oral_read_score_pcnt age) 
gen read_comp_score_zero =  (SumComprehension == 0)
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt)
replace read_comp_score_zero = 0 if missing(read_comp_score_zero)
gen language = "Pushto"
recode Info_1 (0 = 1 "Female") (1= 0 "Males"), gen(female)
recode Info_3 (1=2) (2=3) (3=4) (4=5), gen(grade)
keep school_code Region urban language id age grade female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
gen w = 0 
gen n_res = 1
gen r_res = 1
gen lang_instr = language
bysort id: gen id_n = _n
drop id
ren id_n id
gen year = 2016
drop if missing(grade)

gen country = "Afghanistan"
gen cntabb = "AFG"
gen idcntry = 004
gen n = _n
save "${path}/TEMP/EGRA_Afghanistan_2016_pushto_s.dta", replace

use "${path}/TEMP/EGRA_Afghanistan_2016_dari_s.dta", clear
append using "${path}/TEMP/EGRA_Afghanistan_2016_pushto_s.dta"	

codebook, compact
cf _all using "${path}/CNT/AFG/AFG_2016_EGRA/AFG_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/AFG/AFG_2016_EGRA/AFG_2016_EGRA_v01_M_v01_A_HAD.dta", replace


