
set seed 10051990
set sortseed 10051990


* Tuvalu

use "${path}/CNT/TUV\TUV_2014_EGRA\TUV_2014_EGRA_v01_M\Data\Stata\2014.dta", clear
*Data is not svyset.
*Constructing variables of interest:
ren (orf_per_minute schoolcode)  (orf school_code)
egen oral_read_score1 = rowtotal(oral_read?)
egen oral_read_score2 = rowtotal(oral_read??)
egen oral_read_score = rowtotal(oral_read_score?)
gen orf_check = oral_read_score/((60-oral_read_time_remain)/60)
assert orf == orf_check
drop orf_check
gen oral_read_score_pcnt = (oral_read_score/54)*100
gen oral_read_score_zero = (oral_read_score == 0)
foreach var of varlist read_comp2 read_comp3 read_comp4 read_comp5 {
	replace `var' = "0" if `var' == "3" | `var' == "notAsked"
	destring `var', replace
}
egen read_comp_score = rowtotal(read_comp?)
gen read_comp_score_pcnt = (read_comp_score/5)*100
gen read_comp_score_zero = (read_comp_score == 0)
keep year school_code region id grade age female orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
gen w = 0
gen n_res = 1
gen r_res = 1
gen s_res = 1
gen language = "Tuvaluan"
gen lang_instr = "Tuvaluan"
gen country = "Tuvalu"
gen cntabb = "TUV"
gen idcntry = 798
encode id, gen(id_n)
drop id
ren id_n id
codebook, compact
cf _all using "${path}\CNT\TUV\TUV_2014_EGRA\TUV_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\TUV\TUV_2014_EGRA\TUV_2014_EGRA_v01_M_v01_A_HAD.dta", replace

