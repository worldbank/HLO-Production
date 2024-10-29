* Sudan
set seed 10051990
set sortseed 10051990


use "${path}/CNT/SDN/SDN_2015_EGRA/SDN_2015_EGRA_v01_M/Data/Stata/2015.dta", clear
*ESCS variables not available
ren (Q_9_0_1 Q_9_5 Q_9_7_1) (region school_code school_type)
gen female = 1 if Q_9_8 == 2
replace female = 0 if  Q_9_8 == 1
*Developing variables of interest:
gen orf = Q_5_3/((60-Q_5_2)/60)
gen oral_read_score_pcnt = (Q_5_3/50)*100
gen oral_read_score_zero = (Q_5_3 == 0)
gen read_comp_score_pcnt = (Q_5_10/5)*100
gen read_comp_score_zero = (Q_5_10 == 0)
recode Q_9_7 (1 3 = 1) (2 4 = 0), gen(urban)
keep region urban school_code school_type female orf oral_read* read_comp* 
gen w = 0
gen n_res = 1
gen r_res = 0
gen language = "Arabic"
gen grade = 3
gen lang_instr = language
gen year = 2015
gen country = "Sudan"
gen cntabb = "SDN"
gen idcntry = 736
gen id = _n

codebook, compact
cf _all using "${path}\CNT\SDN\SDN_2015_EGRA\SDN_2015_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}\CNT\SDN\SDN_2015_EGRA\SDN_2015_EGRA_v01_M_v01_A_HAD.dta", update replace
save "${path}\CNT\SDN\SDN_2015_EGRA\SDN_2015_EGRA_v01_M_v01_A_HAD.dta", replace
