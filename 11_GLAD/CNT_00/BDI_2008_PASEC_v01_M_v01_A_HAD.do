******************************************************
*Author: Syedah Aroob Iqbal
******************************************************
/*
*This do file 
1) Develops harmonized assessment database for BDI_2008_PASEC
*/
set seed 10051990
set sortseed 10051990
global path = "N:\GDB\HLO_Database"

log using "${program}\BDI_2008_PASEC_v01_M_v01_A_HAD.smcl", replace

use "${path}\CNT\BDI\BDI_2008_PASEC\BDI_2008_PASEC_v01_M\Data\Stata\BDI2_2009.dta", clear
append using "${path}\CNT\BDI\BDI_2008_PASEC\BDI_2008_PASEC_v01_M\Data\Stata\BDI5_2009.dta"

*Making variables consistent with other datasets:
gen idschool = NUMECOLE
gen idclass = NUMCLASS
gen idgrade = NUMCLASS
gen idstud = NUMELEVE
gen strata1 = NUMESTRATES
gen su1 = NUMECOLE
gen weight = IPROINCLU
gen female = FILLE
gen score_reading = SFIN2F100 if idgrade == 2
replace score_reading = SFIN5F100 if idgrade == 5

gen score_math = SFIN2M100 if idgrade == 2
replace score_math = SFIN5F100 if idgrade == 5

*Identifying variables for ESCS:
*MAIDUR MAISEMIDU MAITBATTU MAIPAILLE MAIAUTRE MAIAUTRE2 ROBINET EUASOURC TOILETTE ELECTRICI LAMPETEMP LAMPMECHE NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP PUITS CHARRETTE
*Removing variables specifiying others:  MAIAUTRE MAIAUTRE2
foreach var of varlist MAIDUR MAISEMIDU MAITBATTU MAIPAILLE ROBINET EUASOURC TOILETTE ELECTRICI LAMPETEMP LAMPMECHE NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP PUITS CHARRETTE {
	tab `var'
}
*The variables are cleaned:
bysort idgrade: mdesc MAIDUR MAISEMIDU MAITBATTU MAIPAILLE ROBINET EUASOURC TOILETTE ELECTRICI LAMPETEMP LAMPMECHE NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP PUITS CHARRETTE 
*PUITS and CHARRETTE are not available for grade 2:
*EUASOURC and LAMPMECHE not available for grade 5:
*Replacing missing values:
foreach var of varlist MAIDUR MAISEMIDU MAITBATTU MAIPAILLE ROBINET  TOILETTE ELECTRICI LAMPETEMP  NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP {
	bysort NUMECOLE NUMCLASS: egen `var'_mean  = mean(`var')
	bysort NUMESTRATES NUMCLASS: egen `var'_mean_str = mean(`var')
	
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort idgrade: mdesc MAIDUR MAISEMIDU MAITBATTU MAIPAILLE ROBINET EUASOURC TOILETTE ELECTRICI LAMPETEMP LAMPMECHE NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP PUITS CHARRETTE 
alphawgt  MAIDUR MAISEMIDU MAITBATTU MAIPAILLE ROBINET TOILETTE ELECTRICI LAMPETEMP  NOINFRAST FRIGO CUIRECHGAZ FEUXCHARBON MACHNCOUD TELE ORDINA TELEPHONE RADIO LIVRE VOITURE VELO MOTO NONTRANSP [weight = weight], detail std item /// 0.6465

gen house_hard_yn = MAIDUR
gen house_semi_hard_yn = MAISEMIDU
gen house_clay_yn = MAITBATTU
gen house_straw_wood_yn = MAIPAILLE
gen tap_yn =  ROBINET 
gen toilet_yn = TOILETTE
gen electricity_yn = ELECTRICI
gen oil_lamp_yn = LAMPETEMP
gen no_infrastructure_yn = NOINFRAST
gen frigde_yn = FRIGO 
gen gas_stove = CUIRECHGAZ 
gen charcoal_yn = FEUXCHARBON
gen sewing_machine_yn = MACHNCOUD
gen television_yn = TELE
gen computer_yn = ORDINA 
gen telephone_yn = TELEPHONE
gen radio_yn = RADIO 
gen books_yn = LIVRE
gen car_yn = VOITURE 
gen bicycle_yn = VELO
gen motorcycle_yn = MOTO 
gen no_vehicle_yn = NONTRANSP
save "${path}\CNT\BDI\BDI_2008_PASEC\BDI_2008_PASEC_v01_M_v01_A_BASE.dta", replace
ren AGE age
keep idschool idclass idgrade idstud strata1 su1 female age weight score_reading score_math *_yn
codebook, compact
cf _all using "${path}\CNT\BDI\BDI_2008_PASEC\BDI_2008_PASEC_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BDI\BDI_2008_PASEC\BDI_2008_PASEC_v01_M_v01_A_HAD.dta", replace
log close
