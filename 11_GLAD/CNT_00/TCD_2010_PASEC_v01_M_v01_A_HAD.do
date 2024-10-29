******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for TCD_2010_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\TCD\TCD_2010_PASEC\TCD_2010_PASEC_v01_M\Data\Stata\TCD2_2010.dta", clear

append using "${path}\CNT\TCD\TCD_2010_PASEC\TCD_2010_PASEC_v01_M\Data\Stata\TCD5_2010.dta"

*Making variables consistent with other datasets:
	
gen idschool = NUMECOLE
gen idclass = NUMCLASS
gen idgrade = NUMCLASS
gen idstud = NUMELEVE
gen strata1 = NUMSTRATE
gen female = FILLE

gen score_reading = SFIN2F100   if idgrade == 2
replace score_reading = SFIN5F100 if idgrade == 5

gen score_math = SFIN2M100   if idgrade == 2
replace score_math = SFIN5F100  if idgrade == 5


*Identifying variables for ESCS:
*MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS
numlabel, add
foreach var of varlist MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS  {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS 
*4 variables missing for grade 5:
*Replacing missing values: One variable has 10% missing values
foreach var of varlist  MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS  {
	bysort NUMECOLE NUMCLASS: egen `var'_mean  = mean(`var')
	bysort NUMSTRATE: egen `var'_mean_str = mean(`var')
	
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort idgrade: mdesc MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS 
alphawgt MAISDUR MAISSEMIDUR MAISTERREBANCO MAISPAILLEBOIS ROBINET PUIT TOILETEAU ELECMAIS LAMPETROL LAMPGAZ AUCUNSINFRA FRIGO RECHAUGAZ CHARBON TELEVISEUR MACHINCOUD ORDINATEUR TELEPHONE RADIO LIVRES VOITURE VELO MOBYLETTE CHARRETTE AUCUNSTRANSPORTS, detail item std // 0.7590

gen house_hard_yn = MAISDUR 
gen house_semi_hard_yn = MAISSEMIDUR 
gen house_clay_yn = MAISTERREBANCO 
gen house_straw_wood_yn = MAISPAILLEBOIS 
gen tap_yn = ROBINET 
gen well_yn = PUIT 
gen toilet_yn = TOILETEAU 
gen electricity_yn = ELECMAIS
gen oil_lamp_yn = LAMPETROL
gen gas_lamp_yn = LAMPGAZ
gen no_infrastructure_yn = AUCUNSINFRA
gen fridge_yn = FRIGO
gen gas_heater_yn = RECHAUGAZ
gen charcoal_yn = CHARBON
gen television_yn = TELEVISEUR
gen sewing_machine_yn = MACHINCOUD
gen computer_yn = ORDINATEUR
gen telephone_yn = TELEPHONE
gen radio_yn = RADIO
gen books_yn = LIVRES
gen car_yn = VOITURE
gen bicycle_yn = VELO
gen motorcycle_yn = MOBYLETTE
gen cart_yn = CHARRETTE
gen no_vehicle_yn = AUCUNSTRANSPORTS

save "${path}\CNT\TCD\TCD_2010_PASEC\TCD_2010_PASEC_v01_M_v01_A_BASE.dta", replace
ren *, lower
keep idschool idclass idgrade idstud strata1 female age score_reading score_math *_yn
save "${path}\CNT\TCD\TCD_2010_PASEC\TCD_2010_PASEC_v01_M_v01_A_HAD.dta", replace

