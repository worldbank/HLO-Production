******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for GAB_2006_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\GAB\GAB_2006_PASEC\GAB_2006_PASEC_v01_M\Data\Stata\GB2.dta", clear
ren (qe2* qm2*) (qe5* qm5*)

append using "${path}\CNT\GAB\GAB_2006_PASEC\GAB_2006_PASEC_v01_M\Data\Stata\GB5.dta"
ren (qe5* qm5*) (qe* qm*)

*Making variables consistent with other datasets:
	
gen idschool = numecole
gen idclass = numclasse
gen idgrade = numclasse
gen idstud = numeleve
gen female = qe_b
gen age = qe_c
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5


*Identifying variables for ESCS:
numlabel, add
foreach var of varlist qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_ubis qe_v qe_w qe_x qe_y qe_z qe_aa qe_ab qe_ae qe_af {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_ubis qe_v qe_w qe_x qe_y qe_z qe_aa qe_ab qe_ae qe_af
*Replacing missing values: One variable has 10% missing values
foreach var of varlist qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_ubis qe_v qe_w qe_x qe_y qe_z qe_aa qe_ab qe_ae qe_af {
	bysort numecole numclass: egen `var'_mean  = mean(`var')
	bysort numstrate: egen `var'_mean_str = mean(`var')
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort idgrade: mdesc qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_ubis qe_v qe_w qe_x qe_y qe_z qe_aa qe_ab qe_ae qe_af
alphawgt qe_i qe_j qe_k qe_l qe_n qe_o qe_p qe_q qe_r qe_s qe_t qe_u qe_ubis qe_v qe_w qe_x qe_y qe_z qe_aa qe_ab qe_ae qe_af , detail std item // 0.7914
gen house_hard_yn = qe_i 
gen house_semi_hard_yn = qe_j 
gen house_clay_yn = qe_k
gen house_straw_wood_yn =  qe_l 
gen tap_yn = qe_n
gen well_yn =  qe_o
gen toilet_yn =  qe_p
gen electricity_yn =  qe_q
gen oil_lamp_yn = qe_r
gen gas_lamp_yn =  qe_s 
gen fridge_yn = qe_t
gen stovetop_yn = qe_u
gen charcoal_yn = qe_ubis
gen television_yn = qe_v
gen sewing_machine_yn = qe_w 
gen computer_yn = qe_x 
gen telephone_yn = qe_y 
gen radio_yn = qe_z 
gen books_yn = qe_aa 
gen car_yn = qe_ab
gen bicycle_yn =  qe_ae
gen motorcycle = qe_af
save "${path}\CNT\GAB\GAB_2006_PASEC\GAB_2006_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud  female age  score_reading score_math *_yn
save "${path}\CNT\GAB\GAB_2006_PASEC\GAB_2006_PASEC_v01_M_v01_A_HAD.dta", replace

