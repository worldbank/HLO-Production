** Gambia

set seed 10051990
set sortseed 10051990


use "${path}\CNT\GMB\GMB_2011_EGRA\GMB_2011_EGRA_v01_M\Data\Stata\2011.dta", clear
*Data is svyset:
ren strat1 strata1
ren strat2 strata2
svyset school_code [pweight = wt_final], fpc(fpc1) strata(strata1) vce(linearized) || id, fpc(fpc2) strata(strata2) singleunit(scaled)
gen w = 1
gen n_res = 1
gen r_res = 1 
gen s_res = 1
keep country year region strat* fpc* school_code school_type id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero w wt_final fpc1 fpc2 strata1 strata2  w *_res exit_interview26 exit_interview27 exit_interview28 exit_interview29 exit_interview30 exit_interview31 exit_interview32 exit_interview33 exit_interview34 exit_interview35 exit_interview36 exit_interview37 exit_interview38 exit_interview39
foreach var of varlist *_pcnt {
	replace `var' = `var'*100
}
decode language, gen(language_s)
drop language
ren language_s language
decode region, gen(region_s)
drop region
ren region_s region
gen lang_instr = "English"
decode school_type, gen(school_type_s)
drop school_type
ren school_type_s school_type

*Idenitfying variables for ESCS:
*Removing exit_interview27: Data does not look clear.
*exit_interview26 exit_interview28 exit_interview29 exit_interview30 exit_interview31 exit_interview32 exit_interview33 exit_interview34 exit_interview35 exit_interview36 exit_interview37 exit_interview38 exit_interview39
foreach var of varlist exit_interview26  exit_interview28 exit_interview29 exit_interview30 exit_interview31 exit_interview32 exit_interview33 exit_interview34 exit_interview35 exit_interview36 exit_interview37 exit_interview38 exit_interview39 {
	tab `var'
	*Missing are given by 2,9,27 and 6
	replace `var' = . if inlist(`var',2,9,27,6)
}
mdesc exit_interview26  exit_interview28 exit_interview29 exit_interview30 exit_interview31 exit_interview32 exit_interview33 exit_interview34 exit_interview35 exit_interview36 exit_interview37 exit_interview38 exit_interview39
*Filling in missing values:
foreach var of varlist exit_interview26 exit_interview28 exit_interview29 exit_interview30 exit_interview31 exit_interview32 exit_interview33 exit_interview34 exit_interview35 exit_interview36 exit_interview37 exit_interview38 exit_interview39 {
	bysort region school_code: egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	bysort region : egen `var'_mean_reg = mean(`var')
	bysort region : egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}
alphawgt exit_interview26_std exit_interview28_std exit_interview29_std exit_interview30_std exit_interview31_std exit_interview32_std exit_interview33_std exit_interview34_std exit_interview35_std exit_interview36_std exit_interview37_std exit_interview38_std exit_interview39_std [weight = wt_final], detail item std
pca exit_interview26_std exit_interview28_std exit_interview29_std exit_interview30_std exit_interview31_std exit_interview32_std exit_interview33_std exit_interview34_std exit_interview35_std exit_interview36_std exit_interview37_std exit_interview38_std exit_interview39_std [weight = wt_final]
predict ESCS
gen electricity_yn = exit_interview26
gen fridge_yn = exit_interview28
gen television_yn = exit_interview29
gen video_dvd_player_yn = exit_interview30
gen radio_yn = exit_interview31
gen gas_electric_stove_yn = exit_interview32
gen bicycle_yn = exit_interview33
gen motorcycle_yn = exit_interview34
gen four_wheeler_yn = exit_interview35
gen tap_in_home_compound = exit_interview36
gen toilet_yn = exit_interview37
gen mobile_yn = exit_interview38
gen telephone_yn = exit_interview39

keep country year region strat* fpc* school_code school_type id grade female age language orf oral_read_score_pcnt oral_read_score_zero read_comp_score_pcnt read_comp_score_zero w wt_final fpc1 fpc2 strata1 strata2  w *_res *_yn

gen cntabb = "GMB"
gen idcntry = 270

codebook, compact
cf _all using "${path}/CNT/GMB/GMB_2011_EGRA/GMB_2011_EGRA_v01_M_v01_A_HAD.dta", verbose
save  "${path}/CNT/GMB/GMB_2011_EGRA/GMB_2011_EGRA_v01_M_v01_A_HAD.dta", replace

/*
gen n = _n
gen cntabb = "GMB"
gen idcntry = 270

save "${gsdData}/0-RawOutput/merged/Gambia.dta", replace
