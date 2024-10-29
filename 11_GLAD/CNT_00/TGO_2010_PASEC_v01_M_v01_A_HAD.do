******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for TGO_2010_PASEC
*/

global path = "N:\GDB\HLO_Database"

use "${path}\CNT\TGO\TGO_2010_PASEC\TGO_2010_PASEC_v01_M\Data\Stata\TOG2_2010.dta", clear

append using "${path}\CNT\TGO\TGO_2010_PASEC\TGO_2010_PASEC_v01_M\Data\Stata\TOG5_2010.dta"

*Making variables consistent with other datasets:
	
gen idschool = numecole
gen idclass = numclass
gen idgrade = numclass
gen idstud = numeleve
gen strata1 = numstrate
gen su1 = numecole
gen weight = iproinclu
gen female = fille
gen score_reading = sfin2f100    if idgrade == 2
replace score_reading = sfin5f100  if idgrade == 5

gen score_math = sfin2m100    if idgrade == 2
replace score_math = sfin5f100    if idgrade == 5


*Identifying variables for ESCS:
*Variables not available for ESCS
save "${path}\CNT\TGO\TGO_2010_PASEC\TGO_2010_PASEC_v01_M_v01_A_BASE.dta", replace
