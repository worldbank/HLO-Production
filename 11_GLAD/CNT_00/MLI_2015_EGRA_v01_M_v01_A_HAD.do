
set seed 10051990
set sortseed 10051990


use "${path}/CNT/MLI/MLI_2015_EGRA/MLI_2015_EGRA_v01_M/Data/Stata/2015.dta", clear
*Data is survey set.
gen w = 1
ren (wt_stage2 home_assess_lang) (wt_final tlang)
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2, fpc(fpc2) strata(strata2) singleunit(scaled) vce(linearized)
xtile tses0 = wealthindex [pweight = wt_final], nq(5)
keep w country language school_code region_name school_type year id grade age female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tses0 strata1 stage1 fpc1 strata2 stage2 fpc2 wt_final w tlang s_6 s_10 s_11 s_12 s_13 s_14 s_15 s_16 s_17 s_18 s_19
ren region_name region
*Sampling Method:
gen n_res = 0
*Confirm with wherever we got this data from that it is nationally representative.
gen r_res = 1
gen s_res = 1
gen l_res = 1
gen lang_instr = "French"
decode language, gen(language_s)
drop language
ren language_s language
encode school_code, gen(school_code_n)
drop school_code
ren school_code_n school_code
encode id, gen(id_n)
drop id
ren id_n id
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type

*****************************************************
*Development of ESCS Variable:
*****************************************************
*s_6 s_10 s_11 s_12 s_13 s_14 s_15 s_16 s_17 s_18 s_19
numlabel, add
foreach var of varlist s_6 s_10 s_11 s_12 s_13 s_14 s_15 s_16 s_17 s_18 s_19 {
	tab `var'
	replace `var' = . if `var' == 9
}
mdesc s_6 s_10 s_11 s_12 s_13 s_14 s_15 s_16 s_17 s_18 s_19
*s_6 has 23% missing. Drop the variable:
foreach var of varlist s_10 s_11 s_12 s_13 s_14 s_15 s_16 s_17 s_18 s_19 {
	bysort region school_code: egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	bysort region: egen `var'_mean_reg = mean(`var')
	bysort region: egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt s_10_std s_11_std s_12_std s_13_std s_14_std s_15_std s_16_std s_17_std s_18_std s_19_std [weight = wt_final], detail item
pca s_10_std s_11_std s_12_std s_13_std s_14_std s_15_std s_16_std s_17_std s_18_std s_19_std [weight = wt_final]
predict ESCS

*Generation of asset variables:
gen radio_yn = s_10
gen telephone_yn = s_11
gen electricity_yn = s_12
gen television_yn = s_13
gen fridge_yn = s_14
gen toilet_yn = s_15
gen bicycle_yn = s_16
gen motorcycle_yn = s_17
gen canoe_yn = s_18
gen four_wheeler_yn = s_10


gen idcntry = 466
gen cntabb = "MLI"
save "${path}/CNT/MLI/MLI_2015_EGRA/MLI_2015_EGRA_v01_M_v01_A_BASE/MLI_2015_EGRA_v01_M_v01_A_BASE.dta", replace
keep country idcntry cntabb w n_res r_res l_res lang_instr language school_code region school_type year id grade age female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tses0 strata1 fpc1 strata2 fpc2 wt_final w tlang *_yn

codebook, compact
cf _all using "${path}/CNT/MLI/MLI_2015_EGRA/MLI_2015_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 id using "${path}/CNT/MLI/MLI_2015_EGRA/MLI_2015_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}/CNT/MLI/MLI_2015_EGRA/MLI_2015_EGRA_v01_M_v01_A_HAD.dta", replace
