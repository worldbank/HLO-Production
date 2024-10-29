* Phillipines

set seed 10051990
set sortseed 10051990

use "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M/Data/Stata/2013_s3.dta", clear

ren wt_stage3 wt_final
keep school_code id strata* stage* fpc* wt_final
collapse strata* stage* fpc* wt_final, by(school_code id)
encode (school_code), gen(school_code_n)
drop school_code
ren school_code_n school_code

save "${path}\TEMP\PHL_weights_2013_s3.dta", replace

use "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M/Data/Stata/2013_s3.dta", clear
ren wt_stage3 wt_final
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2, fpc(fpc2) strata(strata2) || stage3, fpc(fpc3) strata(strata3) singleunit(scaled) vce(linearized)
keep region year strata* stage* fpc* wt_final e_orf e_oral_read_score_pcnt e_oral_read_score_zero e_read_comp_score_pcnt e_read_comp_score_zero age female f_orf f_oral_read_score_pcnt f_oral_read_score_zero f_read_comp_score_pcnt f_read_comp_score_zero grade country school_code id exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f  exit_interview11a exit_interview12b exit_interview13b
ren (e_* f_*) (*1 *2)
reshape long orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero, i(id region year age female country grade school_code) j(language)
gen language_s = "English" if language == 1
replace language_s = "Filipino" if language == 2
drop language
ren language_s language
decode region, gen(region_s)
drop region
ren region_s region
encode (school_code), gen(school_code_n)
drop school_code
ren school_code_n school_code
gen n_res = 1
gen r_res = 1
gen w = 1
gen lang_instr = "English/Filipno"

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f  exit_interview11a exit_interview12b exit_interview13b
*Not using occupational variables as they do not match the broad ISCO categories.
numlabel, add
foreach var of varlist exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f exit_interview11a exit_interview12b exit_interview13b {
	tab `var'
	replace `var' = . if inlist(`var',88,99)
}
mdesc exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f exit_interview11a exit_interview12b exit_interview13b
foreach var of varlist exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f exit_interview11a {
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
alphawgt exit_interview6a exit_interview6b exit_interview6c exit_interview6d exit_interview6e exit_interview6f exit_interview11a [weight = wt_final], detail item
pca exit_interview6a_std exit_interview6b_std exit_interview6c_std exit_interview6d_std exit_interview6e_std exit_interview6f_std exit_interview11a_std [weight = wt_final]
predict ESCS

*Generating Asset Variables:
gen radio_yn = exit_interview6a
gen television_yn = exit_interview6b
gen computer_yn = exit_interview6c
gen toilet_yn = exit_interview6d
gen motorcycle_yn = exit_interview6e
gen four_wheeler_yn = exit_interview6f
gen books_yn = exit_interview11a

merge m:1 school_code id using "${path}\TEMP\PHL_weights_2013_s3.dta", assert(match) nogen

gen cntabb = "PHL" 
gen idcntry = 608

*Weight variables:
ren stage* su*

save "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M_v01_A_BASE/PHL_2013_EGRA_v01_M_v01_A_BASE.dta", replace
keep cntabb idcntry  n_res r_res w lang_instr language region year strata* fpc* su* wt_final orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero age female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero grade country school_code *_yn

codebook, compact
cf _all using "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M_v01_A_HAD.dta"
*Make sure each row has unique id
*merge 1:1 strata* su* region grade wt_final using "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M_v01_A_HAD.dta", update replace
save "${path}/CNT/PHL/PHL_2013_EGRA/PHL_2013_EGRA_v01_M_v01_A_HAD.dta", replace

