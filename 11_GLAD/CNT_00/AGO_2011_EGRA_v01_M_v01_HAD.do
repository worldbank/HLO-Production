****************************************************************************
************************Harmonizing Angola EGRA dataset*********************
****************************************************************************
set seed 10051990
set sortseed 10051990

use "${path}/CNT/AGO/AGO_2011_EGRA/AGO_2011_EGRA_v01_M/Data/Stata/2011.dta", clear 
ren (Schoolcode Studentcode) (school_code id)
gen female = (Studentgender == "feminino")
drop Studentgender 
gen year = 2011
foreach var of varlist Correct* {
	replace `var' = 0 if missing(`var')
	}
egen read_comp_score = rowtotal(CorrectGoodmorningMaria Correctsevenyears Correctfiveyears CorrectSaurimo Correctschool Correctnurse Correctfruits )
gen read_comp_score_pcnt = (read_comp_score/7)*100

/*Construction of socio-economic index:
*Identifying variables:
*Canyourmotherreadandwrite Canyourfatherreadandwrite
*Doyouhaveelectricityathome Doyouhavearefrigerator Doyouhaveplumbing Doyouhavetankwater DoyouhaveaTV Doyouhavearadio Doyouhaveagasstove Doyouhaveawoodburningstov Doyouhaveasingleburner Doyouhaveanoilstove Doyouhaveabicycle Doyouhaveacar Doyouhaveamotorcycle Doyouhaveabathroom Doyouhaveatoilet Doyouhaveacellphone Doyouhavealandlinephone Doyouhavefoodatschool
*First dimension: Homeposessions or wealth:

*Checking the quality of available indicators
mdesc Doyouhaveelectricityathome Doyouhavearefrigerator Doyouhaveplumbing Doyouhavetankwater DoyouhaveaTV Doyouhavearadio Doyouhaveagasstove Doyouhaveawoodburningstov Doyouhaveasingleburner Doyouhaveanoilstove Doyouhaveabicycle Doyouhaveacar Doyouhaveamotorcycle Doyouhaveabathroom Doyouhaveatoilet Doyouhaveacellphone Doyouhavealandlinephone 
mdesc Canyourmotherreadandwrite Canyourfatherreadandwrite

*A lot of missing values.
*As we do not have much information on the reasons for missing values, we will take these as missing at random.
replace Doyouhavefoodatschool = "0" if Doyouhavefoodatschool == "N�o"
replace Doyouhavefoodatschool = "1" if Doyouhavefoodatschool == "Sim"
destring Doyouhavefoodatschool, replace

gen mother_edu = 0 if (Canyourmotherreadandwrite == "Tua m�e n�o sabe ler")
replace mother_edu = 1 if (Canyourmotherreadandwrite == "Tua m�e l� mas n�o escreve")
replace mother_edu = 2 if (Canyourmotherreadandwrite == "Tua m�e l� e escreve                                                            ")
gen father_edu = 0 if (Canyourfatherreadandwrite == "Teu pai n�o sabe ler")
replace father_edu = 1 if (Canyourfatherreadandwrite == "Teu pai l� mas n�o escreve")
replace father_edu = 2 if (Canyourfatherreadandwrite == "Teu pai l� e escreve")
replace mother_edu = . if Canyourmotherreadandwrite == "Outra resposta"
replace father_edu = . if Canyourfatherreadandwrite == "Outra resposta"

*Imputation to fill in missing values using means of the variable:
foreach var of varlist Doyouhaveelectricityathome Doyouhavearefrigerator Doyouhaveplumbing Doyouhavetankwater DoyouhaveaTV Doyouhavearadio Doyouhaveagasstove Doyouhaveawoodburningstov Doyouhaveasingleburner Doyouhaveanoilstove Doyouhaveabicycle Doyouhaveacar Doyouhaveamotorcycle Doyouhaveabathroom Doyouhaveatoilet Doyouhaveacellphone Doyouhavealandlinephone mother_edu* father_edu* {
		egen `var'_mean = mean(`var')
		replace `var' = `var'_mean if missing(`var')
}

egen PARREAD = rowmax(mother_edu father_edu)
tab PARREAD, gen(HISCED_d)

*First investigating the degree of correlation among the variables:
alphawgt Doyouhaveelectricityathome Doyouhavearefrigerator Doyouhaveplumbing Doyouhavetankwater DoyouhaveaTV Doyouhavearadio Doyouhaveagasstove Doyouhaveawoodburningstov Doyouhaveasingleburner Doyouhaveanoilstove Doyouhaveabicycle Doyouhaveacar Doyouhaveamotorcycle Doyouhaveabathroom Doyouhaveatoilet Doyouhaveacellphone Doyouhavealandlinephone, detail std item label // cronbach alpha is 0.9263 internal consistency is high.
foreach var of varlist Doyouhaveelectricityathome Doyouhavearefrigerator Doyouhaveplumbing Doyouhavetankwater DoyouhaveaTV Doyouhavearadio Doyouhaveagasstove Doyouhaveawoodburningstov Doyouhaveasingleburner Doyouhaveanoilstove Doyouhaveabicycle Doyouhaveacar Doyouhaveamotorcycle Doyouhaveabathroom Doyouhaveatoilet Doyouhaveacellphone Doyouhavealandlinephone {
	egen `var'_std = std(`var')
}

pca *_std
predict HOMEPOS

*Adding parental education explains even less of the variation in scores.
gen ESCS = HOMEPOS
*/
gen n_res = 1
gen r_res = 0
gen w = 0
gen country = "Angola"
gen cntabb = "AGO"
gen idcntry = 024
gen n = _n
gen grade = 3
gen language = "Portuguese"
gen lang_instr = language
save "${path}\CNT\AGO\AGO_2011_EGRA\AGO_2011_EGRA_v01_M_v01_A_BASE\AGO_2011_EGRA_v01_M_v01_A_BASE.dta", replace
label define lyn 0 "No" 1 "Yes"
label values female lyn
keep school_code id year female read_comp_score_pcnt language lang_instr grade n_res r_res country cntabb idcntry w
codebook, compact
cf _all using "${path}\CNT\AGO\AGO_2011_EGRA\AGO_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\AGO\AGO_2011_EGRA\AGO_2011_EGRA_v01_M_v01_A_HAD.dta", replace

