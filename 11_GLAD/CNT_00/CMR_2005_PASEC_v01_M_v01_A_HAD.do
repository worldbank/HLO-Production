******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for CMR_2005_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\CMR\CMR_2005_PASEC\CMR_2005_PASEC_v01_M\Data\Stata\CmFr_Global2.dta", clear
append using "${path}\CNT\CMR\CMR_2005_PASEC\CMR_2005_PASEC_v01_M\Data\Stata\CmFr_Global5.dta"
*Making variables consistent with other datasets:
	
gen idschool = numecole
gen idclass = numclass
gen idgrade = numclass
gen idstud = numeleve
gen weight = iproinclu
gen female = fille
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5


*Identifying variables for ESCS:
numlabel, add
foreach var of varlist robinet puit toileteau elecmais lampetrol lampgaz frigo rechaugaz televiseur machinecou ordinateur telephone_el radio livres voiture charrette charrue velo mobylette {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc robinet puit toileteau elecmais lampetrol lampgaz frigo rechaugaz televiseur machinecou ordinateur telephone_el radio livres voiture charrette charrue velo mobylette
*Replacing missing values:
foreach var of varlist robinet puit toileteau elecmais lampetrol lampgaz frigo rechaugaz televiseur machinecou ordinateur telephone_el radio livres voiture charrette charrue velo mobylette {
	bysort numecole numclass: egen `var'_mean  = mean(`var')
	
	replace `var' = `var'_mean if missing(`var')
}
bysort idgrade: mdesc robinet puit toileteau elecmais lampetrol lampgaz frigo rechaugaz televiseur machinecou ordinateur telephone_el radio livres voiture charrette charrue velo mobylette
alphawgt robinet puit toileteau elecmais lampetrol lampgaz frigo rechaugaz televiseur machinecou ordinateur telephone_el radio livres voiture charrette charrue velo mobylette [weight = weight], detail std item // 0.7417

gen tap_yn = robinet 
gen well_yn = puit
gen toilet_yn = toileteau
gen electricity_yn = elecmais
gen oil_lamp_yn = lampetrol 
gen gas_lamp_yn = lampgaz
gen fridge_yn =  frigo
gen gas_heater_yn = rechaugaz
gen television_yn = televiseur
gen sewing_machine_yn = machinecou
gen computer_yn = ordinateur
gen telephone_yn = telephone_el
gen radio_yn = radio
gen books_yn = livres
gen car_yn = voiture
gen cart_yn = charrette 
gen plow_yn = charrue
gen bicycle_yn = velo
gen motorcycle_yn = mobylette
save "${path}\CNT\CMR\CMR_2005_PASEC\CMR_2005_PASEC_v01_M_v01_A_BASE.dta", replace

keep idschool idclass idgrade idstud  female age weight score_reading score_math *_yn
save "${path}\CNT\CMR\CMR_2005_PASEC\CMR_2005_PASEC_v01_M_v01_A_HAD.dta", replace

