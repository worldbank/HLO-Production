* Tajikistan :

set seed 10051990
set sortseed 10051990

use "${path}/CNT/TJK/TJK_2014_EGRA/TJK_2014_EGRA_v01_M/Data/Stata/2014.dta", clear

ren (Q1 Q2 Q314 Q6) (lang_instr lan_at_home tppri tbook)
ren (Language Region District Grade) (language region district grade)
ren (Country masked_student_ID masked_school_ID) (country id school_code)
*Recoding variables:
gen urban = 0 if type == 1
replace urban = 1 if type == 2
recode Gender (1 = 0) (2= 1), gen(female)
*Variables needed for analysis:
ren (pov lnsp prpq fwsp ufwsp plcq pdict) (vocal_word_score_pcnt letter_score_pcnt read_comp_score_pcnt fam_word_score_pcnt invent_word_score_pcnt list_comp_score_pcnt dict_score_pcnt)
ren (LNF1 FWF1 UFWF1 RPF1) (clpm cwpm cnonwpm orf)
*Generating variables for analysis:
gen oral_read_score_zero = (rp == 0)
gen read_comp_score_zero = (rpq == 0)
gen fam_word_score_zero = (fws == 0)
gen invent_word_score_zero = (ufws == 0)
gen list_comp_score_zero = (lcq == 0)
gen dict_score_zero = (dict == 0)
gen year = 2014
gen n_res = 0
gen r_res = 0
gen w = 0
keep country year school_code id language lan_at_home tppri tbook urban grade female orf oral_read_score_zero read_comp_score_pcnt read_comp_score_zero
gen language_s = "Russian" if language == 3
replace language_s = "Tajik" if language == 2
drop language
ren language_s language
drop tbook

replace country = "Tajikistan"
gen cntabb = "TJK"
gen idcntry = 762

codebook, compact
cf _all using  "${path}\CNT\TJK\TJK_2014_EGRA\TJK_2014_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\TJK\TJK_2014_EGRA\TJK_2014_EGRA_v01_M_v01_A_HAD.dta", replace


