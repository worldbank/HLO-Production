set seed 10051990
set sortseed 10051990

use "${path}\CNT\IDN\IDN_2012_EGRA\IDN_2012_EGRA_v01_M\Data\Stata\2012.dta", clear
*Data is svyset:
encode tangerine_id, gen(su1)
gen strata1 = strat1
svyset su1 [pweight = wt_final], fpc(fpc1) strata(strat1)  singleunit(scaled) vce(linearized)
keep country year su1 strata1 fpc1 school_code school_type urban id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero wt_final
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
gen w= 1
gen n_res = 0
gen r_res = 0
gen s_res = 1
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type
drop language
gen lang_instr = "Bhasa Indonesia"
gen language = "Bhasa Indonesia"

replace country = "Indonesia"
gen cntabb = "IDN"
gen idcntry = 360

codebook, compact
cf _all using "${path}\CNT\IDN\IDN_2012_EGRA\IDN_2012_EGRA_v01_M_v01_A_HAD"
save "${path}\CNT\IDN\IDN_2012_EGRA\IDN_2012_EGRA_v01_M_v01_A_HAD", replace
 
