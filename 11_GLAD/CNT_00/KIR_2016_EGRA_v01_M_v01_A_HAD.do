
set seed 10051990
set sortseed 10051990


*Kiribati:
use "${path}/CNT/KIR/KIR_2016_EGRA/KIR_2016_EGRA_v01_M/Data/Stata/2016.dta", clear
encode district, gen(district_n)
drop district
ren district_n district
gen country = "Kiribati"
gen language = "Kiribati"
ren (letter_sound_per_minute letter_per_minute fam_word_per_minute inv_word_per_minute orf_per_minute readcomp_pct letter_zero pa_zero letter_sound_zero fam_word_zero inv_word_zero readcomp_zero listcomp_zero dict_zero weight) (clspm clpm cwpm cnonwpm orf read_comp_score_pct letter_score_zero pa_init_sound_zero letter_sound_score_zero fam_word_score_zero inv_word_score_zero read_comp_score_zero list_comp_score_zero dict_score_zero wt_final)
ren schoolcode school_code
encode school_code, gen(school_code_n)
drop school_code
ren school_code_n school_code
ren item2 tppri
*There is no oral_read_score_zero. Generating:
gen oral_read_score_zero = 1 if orf_correct == 0
replace oral_read_score_zero = 0 if missing(oral_read_score_zero)
*There is no oral_read_score_pcnt. Generating:
egen oral_read_score_pcnt_1 = rowtotal(oral_read?)
egen oral_read_score_pcnt_2 = rowtotal(oral_read??)
egen oral_read_score_pcnt = rowtotal(oral_read_score_pcnt_?)
replace oral_read_score_pcnt = oral_read_score_pcnt/60
drop oral_read_score_pcnt_*
ren read_comp_score_pct read_comp_score_pcnt
svyset school_code [pweight = wt_final], fpc(fpc1) singleunit(scaled)
keep country year month date district island school_code fpc* id grade female age start_time end_time  language consent clspm clpm cwpm cnonwpm orf read_comp_score_pcnt read_comp_score_zero letter_score_zero pa_init_sound_zero letter_sound_score_zero fam_word_score_zero inv_word_score_zero list_comp_score_zero dict_score_zero oral_read_score_zero wt_final tppri oral_read_score_pcnt
replace oral_read_score_pcnt = oral_read_score_pcnt*100
gen n_res = 1
gen r_res = 0
gen w = 1
label define lyn 0 "no" 1 "Yes"
replace consent = "0" if consent == "no"
replace consent = "1" if consent == "yes"
destring consent, replace
label values consent lyn
bysort id: gen id_n = _n
drop id
ren id_n id
gen s_res = 1
gen lang_instr = "Kiribati"
replace country = "Kiribati"
gen cntabb = "KIR"
gen idcntry = 296
*Standardizing survey variables:
gen su1 = school_code
cf _all using "${path}\CNT\KIR\KIR_2016_EGRA\KIR_2016_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\KIR\KIR_2016_EGRA\KIR_2016_EGRA_v01_M_v01_A_HAD.dta", replace

