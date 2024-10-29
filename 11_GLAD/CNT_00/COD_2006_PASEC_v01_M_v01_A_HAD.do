******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for COD_2006_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\COD\COD_2006_PASEC\COD_2006_PASEC_v01_M\Data\Stata\COG2.dta", clear
ren (qe2* qm2*) (qe5* qm5*)

append using "${path}\CNT\COD\COD_2006_PASEC\COD_2006_PASEC_v01_M\Data\Stata\COG5.dta"
ren (qe5* qm5*) (qe* qm*)

*Making variables consistent with other datasets:
	
gen idschool = numecole
gen idclass = numclass
gen idgrade = numclass
gen idstud = numeleve
gen weight = iproinclu
gen female = qe_1
gen age = qe_2
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5


*Identifying variables for ESCS:
numlabel, add
foreach var of varlist qe_3a qe_3b qe_3c qe_4a qe_4b qe_4c qe_4d qe_4e qe_4f qe_5a qe_5b qe_5c qe_5d qe_5e qe_5f qe_5g qe_5h qe_6a qe_6b qe_6c {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc qe_3a qe_3b qe_3c qe_4a qe_4b qe_4c qe_4d qe_4e qe_4f qe_5a qe_5b qe_5c qe_5d qe_5e qe_5f qe_5g qe_5h qe_6a qe_6b qe_6c
*Replacing missing values: One variable has 10% missing values
foreach var of varlist qe_3a qe_3b qe_3c qe_4a qe_4b qe_4c qe_4d qe_4e qe_4f qe_5a qe_5b qe_5c qe_5d qe_5e qe_5f qe_5g qe_5h qe_6a qe_6b qe_6c {
	bysort numecole numclass: egen `var'_mean  = mean(`var')
	bysort numstrate: egen `var'_mean_str = mean(`var')
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort idgrade: mdesc qe_3a qe_3b qe_3c qe_4a qe_4b qe_4c qe_4d qe_4e qe_4f qe_5a qe_5b qe_5c qe_5d qe_5e qe_5f qe_5g qe_5h qe_6a qe_6b qe_6c
alphawgt qe_3a qe_3b qe_3c qe_4a qe_4b qe_4c qe_4d qe_4e qe_4f qe_5a qe_5b qe_5c qe_5d qe_5e qe_5f qe_5g qe_5h qe_6a qe_6b qe_6c [weight = weight], detail std item // 0.8189


gen house_hard_yn = qe_3a 
gen house_semi_hard_banco_yn = qe_3b 
gen house_straw_wood_yn = qe_3c 
gen well_yn = qe_4a
gen tap_yn = qe_4b 
gen toilet_yn = qe_4c
gen electricity_yn = qe_4d
gen lamp_yn =  qe_4e
gen oil_lamp_yn = qe_4f
gen radio_yn = qe_5a 
gen telephone_yn = qe_5b 
gen sewing_machine_yn = qe_5c
gen gas_stove_yn =  qe_5d
gen television_yn = qe_5e
gen fridge_yn = qe_5f 
gen dvd_yn = qe_5g
gen computer_yn = qe_5h
gen bicycle_yn =  qe_6a
gen motorcycle_yn = qe_6b
gen car_yn = qe_6c
save "${path}\CNT\COD\COD_2006_PASEC\COD_2006_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud  female age weight score_reading score_math *_yn

save "${path}\CNT\COD\COD_2006_PASEC\COD_2006_PASEC_v01_M_v01_A_HAD.dta", replace
