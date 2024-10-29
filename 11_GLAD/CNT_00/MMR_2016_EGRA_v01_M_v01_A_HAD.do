
set seed 10051990
set sortseed 10051990

use "${path}/CNT/MMR/MMR_2016_EGRA/MMR_2016_EGRA_v01_M/Data/Stata/2016.dta", clear

gen tlang = 1 if (eglang == sq6lang)
*Renaming variables for consistency:
ren (school_ID student_ID sq9presch eglang eg10gd eg14gen eg0fyear) (school_code id tppri language grade female year)
*Generating missing variables required for analysis:
foreach var of varlist egst6aor* {
	replace `var' = 0 if `var' == 444 | `var' == 555
}
egen oral_read_score = rowtotal(egst6aor*)
gen oral_read_score_pcnt = (oral_read_score/44)*100
gen oral_read_score_zero = (oral_read_score == 0)
foreach var of varlist egst6brc* {
	replace `var' = 0 if `var' == 444 | `var' == 999
}
egen read_comp_score = rowtotal(egst6brc*)
gen read_comp_score_pcnt = (read_comp_score/6)*100
gen read_comp_score_zero = (read_comp_score == 0)
decode language, gen(lang_str)
drop language
ren lang_str language
keep school_code id year female grade language tlang oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt
gen n_res = 0
gen r_res = 0
gen w = 0
gen lang_instr = "Myanmar"

gen country = "Myanmar"
gen cntabb = "MMR"
gen idcntry = 104

codebook, compact
cf _all using "${path}\CNT\MMR\MMR_2016_EGRA\MMR_2016_EGRA_v01_M_v01_A_HAD"
save "${path}\CNT\MMR\MMR_2016_EGRA\MMR_2016_EGRA_v01_M_v01_A_HAD", replace
