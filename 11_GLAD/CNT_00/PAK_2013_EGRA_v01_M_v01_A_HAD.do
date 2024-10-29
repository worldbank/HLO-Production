*Pakistan
set seed 10051990
set sortseed 10051990

*Preparing for appending:
use "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\ICT_2013_2017.dta", clear
gen language_str = "Urdu"
drop language
ren language_str language
save "${path}\TEMP\TEMP_All_EGRA\ICT_2013_2017_forappend.dta", replace

use "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\PUN_2013.dta", clear
gen language_str = "Urdu"
drop language
ren language_str language
keep school_code_m id_str grade female language country year read_comp_score_pcnt
save "${path}\TEMP\TEMP_All_EGRA\PUN_2013_forappend.dta", replace

use "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\AJK_2013_2017.dta", clear
append using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\BAL_2013_2017.dta"
append using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\GB_2013_2017.dta"
append using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\KP_2013_2017.dta"
append using "${path}\TEMP\TEMP_All_EGRA\ICT_2013_2017_forappend.dta"
append using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\SND_2013_2017.dta"
append using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M\Data\Stata\SND_URD_2013_2017.dta"
append using "${path}\TEMP\TEMP_All_EGRA\PUN_2013_forappend.dta"
encode school_code_m, gen(school_code)


*Developing variables for ESCS:
*Identification  of variables:
*Possible variables:
numlabel, add
foreach var of varlist s_2 s_2_1 s_2_2 s_2_3 s_2_4 s_2_5 s_31 s_32 s_33 s_34 s_34_1 s_34_2 s_34_3 {
	tab `var'
}
*Selected variables:
foreach var of varlist s_2_2 s_2_3 s_2_4 s_31 s_32 s_33 s_34_1 s_34_2 s_34_3 {
	tab `var'
	replace `var' = . if inlist(`var',-8,999)
}
mdesc s_2_2 s_2_3 s_2_4 s_31 s_32 s_33 s_34_1 s_34_2 s_34_3
*The data is only available for one dataset: ICT_2013_2017

alphawgt s_2_2 s_2_3 s_2_4 s_31 s_32 s_33 s_34_1 s_34_2 s_34_3, item detail std // Very low aplha

/*
*Renaming variables:
gen newspapers_yn = s_2_2
gen books_yn = s_2_3
gen television_yn = s_31
gen radio_yn = s_32
gen computer_yn = s_33
gen bicycle_yn = s_34_1
gen motorcycle_yn = s_34_2
*/



keep school_code id grade female language country year read_comp_score_pcnt wt_final
gen lang_instr = language
gen n_res = 0 
gen r_res = 0
gen w = 1
gen cntabb = "PAK"
gen idcntry = 586

codebook, compact
cf _all using "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\PAK\PAK_2013_EGRA\PAK_2013_EGRA_v01_M_v01_A_HAD.dta", replace
