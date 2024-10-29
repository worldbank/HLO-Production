// 2012
set seed 10051990
set sortseed 10051990

use "${path}/CNT/BDI/BDI_2012_EGRA/BDI_2012_EGRA_v01_M/Data/Stata/2012.dta", clear
*Data is svyset but svy variable IPROINCLU is not available. Other svy variables like strate_base also not available.
gen w = 0
gen year = 2012
ren (femme) (female)
egen read_comp_score = rowtotal(read_comp*)
gen read_comp_score_zero = (read_comp_score == 1)
gen read_comp_score_pcnt = (read_comp_score/5)*100 if missing(read_comp6)
replace read_comp_score_pcnt = (read_comp_score/9)*100
gen grade = 2
gen n_res = 1 
gen r_res = 0
gen lang_instr = "French"
gen language = "French"
*Generating index for socio-economic index.
*The variables are not very clear.
save "${path}\CNT\BDI\BDI_2012_EGRA\BDI_2012_EGRA_v01_M_v01_A_BASE\BDI_2012_EGRA_v01_M_v01_A_BASE.dta" , replace

keep year age cwpm orf female read_comp_score_pcnt read_comp_score_zero w n_res r_res grade lang_instr language

gen country = "Burundi"
gen cntabb = "BDI"
gen idcntry = 108
gen n = _n

codebook, compact
cf _all using "${path}\CNT\BDI\BDI_2012_EGRA\BDI_2012_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BDI\BDI_2012_EGRA\BDI_2012_EGRA_v01_M_v01_A_HAD.dta", replace



