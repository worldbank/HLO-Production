******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for BEN_2005_PASEC
*/
set seed 10051990
set sortseed 10051990
global path = "N:\GDB\HLO_Database"

log using "${program}\LOG\BEN_2005_PASEC_v01_M.smcl", replace

use "${path}\CNT\BEN\BEN_2005_PASEC\BEN_2005_PASEC_v01_M\Data\Stata\BEN2_2005.dta", clear
ren (qe2* qm2*) (qe5* qm5*)
append using "${path}\CNT\BEN\BEN_2005_PASEC\BEN_2005_PASEC_v01_M\Data\Stata\BEN5_2005.dta"
ren (qe5* qm5*) (qe* qm*)

*Making variables consistent with other datasets:
gen idschool = numecole
gen idclass = numclass
gen idgrade = numclass
gen idstud = numeleve
gen female = qe_b
gen age = qe_c
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5

*Identifying variables for ESCS:
*Grade 2 data has only house variables:
*ESCS variables for grade 5:
*qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag
numlabel, add
foreach var of varlist qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag  
*Four variables have 50 percent missing. Removing those variables:
*EUASOURC LAMPMECHE PUITS CHARRETTE
*Replacing missing values:
foreach var of varlist qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag   {
	bysort numecole numclass: egen `var'_mean  = mean(`var')
	
	replace `var' = `var'_mean if missing(`var')
}
bysort idgrade: mdesc qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag
alphawgt  qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_v qe_w qe_x qe_y qe_aa qe_ab qe_ac qe_ad qe_ae qe_af qe_ag, detail std item // 0.7583

gen house_hard_yn = qe_i
gen house_semi_hard_yn = qe_j
gen house_banco_yn =  qe_k
gen house_straw_wood_yn = qe_l
gen tap_yn = qe_n 
gen well_yn = qe_o 
gen tank_yn = qe_p 
gen toilet_yn = qe_q
gen electricity_yn =  qe_r
gen oil_lamp_yn =  qe_s 
gen gas_lamp_yn = qe_t
gen fridge_yn = qe_u
gen gas_stove_yn = qe_v
gen television_yn = qe_w
gen sewing_machine_yn = qe_x
gen computer_yn = qe_y
gen radio_yn = qe_aa
gen books_yn = qe_ab
gen car_yn = qe_ac
gen cart_yn = qe_ad
gen plow_yn = qe_ae
gen bicycle_yn = qe_af
gen motorcycle_yn =  qe_ag
save "${path}\CNT\BEN\BEN_2005_PASEC\BEN_2005_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud  female age score_reading score_math *_yn

codebook, compact
cf _all using "${path}\CNT\BEN\BEN_2005_PASEC\BEN_2005_PASEC_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BEN\BEN_2005_PASEC\BEN_2005_PASEC_v01_M_v01_A_HAD.dta", replace
log close
