********************************************

set seed 10051990
set sortseed 10051990


use "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M\Data\Stata\back_05_2006_02_9.dta", clear
append using "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M\Data\Stata\Gn_Global2.dta"
append using "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M\Data\Stata\back_05_2006_05_9.dta", force
append using "${path}\CNT\GIN\GIN_2004_PASEC\GIN_2004_PASEC_v01_M\Data\Stata\Gn_Global5.dta"

replace pays = "Guinea" if missing(pays)
replace annee = 2005 if missing(annee)


/*use "${path}\STANDARD\ccc_list.dta", clear
levelsof wbcode, local(ccc)

touch "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M_v01_A_HAD.dta", replace

use "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M_v01_A_HAD.dta", clear

foreach c of local ccc {
	forvalues year = 1996/2012 {
		capture noisily: cd "${path}/CNT/`c'/`c'_`year'_PASEC/`c'_`year'_PASEC_v01_M_v01_A_HAD.dta"
		fs *.dta
		foreach f in `r(files)' {
			capture noisily: append using `f'
		}
	}
}
*/

gen IDGRADE = num_classe
replace IDGRADE = num_class if missing(IDGRADE)
drop if missing(IDGRADE)

gen AGE = age 
gen year = annee 

egen SCORE_READING_2 = std(sfin2f100) if IDGRADE == 2
replace SCORE_READING_2 = SCORE_READING_2*100 + 500

egen SCORE_READING_5 = std(sfin5f100) if IDGRADE == 5
replace SCORE_READING_5 = SCORE_READING_5*100 + 500

gen SCORE_READING = SCORE_READING_2 if IDGRADE == 2
replace SCORE_READING = SCORE_READING_5 if IDGRADE == 5

egen SCORE_MATH_2 = std(sfin2m100) if IDGRADE == 2
replace SCORE_MATH_2 = SCORE_MATH_2*100 + 500

egen SCORE_MATH_5 = std(sfin5m100) if IDGRADE == 5
replace SCORE_MATH_5 = SCORE_MATH_5*100 + 500

gen SCORE_MATH = SCORE_MATH_2 if IDGRADE == 2
replace SCORE_MATH = SCORE_MATH_5 if IDGRADE == 5

sort SCORE_READING
drop if missing(SCORE_READING)
gen STUDENT_WEIGHT = iproinclu

gen LOW_READING_PROFICIENCY_UIS = (sfin2f100 > 75) if IDGRADE == 2
replace LOW_READING_PROFICIENCY_UIS = (sfin5f100 > 28.5) if IDGRADE == 5

gen LOW_READING_PROFICIENCY_WB = (sfin2f100 > 75) if IDGRADE == 2
replace LOW_READING_PROFICIENCY_WB = (sfin5f100 > 41.4) if IDGRADE == 5

gen IDSTUD = num_eleve
gen IDSCHOOL = num_ecole
gen IDSTRATA = strate


gen IDCNTRY= 204 if pays == "Bénin"
replace IDCNTRY = 854 if inlist(pays,"Burkina Faso","BFA")
replace IDCNTRY = 108 if pays == "Burundi"
replace IDCNTRY = 120 if pays == "Cameroun"
replace IDCNTRY = 174 if pays == "Comores"
replace IDCNTRY = 178 if pays == "Congo"
replace IDCNTRY = 384 if pays == "Cote dIvoire"
replace IDCNTRY = 266 if inlist(pays,"Gabon","GAB")
replace IDCNTRY = 450 if pays == "Madagascar"
replace IDCNTRY = 466 if pays == "Mali"
replace IDCNTRY = 480 if pays == "Maurice"
replace IDCNTRY = 478 if pays == "Mauritanie"
replace IDCNTRY = 562 if pays == "Niger"
replace IDCNTRY = 180 if pays == "RDC"
replace IDCNTRY = 686 if pays == "Sénégal"
replace IDCNTRY = 148 if inlist(pays,"TCD","Tchad")
replace IDCNTRY = 768 if inlist(pays,"TGO","Togo")
replace IDCNTRY = 324 if inlist(pays,"Guinea")


*Identifying variables for ESCS:
*el_maison el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelecnumlabel, add
foreach var of varlist el_maison el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec {
	tab `var'
	replace `var' = . if `var' == 999
}
tab el_maison, gen(dmaison)
*The variables are cleaned:
bysort IDCNTRY year IDGRADE: mdesc dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec 
*4 variables missing for grade 5:
*Replacing missing values: One variable has 10% missing values
foreach var of varlist dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec  {
	bysort IDCNTRY year num_ecole num_classe: egen `var'_mean  = mean(`var')
	bysort IDCNTRY year IDSTRATA: egen `var'_mean_str = mean(`var')
	replace `var' = `var'_mean if missing(`var')
	replace `var' = `var'_mean_str if missing(`var')
}
bysort IDCNTRY year IDGRADE: mdesc dmaison* el_livres el_livreslect el_livrescol el_toiletfosse el_toileteau el_ecmais el_feuxcharbon el_frigo el_magnetoscope el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur el_hifi el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec 

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 204, std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture  
predict ESCSBEN
gen ESCS = ESCSBEN

