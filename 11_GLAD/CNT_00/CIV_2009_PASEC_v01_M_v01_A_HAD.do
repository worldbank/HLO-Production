******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for CIV_2009_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\CIV\CIV_2009_PASEC\CIV_2009_PASEC_v01_M\Data\Stata\CI2OK.dta", clear
append using "${path}\CNT\CIV\CIV_2009_PASEC\CIV_2009_PASEC_v01_M\Data\Stata\CI5OK.dta"

*Making variables consistent with other datasets:
gen idschool = NUMECOLE
gen idclass = NUMCLASS
gen idgrade = NUMCLASS
gen idstud = NUMELEVE
gen strata1 = NUMSTRATE
gen weight = IPROINCLU
gen female = FILLE
gen age = AGE
gen score_reading = SFIN2F100   if idgrade == 2
replace score_reading = SFIN5F100 if idgrade == 5

gen score_math = SFIN2F100   if idgrade == 2
replace score_math = SFIN5F100   if idgrade == 5


*Identifying variables for ESCS:
* MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT
numlabel, add
foreach var of varlist  MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT
*Replacing missing values:
drop if missing(idgrade)
foreach var of varlist MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT {
	bysort NUMECOLE NUMCLASS: egen `var'_mean  = mean(`var')
	bysort NUMSTRATE NUMCLASS: egen `var'_mean_str = mean(`var')
	
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort idgrade: mdesc MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT
alphawgt MAIDUR MAISEMIDU MAIBANCO MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPELECT LAMPTEMP LAMPGAZ RADIO MACHNCOUD CUIRECHGAZ TELE FRIGO MAGNETO DVD HIFI ORDINA LIVRE VELO MOTO VOITURE PIROGMOT PIROGSANMOT [weight = weight], detail std item // 0.813

gen house_hard_yn = MAIDUR 
gen house_semi_hard_yn = MAISEMIDU
gen house_clay_yn =  MAIBANCO
gen house_straw_wood_yn = MAIPAILLE
gen tap_yn = ROBINET 
gen toilet_yn = TOILETTE 
gen electricity_yn = ELECTRICI
gen lamp_yn = LAMPELECT 
gen oil_lamp_yn = LAMPTEMP 
gen gas_lamp_yn = LAMPGAZ
gen radio_yn = RADIO
gen sewing_machine_yn = MACHNCOUD
gen gas_stove_yn = CUIRECHGAZ
gen television_yn = TELE 
gen fridge_yn = FRIGO
gen vcr_yn =  MAGNETO 
gen dvd_yn = DVD 
gen hifi_yn = HIFI
gen computer_yn =  ORDINA 
gen books_yn = LIVRE
gen bicycle_yn = VELO
gen motorcycle_yn = MOTO
gen car_yn =  VOITURE
gen canoe_engine_yn = PIROGMOT 
gen canoe_yn = PIROGSANMOT
save "${path}\CNT\CIV\CIV_2009_PASEC\CIV_2009_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud strata1 female age weight score_reading score_math *_yn
save "${path}\CNT\CIV\CIV_2009_PASEC\CIV_2009_PASEC_v01_M_v01_A_HAD.dta", replace
