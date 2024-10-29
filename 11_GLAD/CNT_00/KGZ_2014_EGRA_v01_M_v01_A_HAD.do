** Kyrzg
set seed 10051990
set sortseed 10051990


*Preparing for appending:
use "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_rus_2.dta", clear
append using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_rus_4.dta"
ren (Grade Gender RPF1) (grade gender rpf1)
save "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_rus_2_4.dta", replace
use "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_kyr_1.dta", clear
append using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_kyr_2.dta"
append using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_kyr_4.dta"
drop language 
gen lang = "Kyrgyz"
append using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_rus_1.dta"
append using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M\Data\Stata\2014_rus_2_4.dta"
drop language
ren lang language
replace language = "Russian" if missing(language)
gen year = 2014
*Data is not svyset
gen r_res = 1
gen n_res = 0
gen w = 0
gen lang_instr = "Kyrgyz/Russian"
gen s_res = 1
*Variables of interest:
gen oral_read_score_zero = (rp == 0)
gen read_comp_score_zero = (rpq == 0)
ren (rpf1 rpp prpq) (orf oral_read_score_pcnt read_comp_score_pcnt)
ren gender female
keep language country female grade orf oral_read_score_zero oral_read_score_pcnt read_comp_score_zero read_comp_score_pcnt year n_res w r_res s_res lang_instr
drop country
drop language 
gen language = "Kyrgyz"
replace female = 0 if female == 1
replace female = 1 if female == 2
label drop gender

gen country = "Kyrgyzstan"
gen cntabb = "KGZ"
gen idcntry = 417

codebook, compact
cf _all using "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\KGZ\KGZ_2014_EGRA\KGZ_2014_EGRA_v01_M_v01_A_HAD.dta", replace



