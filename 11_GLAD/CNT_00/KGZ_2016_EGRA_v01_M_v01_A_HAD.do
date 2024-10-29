//2016
set seed 10051990
set sortseed 10051990

use "${path}\CNT\KGZ\KGZ_2016_EGRA\KGZ_2016_EGRA_v01_M\Data\Stata\2016.dta", clear
*Data is weighted:
gen w = 1
ren (treat masked_SchoolID masked_StudentID rp_permin rpc_score q1 q6) (strata1 school_code id orf read_comp_score_pcnt lang_instr tbook)
svyset school_code [pweight = wt_final], strata(strata1) vce(linearized) 
replace language = "Kyrgyz" if language == "K"
replace language = "Russian" if language == "R"
gen year = 2016
gen r_res = 1
gen n_res = 0
gen s_res = 1
gen female = 1 if gender == "G"
replace female = 0 if gender == "B"
decode tbook, gen(tbook_s)
drop tbook
ren tbook_s tbook
*Variables of interest:
gen oral_read_score_zero = (rp_correct == 0)
gen oral_read_score_pcnt = (rp_correct/41)*100 if grade == 2 & language == "Kyrgyz"
replace oral_read_score_pcnt = (rp_correct/48)*100 if grade == 2 & language == "Russian"
replace oral_read_score_pcnt = (rp_correct/80)*100 if grade == 4 & language == "Kyrgyz"
replace oral_read_score_pcnt = (rp_correct/93)*100 if grade == 4 & language == "Russian"
egen read_comp_score = rowtotal(rpc?)
gen read_comp_score_zero = (read_comp_score == 0)
keep language country w year strata1 region school_code id female grade orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt year n_res w r_res s_res lang_instr tbook wt_final
drop language 
gen language = "Kyrgyz"
decode region, gen(region_s)
drop region 
ren region_s region
decode lang_instr, gen(lang_instr_s)
drop lang_instr
ren lang_instr_s lang_instr
drop year
gen year = 2016

replace country = "Kyrgyzstan"
gen cntabb = "KGZ"
gen idcntry = 417

codebook, compact
cf _all using "${path}\CNT\KGZ\KGZ_2016_EGRA\KGZ_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\KGZ\KGZ_2016_EGRA\KGZ_2016_EGRA_v01_M_v01_A_HAD.dta", replace

