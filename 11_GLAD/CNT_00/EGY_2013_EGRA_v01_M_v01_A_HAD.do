set seed 10051990
set sortseed 10051990





use "${path}\CNT\EGY\EGY_2013_EGRA\EGY_2013_EGRA_v01_M\Data\Stata\2013.dta", clear
*Extra variables required by Nadir not available
*Stratafied by region and gender
assert region == strata1
assert female == strata2
assert school_code == stage1
ren stage2 id
*Setting survey weights using the renamed variables:
svyset school_code [pweight = wt_final], fpc(fpc1)  strata(region) || id, fpc(fpc2) strata(female) singleunit(scaled)
keep country year region urban school_type school_code fpc* strata1 strata2 stage1 id grade female age clspm cnonwpm orf letter_sound_score letter_sound_score_pcnt letter_sound_score_zero letter_sound_attempted letter_sound_attempted_pcnt invent_word_score invent_word_score_pcnt invent_word_score_zero invent_word_attempted invent_word_attempted_pcnt oral_read_score_pcnt oral_read_score oral_read_score_zero oral_read_attempted oral_read_attempted_pcnt read_comp_score read_comp_score_pcnt read_comp_score_zero read_comp_attempted read_comp_attempted_pcnt list_comp_score list_comp_score_pcnt list_comp_score_zero list_comp_attempted list_comp_attempted_pcnt mazea_score mazea_score_pcnt mazea_score_zero mazea_attempted mazea_attempted_pcnt mazeb_score mazeb_score_pcnt mazeb_score_zero mazeb_attempted mazeb_attempted_pcnt wt_final
gen n_res = 1
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
gen language = "Arabic"
gen s_res = 1
gen lang_instr = "Arabic"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type

replace country = "Egypt"
gen cntabb = "EGY"
gen idcntry = 818
*Standardizing svyset variables:

gen su1 = school_code
gen su2 = id

codebook, compact
cf _all using "${path}\CNT\EGY\EGY_2013_EGRA\EGY_2013_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\EGY\EGY_2013_EGRA\EGY_2013_EGRA_v01_M_v01_A_HAD.dta", replace
