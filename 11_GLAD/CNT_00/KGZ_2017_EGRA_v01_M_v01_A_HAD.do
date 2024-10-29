// 2017
set seed 10051990
set sortseed 10051990

use "${path}/CNT/KGZ/KGZ_2017_EGRA/KGZ_2017_EGRA_v01_M/Data/Stata/2017.dta", clear
*Data is weighted:
gen w = 1
ren (treatment masked_SchoolID masked_StudentID rp_permin rpc_score q1) (strata1 school_code id orf read_comp_score_pcnt lang_instr)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized) 
replace language = "Kyrgyz" if language == "K"
replace language = "Russian" if language == "R"
gen year = 2017
gen r_res = 1
gen n_res = 1
gen s_res = 1
gen female = 1 if gender == "G"
replace female = 0 if gender == "B"
*Variables of interest:
gen oral_read_score_zero = (rp_correct == 0)
gen oral_read_score_pcnt = (rp_correct/42)*100 if grade == 2
replace oral_read_score_pcnt = (rp_correct/82)*100 if grade == 4
egen read_comp_score = rowtotal(rpc?)
gen read_comp_score_zero = (read_comp_score == 0)
keep w language country year strata1 region school_code id female grade orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt year n_res w r_res s_res lang_instr  wt_final q4a q4b q4c q4d q4e q6 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q25
replace country = "Kyrgyzstan"
decode region, gen(region_s)
drop region 
ren region_s region
decode lang_instr, gen(lang_instr_s)
drop lang_instr
ren lang_instr_s lang_instr
drop if missing(lang_instr)

*ESCS:
*Identifying variables:
*q4a q4b q4c q4d q6 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q25
numlabel, add
foreach var of varlist q4a q4b q4c q4d q6 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q25 {
	tab `var'
}
*Cleaning:
foreach var of varlist q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 {
	replace `var' = . if `var' == 3
	replace `var' = 0 if `var' == 2
}
foreach var of varlist q4a q4b q4c q4d {
	replace `var' = 0 if `var' != 1
}
*Creating dummies from categorical variables:
foreach var of varlist q6 q25 q23 {
	tab `var', gen(`var'_d)
}
mdesc q4a q4b q4c q4d q6 q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q25
*q23 and q25 have 25% missing values. so dropped
foreach var of varlist q4a q4b q4c q4d q6_d* q11 q12 q13 q14 q15 q16 q17 q18 q19 q20 q21 q22 {
	bysort region school_code: egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt q4a_std q4b_std q4c_std q4d_std q6_d*_std q11_std q12_std q13_std q14_std q15_std q16_std q17_std q18_std q19_std q20_std q21_std q22_std [weight = wt_final], detail item
pca q4a_std q4b_std q4c_std q4d_std q6_d*_std q11_std q12_std q13_std q14_std q15_std q16_std q17_std q18_std q19_std q20_std q21_std q22_std [weight = wt_final]
predict ESCS

*KGZ EGRA producing wierd results
/*Generating Asset Variables:
gen newspapers_yn = q4a
gen magazines_yn = q4b
gen religious_books_yn = q4c
gen books_yn = q4d
gen books_n_1_10 = q6_d1
gen books_n_11_40 = q6_d2
gen books_n_41 = q6_d3
gen radio_yn = q11
gen telephone_yn = q12
gen mobile_yn = q13
gen television_yn = q14
gen fridge_yn = q15
gen bicycle_yn = q16
gen motorcycle_yn = q17
gen computer_yn = q18
gen internet_yn = q19
gen automobile_yn = q20
gen tractor_yn = q21
gen truck_yn = q22
*/
replace country = "Kyrgyzstan"
gen cntabb = "KGZ"
gen idcntry = 417

*Weight variables:
gen su1 = school_code



save "${path}/CNT/KGZ/KGZ_2017_EGRA/KGZ_2017_EGRA_v01_M_v01_A_BASE/KGZ_2017_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry w language country year strata1 su1 region school_code id female grade orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt year n_res w r_res s_res lang_instr  wt_final 
codebook, compact
cf _all using "${path}/CNT/KGZ/KGZ_2017_EGRA/KGZ_2017_EGRA_v01_M_v01_A_HAD.dta"
save "${path}/CNT/KGZ/KGZ_2017_EGRA/KGZ_2017_EGRA_v01_M_v01_A_HAD.dta", replace

