* Tonga

set seed 10051990
set sortseed 10051990

use "${path}/CNT/TON/TON_2009_EGRA/TON_2009_EGRA_v01_M/Data/Stata/2009.dta", clear

ren (school_no student_code class CWCPM s9_6) (school_code id grade orf tppri)
replace orf = 0 if missing(orf)
gen female = 1 if gender == 1
replace female = 0 if gender == 2
*Constructing variables of interst:
replace s6_3 = 0 if missing(s6_3)
gen oral_read_score_pcnt = (s6_3/60)*100
gen oral_read_score_zero = (s6_3 == 0)
foreach var of varlist s6_5 s6_6 s6_7 s6_8 s6_9 {
	replace `var' = 0 if `var' == 9 | `var' == 2
}
egen read_comp_score = rowtotal(s6_5 s6_6 s6_7 s6_8 s6_9)
gen read_comp_score_pcnt = (read_comp_score/5)*100
gen read_comp_score_zero = (read_comp_score == 0)
keep year region school_code id female age grade tppri orf oral_read* read_comp* s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26 s9_27 s9_28
gen n_res = 1
gen s_res = 1
gen r_res = 0
gen w = 0
gen lang_instr = "Tongan"
gen language = "Tongan"
gen region_s = "Tongatapu" if region == 1
replace region_s = "Eua" if region == 2
replace region_s = "Hapai" if region == 3
replace region_s = "Vavau" if region == 4
drop region
ren region_s region

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26 s9_27 s9_28
foreach var of varlist s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26 s9_27 s9_28 {
	tab `var'
	replace `var' = . if `var' == 9
}
*Creating dummies out of categorical variables:
foreach var of varlist s9_26 s9_27 s9_28 {
	tab `var', gen(`var'_d)
}
*Removing water_0 and water_other from the variables: s9_28_d1 & s9_28_d4
*Missings:
mdesc s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26 s9_27 s9_28
*Filling missings:
foreach var of varlist s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26_d* s9_27_d* s9_28_d2 s9_28_d3  {
	bysort region school_code : egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')

	egen `var'_mean_cnt = mean(`var')
	
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean if missing(`var') & `var'_count > 10 & !missing(`var'_count)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
mdesc s9_11 s9_16 s9_17 s9_18 s9_19 s9_20 s9_21 s9_22 s9_23 s9_24 s9_25 s9_26_d* s9_27_d* s9_28*
alphawgt s9_11_std s9_16_std s9_17_std s9_18_std s9_19_std s9_20_std s9_21_std s9_22_std s9_23_std s9_24_std s9_25_std s9_26_d*_std s9_27_d*_std s9_28_d*_std, detail item
pca s9_11_std s9_16_std s9_17_std s9_18_std s9_19_std s9_20_std s9_21_std s9_22_std s9_23_std s9_24_std s9_25_std s9_26_d*_std s9_27_d*_std s9_28_d*_std
predict ESCS

*Generating Asset Variables:
gen books_yn = s9_11
gen radio_yn = s9_16
gen telephone_yn = s9_17
gen mobile_yn = s9_18
gen electricity_yn = s9_19
gen television_yn = s9_20
gen television_sky_yn = s9_21
gen fridge_yn = s9_22
gen toilet_yn = s9_23
gen vehicle_yn = s9_24
gen canoe_yn = s9_25
gen walls_brick_yn = s9_26_d1
gen walls_timber_yn = s9_26_d2
gen walls_corriron_yn = s9_26_d3
gen walls_fale_tonga_yn = s9_26_d4
gen gas_electric_stove_yn = s9_27_d1
gen kerosene_yn = s9_27_d2
gen firewood_yn = s9_27_d3
gen tap_in_home_compound_yn = s9_28_d1
gen tap_communal_yn = s9_28_d2

gen country = "Tonga"
gen cntabb = "TON"
gen idcntry = 776

save "${path}/CNT/TON/TON_2009_EGRA/TON_2009_EGRA_v01_M_v01_A_BASE/TON_2009_EGRA_v01_M_v01_A_BASE.dta", replace
keep country cntabb idcntry n_res s_res r_res w lang_instr language year region school_code id female age grade tppri orf oral_read* read_comp* *_yn

codebook, compact
cf _all using "${path}/CNT/TON/TON_2009_EGRA/TON_2009_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}/CNT/TON/TON_2009_EGRA/TON_2009_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}/CNT/TON/TON_2009_EGRA/TON_2009_EGRA_v01_M_v01_A_HAD.dta", replace



