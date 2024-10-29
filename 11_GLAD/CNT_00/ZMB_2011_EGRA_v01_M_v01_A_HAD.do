* Zambia
set seed 10051990
set sortseed 10051990
use "${path}/CNT/ZMB/ZMB_2011_EGRA/ZMB_2011_EGRA_v01_M/Data/Stata/2011.dta", clear

*Data is svyset
gen w = 1
keep country year region district school_code id grade female language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_zero read_comp_score_pcnt fpc* wt_final w s38 s41_a s41_b s41_c s41_d s41_e s41_f s41_g s41_h s41_i s41_j s41_k s41_l s41_m s41_n s41_o s41_p s41_q s41_r
gen n_res = 1 
gen r_res = 1 
gen l_res = 1
replace orf = 0 if missing(orf)
replace read_comp_score_zero = 1 if missing(read_comp_score_zero)
replace read_comp_score_pcnt = 0 if missing(read_comp_score_pcnt)
replace oral_read_score_pcnt = oral_read_score_pcnt*100
replace read_comp_score_pcnt = read_comp_score_pcnt*100
decode language, gen(language_s)
drop language
ren language_s language
decode region, gen(region_s)
drop region
ren region_s region
gen lang_instr = language
replace country = "Zambia"
gen cntabb = "ZMB"
gen idcntry = 894

*********************************************************************************
*Development of ESCS Variable
*********************************************************************************
*Identifying variables:
*s38 s41_a s41_b s41_c s41_d s41_e s41_f s41_g s41_h s41_i s41_j s41_k s41_l s41_m s41_n s41_o s41_p s41_q s41_r
numlabel, add
foreach var of varlist s38 s41_a s41_b s41_c s41_d s41_e s41_f s41_g s41_h s41_i s41_j s41_k s41_l s41_m s41_n s41_o s41_p s41_q s41_r {
	tab `var'
}
mdesc s38 s41_a s41_b s41_c s41_d s41_e s41_f s41_g s41_h s41_i s41_j s41_k s41_l s41_m s41_n s41_o s41_p s41_q s41_r
*Filling in missing:
foreach var of varlist s38 s41_a s41_b s41_c s41_d s41_e s41_f s41_g s41_h s41_i s41_j s41_k s41_l s41_m s41_n s41_o s41_p s41_q s41_r {
	bysort region district school_code: egen `var'_mean = mean(`var')
	bysort region district school_code: egen `var'_count = count(`var')
	bysort region district : egen `var'_mean_d = mean(`var')
	bysort region district : egen `var'_count_d = count(`var')
	bysort region: egen `var'_mean_reg = mean(`var')
	bysort region: egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_d if missing(`var') & `var'_count_d > 7 & !missing(`var'_count_d)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt s38_std s41_a_std s41_b_std s41_c_std s41_d_std s41_e_std s41_f_std s41_g_std s41_h_std s41_i_std s41_j_std s41_k_std s41_l_std s41_m_std s41_n_std s41_o_std s41_p_std s41_q_std s41_r_std [weight = wt_final], detail item
pca s38_std s41_a_std s41_b_std s41_c_std s41_d_std s41_e_std s41_f_std s41_g_std s41_h_std s41_i_std s41_j_std s41_k_std s41_l_std s41_m_std s41_n_std s41_o_std s41_p_std s41_q_std s41_r_std [weight = wt_final]
predict ESCS

*Generating Assets variables:
gen books_yn = s38
gen radio_yn = s41_a
gen television_yn = s41_b
gen bicycle_yn = s41_c
gen vehicle_yn = s41_d
gen pit_toilet_yn = s41_e
gen toilet_yn = 1 if (s41_f == 1 | s41_g == 1)
replace toilet_yn = 0 if (s41_f == 0 & s41_g == 0)
gen electricity_yn = s41_h
gen computer_yn = s41_i
gen kitchen_yn = s41_j
gen firewood_yn = s41_k
gen coal_yn = s41_l
gen gas_electric_stove_yn = s41_m
gen river_stream_yn = s41_n
gen tank_watertruck_yn = 1 if (s41_o == 1 | s41_q == 1)
replace tank_watertruck_yn = 0 if (s41_o == 0 & s41_q == 0)
gen tap_in_home_compound_yn = s41_p
gen well_borehole_yn = s41_r

*Weight variables:
encode region, gen(strata1)
gen su1 = district
gen su2 = school_code
gen strata3 = grade
gen su3 = id 


save "${path}/CNT/ZMB/ZMB_2011_EGRA/ZMB_2011_EGRA_v01_M_v01_A_BASE/ZMB_2011_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry n_res r_res l_res lang_instr year region district strata* su* fpc* school_code id grade female language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_zero read_comp_score_pcnt fpc* wt_final w *_yn

codebook, compact
cf _all using "${path}/CNT/ZMB/ZMB_2011_EGRA/ZMB_2011_EGRA_v01_M_v01_A_HAD.dta"
*merge 1:1 country cntabb id using "${path}/CNT/ZMB/ZMB_2011_EGRA/ZMB_2011_EGRA_v01_M_v01_A_HAD.dta", update replace (Nothing updated)
save "${path}/CNT/ZMB/ZMB_2011_EGRA/ZMB_2011_EGRA_v01_M_v01_A_HAD.dta", replace

