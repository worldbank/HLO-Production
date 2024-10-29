** Honduras
set seed 10051990
set sortseed 10051990

use "${path}\CNT\HND\HND_2008_EGRA\HND_2008_EGRA_v01_M\Data\Stata\2008.dta", clear

*svyset variable not found.
gen w = 0
gen n_res = 1
gen r_res = 0
gen lang_instr = "Spanish"
ren exit_interview12 tppri
recode i_soc_ec (0/1 = 1 "Poorest Quintile") (2/3 = 2 "Q2") (4/5 = 3 "Q3") (6/7 = 4 "Q4") (8/9 = 5 "Q5"), gen(tses0) 
keep country year id grade female age language orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tses0 n_res r_res w tppri lang_instr exit_interview17a exit_interview17b exit_interview17c exit_interview17e exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17
replace read_comp_score_pcnt = read_comp_score_pcnt*100
decode language, gen(language_s)
drop language
ren language_s language
gen comments = "Averages slightly different (1-2 points) as the school_code variables need to produce weighted estimates is not available"
gen idcntry = 340
gen cntabb = "HND"
gen n = _n

*Variables for socio-economic status:
foreach var of varlist exit_interview17a exit_interview17b exit_interview17c exit_interview17e exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17 {
	tab `var'
}
mdesc exit_interview17a exit_interview17b exit_interview17c exit_interview17e exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17
*Filling in missings:
foreach var of varlist exit_interview17a exit_interview17b exit_interview17c exit_interview17e exit_interview17g exit_interview17h exit_interview17i exit_interview17j exit_interview17 {
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview17a_std exit_interview17b_std exit_interview17c_std exit_interview17e_std exit_interview17g_std exit_interview17h_std exit_interview17i_std exit_interview17j_std exit_interview17_std 
pca exit_interview17a_std exit_interview17b_std exit_interview17c_std exit_interview17e_std exit_interview17g_std exit_interview17h_std exit_interview17i_std exit_interview17j_std exit_interview17_std
predict ESCS

*Generating Asset variables:
gen books_yn = exit_interview17a
gen electricity_yn = exit_interview17b
gen tap_in_home_compound_yn = exit_interview17c
gen gas_electric_stove_yn = exit_interview17e
gen telephone_yn = exit_interview17g
gen television_yn = exit_interview17h
gen radio_yn = exit_interview17i
gen fridge_yn = exit_interview17j
gen vehicle_yn = exit_interview17




save "${path}\CNT\HND\HND_2008_EGRA\HND_2008_EGRA_v01_M_v01_A_BASE\HND_2008_EGRA_v01_M_v01_A_BASE.dta", replace

keep country cntabb idcntry n year id grade female age language orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero tses0 n_res r_res w tppri lang_instr *_yn

codebook, compact
cf _all using "${path}\CNT\HND\HND_2008_EGRA\HND_2008_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\HND\HND_2008_EGRA\HND_2008_EGRA_v01_M_v01_A_HAD.dta", replace

