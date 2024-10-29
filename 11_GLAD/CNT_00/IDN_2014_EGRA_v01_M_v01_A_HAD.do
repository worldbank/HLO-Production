** Indonesia
set seed 10051990
set sortseed 10051990


use "${path}/CNT/IDN/IDN_2014_EGRA/IDN_2014_EGRA_v01_M/Data/Stata/2014.dta", clear
*Data is svyset:
ren (wt_stage4 private) (wt_final school_type)
svyset stage1 [pweight = wt_final], fpc(fpc1) strata(strata1) || stage2, fpc(fpc2) strata(strata2) || stage4, fpc(fpc4) strata(strata4) singleunit(scaled) vce(linearized)
xtile tses0 = wealthindex [pweight = wt_final], nquantiles(5)
ren p_6 tppri
gen su1 = stage1
encode stage2, gen(su2)
encode stage4, gen(su3)

keep country strata* su* fpc* school_code region school_type year id female age grade i_orf i_oral_read_score_pcnt i_oral_read_score_zero i_read_comp_score_pcnt i_read_comp_score_zero same_lang_home_assess tppri tses0 wt_final
gen w= 1
gen n_res = 1
gen r_res = 1
gen s_res = 1
ren i_* *
decode region, gen(region_s)
drop region 
ren region_s region
destring school_code, replace
destring id, replace
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
gen lang_instr = "Bhasa Indonesia"
gen language = "Bhasa Indonesia"
*Identifying variables for ESCS:
replace country = "Indonesia"
gen cntabb = "IDN"
gen idcntry = 360

codebook, compact
cf _all using "${path}\CNT\IDN\IDN_2014_EGRA\IDN_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\IDN\IDN_2014_EGRA\IDN_2014_EGRA_v01_M_v01_A_HAD.dta", replace


