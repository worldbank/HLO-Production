******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for GIN_2004_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M\Data\Stata\Gn_Global2.dta", clear

append using "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M\Data\Stata\Gn_Global5.dta"

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
*ESCS variables not avaialble

save "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M_v01_A_BASE.dta", replace
keep idschool idclass idgrade idstud  female age  score_reading score_math 
save "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M_v01_A_HAD.dta", replace

