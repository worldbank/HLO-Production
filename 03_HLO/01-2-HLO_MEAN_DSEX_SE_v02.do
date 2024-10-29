*Author: Syedah Aroob Iqbal

*This do file:
*1)	Calculates standard errors for HLOs in HLO_v01:

set seed 10051990
set sortseed 10051990


use "$clone\03_HLO\output\HLO_MEANS_DSEX_v01_2022_updated_P_L.dta", clear
gen d_index = exchangerate
merge m:1 assessment subject level using "$clone/02_exchangerate/output/exchange_rates_se.dta", 
replace exchangerate_se = 0 if missing(exchangerate_se)
gen d_index_se = exchangerate_se

ren score score_t
ren se se_t
ren HLO HLO_t
forvalues i = 1(1)1000 {
	gen d_index_`i' = d_index + d_index_se*rnormal()
	foreach g in t f m {
		gen score_`g'_`i' = score_`g' + se_`g'*rnormal()
		gen HLO_`g'_`i' = (score_`g'_`i')*(d_index_`i')
	}
}
foreach g in t f m {
	egen se_HLO_`g' = rowsd(HLO_`g'_*)
}
levelsof test, local(test_)
foreach a in score HLO  {
	foreach g in t f m {
		egen `a'_`g'_lower = rowpctile(`a'_`g'_*), p(2.5)
		egen `a'_`g'_upper = rowpctile(`a'_`g'_*), p(97.5)
		gen `a'_`g'_range = `a'_`g'_upper - `a'_`g'_lower
	}
}
gen os_share = (score_t_upper-score_t_lower)/(HLO_t_upper-HLO_t_lower)
tabstat os_share, by(test)
*Renaming standard errors to align with previous format:
ren (se_HLO_t se_HLO_f se_HLO_m) (HLO_t_se HLO_f_se HLO_m_se)
keep cntabb year test subject n_res grade 	///
	score_t se_t score_f se_f score_m se_m 	///
	HLO_t HLO_t_se HLO_f HLO_f_se HLO_m HLO_m_se	///
	n n_f n_m 	///
	d_index d_index_se	*lower *upper *range os_share 
save "$clone\03_HLO\temp\HLO_v01_SE_2022.dta", replace

ren (score_t se_t HLO_t HLO_t_se) (score se HLO HLO_se)
ren (score_t_lower score_t_upper score_t_range) (score_lower score_upper score_range)
ren (HLO_t_lower HLO_t_upper HLO_t_range) (HLO_lower HLO_upper HLO_range)

cf _all using "$clone\03_HLO\output\HLO_MEAN_DSEX_SE_v01_2022_P_L.dta", verbose
cf _all using "$clone\03_HLO\output\HLO_MEAN_DSEX_SE_v01_2022_L_P_Sun.dta", verbose
*isid cntabb year test grade subject
*merge 1:1 cntabb year test grade subject using "$clone\03_HLO\output\HLO_MEAN_DSEX_SE_v01_2022_L_P_Sun
save "$clone\03_HLO\output\HLO_MEAN_DSEX_SE_v01_2022.dta", replace


/*Checking
use "$clone\03_HLO\output\HLO_MEAN_DSEX_SE_v01_2022_P.dta", clear
*Checking with previous:
ren HLO* n_HLO*
merge 1:1 cntabb test year n_res subject grade using "N:\GDB\WorldBank_HLO_workingcopy\HLO\HLO_v01\2-output\HLO_MEAN_DSEX_SE_v01.dta", keep(match)
gen diff = n_HLO - HLO
gen diff_se = n_HLO_se - HLO_se
encode test, gen(test_n)
encode subject, gen(subject_n)
mean diff, over(test_n)
mean diff if test == "LLECE", over(test_n subject_n)
mean diff_se, over(test_n)




