******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for MDG_2005_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\MDG\MDG_2005_PASEC\MDG_2005_PASEC_v01_M\Data\Stata\MDG2_2005.dta", clear

append using "${path}\CNT\MDG\MDG_2005_PASEC\MDG_2005_PASEC_v01_M\Data\Stata\MDG5_2005.dta"

*Making variables consistent with other datasets:
	
gen idschool = numecole
gen idclass = numclass
gen idgrade = numclass
gen idstud = numeleve
gen female = fille
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5


*Identifying variables for ESCS:
* maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette
numlabel, add
foreach var of varlist maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette
*4 variables missing for grade 5:
*Replacing missing values: One variable has 10% missing values
foreach var of varlist  maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette {
	bysort numecole numclass: egen `var'_mean  = mean(`var')
	replace `var' = `var'_mean if missing(`var')
}
bysort idgrade: mdesc maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette
alphawgt maisdur maissemidur maisbanco maistole maison robinet toileteau elecmais lampetrol petromax frigo rechaugaz televiseur machinecou ordinateur radio livreslect livrescol livres voiture charrette charrue velo mobylette , detail std item // 0.7568

*Not sure what is petromax
gen house_hard_yn =  maisdur 
gen house_semi_hard_yn = maissemidur 
gen house_clay_yn = maisbanco 
gen house_plate_yn = maistole
gen tap_yn =  robinet 
gen toilet_yn = toileteau
gen electricity_yn =  elecmais
gen oil_lamp_yn = lampetrol
gen fridge_yn =  frigo 
gen gas_heater_yn = rechaugaz 
gen television_yn = televiseur 
gen sewing_machine_yn = machinecou 
gen computer_yn = ordinateur 
gen radio_yn = radio 
gen books_home_yn = livreslect
gen books_school_yn =  livrescol 
gen books_yn = livres 
gen car_yn = voiture 
gen cart_yn = charrette
gen plow_yn = charrue
gen bicycle_yn = velo
gen motorbike_yn = mobylette 


save "${path}\CNT\MDG\MDG_2005_PASEC\MDG_2005_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud  female age  score_reading score_math *_yn
save "${path}\CNT\MDG\MDG_2005_PASEC\MDG_2005_PASEC_v01_M_v01_A_HAD.dta", replace