alpha dmaison?   el_toileteau el_ecmais el_frigo  el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol el_radio el_voiture el_lampelec  if IDCNTRY == 854, std detail item
pca dmaison?   el_toileteau el_ecmais el_frigo  el_dvd el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol el_radio el_voiture el_lampelec [weight = STUDENT_WEIGHT]
predict ESCSBFA
replace ESCS = ESCSBFA if IDCNTRY == 854

alpha dmaison? el_livres el_toileteau el_ecmais el_feuxcharbon el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 108, detail std item
pca dmaison? el_livres el_toileteau el_ecmais el_feuxcharbon el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture [weight = STUDENT_WEIGHT] 
predict ESCSBDI
replace ESCS = ESCSBDI if IDCNTRY == 108

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 120, detail item std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture [weight = STUDENT_WEIGHT]
predict ESCSCMR
replace ESCS = ESCSCMR if IDCNTRY == 120

alpha dmaison? el_livres  el_toiletfosse el_toileteau el_ecmais el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture if IDCNTRY == 174, detail item std
pca dmaison? el_livres  el_toiletfosse el_toileteau el_ecmais el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture [weight = STUDENT_WEIGHT]
predict ESCSCOM
replace ESCS = ESCSCOM if IDCNTRY == 174

alpha dmaison?  el_toileteau el_ecmais  el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol  el_radio el_voiture el_lampelec if IDCNTRY == 178, detail item std
pca dmaison?  el_toileteau el_ecmais  el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol  el_radio el_voiture el_lampelec [weight = STUDENT_WEIGHT]
predict ESCSCOG
replace ESCS = ESCSCOG if IDCNTRY == 178

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo el_magnetoscope el_dvd el_ordinateur  el_robinet  el_televiseur el_hifi  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec if IDCNTRY ==  384, item detail std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo el_magnetoscope el_dvd el_ordinateur  el_robinet  el_televiseur el_hifi  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec [weight = STUDENT_WEIGHT]
predict ESCSCIV
replace ESCS = ESCSCIV if IDCNTRY ==  384

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 266, detail item std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture [weight = STUDENT_WEIGHT]
predict ESCSGAB
replace ESCS = ESCSGAB if IDCNTRY == 266

alpha dmaison? el_livres el_livreslect el_livrescol  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 450, detail item std
pca dmaison? el_livres el_livreslect el_livrescol  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture [weight = STUDENT_WEIGHT]
predict ESCSMDG
replace ESCS = ESCSMDG if IDCNTRY == 450

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz  el_lampetrol  el_radio el_voiture el_lampelec if IDCNTRY == 480, detail item std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz  el_lampetrol  el_radio el_voiture el_lampelec [weight = STUDENT_WEIGHT]
predict ESCSMAU
replace ESCS = ESCSMAU if IDCNTRY == 480

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture if IDCNTRY == 478, detail item std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture [weight = STUDENT_WEIGHT]
predict ESCSMRT
replace ESCS = ESCSMRT if IDCNTRY == 478

alpha dmaison?  el_toileteau el_ecmais  el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec if IDCNTRY == 686, detail item std
pca dmaison?  el_toileteau el_ecmais  el_frigo el_magnetoscope  el_ordinateur el_puits el_robinet el_telephone el_televiseur  el_velo el_mobylette el_rechaugaz  el_lampetrol el_pirogmot el_pirogsanmot el_radio el_voiture el_lampelec [weight = STUDENT_WEIGHT]
predict ESCSSEN
replace ESCS = ESCSSEN if IDCNTRY == 686

alpha dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture  if IDCNTRY == 148, detail item std
pca dmaison? el_livres  el_toileteau el_ecmais  el_frigo  el_ordinateur  el_robinet el_telephone el_televiseur  el_charrette el_charrue el_velo el_mobylette el_rechaugaz el_lampgaz el_lampetrol  el_radio el_voiture  [weight = STUDENT_WEIGHT]
predict ESCSTCD
replace ESCS = ESCSTCD if IDCNTRY == 148

bysort IDCNTRY IDSCHOOL IDGRADE: egen SCHESCS = mean(ESCS)
bysort IDCNTRY IDGRADE: egen CNTESCS = mean(ESCS)

svyset IDSCHOOL [weight = STUDENT_WEIGHT], strata(IDSTRATA) vce(linearized) singleunit(missing) || IDSTUD
drop _merge
ren IDCNTRY idcntry
merge m:1 idcntry using "${path}\STANDARD\ccc_list.dta", assert(match using) keep(match) nogen

save "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M_v01_A_HAD\SSA_1996_PASEC_v01_M_v01_A_BASE.dta", replace

ren idcntry IDCNTRY
keep IDCNTRY IDSCHOOL STUDENT_WEIGHT IDSTRATA IDSTUD AGE IDGRADE SCORE_READING sfin2f100 sfin5f100 SCORE_MATH  ///
	ESCS countrycode wbcountryname wbregion wbincomegroup wbmember year LOW* CNTESCS SCHESCS
cf _all using "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M_v01_A_HAD\SSA_1996_PASEC_v01_M_v01_A_HAD.dta"
*Get unique identifiers:
save "${path}\SSA\SSA_1996_PASEC\SSA_1996_PASEC_v01_M_v01_A_HAD\SSA_1996_PASEC_v01_M_v01_A_HAD.dta", replace

