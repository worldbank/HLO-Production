******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for MUS_2006_PASEC
*/

global path = "N:\GDB\HLO_Database"

*Mauritius 2006 data obtained from PASEC website not working:
*Mauritius data taken from Nadir's database.

use "N:\GDB\0_RawInput\back_05_2006_02_9.dta", clear
append using "N:\GDB\0_RawInput\back_05_2006_05_9.dta", force

keep if pays == "Maurice"
*Making variables consistent with other datasets:
	
gen idschool = num_ecole
gen idclass = num_classe
gen idgrade = num_classe
gen idstud = num_eleve
gen strata1 = strate
gen su1 = num_ecole
gen weight = iproinclu
gen female = el_fille
gen age = el_age
gen score_reading = sfin2f100  if idgrade == 2
replace score_reading = sfin5f100 if idgrade == 5

gen score_math = sfin2m100  if idgrade == 2
replace score_math = sfin5f100 if idgrade == 5


*Identifying variables for ESCS:
*el_maison el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelecnumlabel, add
foreach var of varlist el_maison el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec {
	tab `var'
	replace `var' = . if `var' == 999
}
tab el_maison, gen(dmaison)
*The variables are cleaned:
bysort idgrade: mdesc dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec 
*4 variables missing for grade 5:
*Replacing missing values: One variable has 10% missing values
foreach var of varlist dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec  {
	bysort num_ecole num_classe: egen `var'_mean  = mean(`var')
	replace `var' = `var'_mean if missing(`var')
}
bysort idgrade: mdesc dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec
alphawgt dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec  [weight = weight], detail std item // 0.6615

*Maison variable is not value labelled.
*Don't know what toiletfosse is
gen books_yn = el_livres
gen books_home_yn = el_livreslect
gen books_school_yn = el_livrescol
gen toilet_yn = el_toileteau
gen electricity_yn = el_ecmais
gen charcoal_yn = el_feuxcharbon
gen fridge_yn = el_frigo
gen vcr_yn = el_magnetoscope
gen dvd_yn = el_dvd
gen computer_yn = el_ordinateur
gen well_yn = el_puits
gen tap_yn = el_robinet
gen telephone_yn = el_telephone
gen television_yn = el_televiseur
gen hifi_yn = el_hifi
gen cart_yn = el_charrette
gen plow_yn = el_charrue
gen bicycle_yn = el_velo
gen motorcycle_yn = el_mobylette
gen gas_heater_yn = el_rechaugaz
gen gas_lamp_yn = el_lampgaz
gen oil_lamp_yn = el_lampetrol
gen canoe_engine_yn = el_pirogmot 
gen canoe_yn = el_pirogsanmot 
gen radio_yn = el_radio 
gen car_yn = el_voiture 
gen lamp_yn = el_lampelec

save "${path}\CNT\MUS\MUS_2006_PASEC\MUS_2006_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud strata1 female age weight su1 score_reading score_math *_yn

save "${path}\CNT\MUS\MUS_2006_PASEC\MUS_2006_PASEC_v01_M_v01_A_HAD.dta", replace
