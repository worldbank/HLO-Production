*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 0323_HLO_MEAN_DSEX_SE_v01
* Authors: Most of the code is from Aroob's HLO_v01 folder on the WBG Network, with some minor syntax changes by Justin (EduAnalytics team)
* Date created: 2024-November-13

/* Description: This do file calculates standard errors for HLOs in HLO_v01: */

*==============================================================================*

set seed 10051990
set sortseed 10051990


use "${clone}/03_harmonization/033_output/HLO_MEANS_DSEX_v01.dta", clear

*Only generating standard errors for the data points added since last database:
merge 1:1 cntabb test year n_res subject grade using "${clone}/03_harmonization/031_rawdata/Metadata_HLO_se.dta", assert(master match) keep(master) keepusing(cntabb) nogen

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
save "${clone}/03_harmonization/temp/HLO_v01_SE.dta", replace

ren (score_t se_t HLO_t HLO_t_se) (score se HLO HLO_se)
ren (score_t_lower score_t_upper score_t_range) (score_lower score_upper score_range)
ren (HLO_t_lower HLO_t_upper HLO_t_range) (HLO_lower HLO_upper HLO_range)

append using "${clone}/03_harmonization/031_rawdata/Metadata_HLO_se.dta"

*Cleaning version
*We do not have a complete list of country names available
drop country

*Correcting missing d_index_se
bysort test: egen mean_d_index_se = mean(d_index_se) if test == "EGRA"
replace d_index_se = mean_d_index_se if test == "EGRA" & missing(d_index_se)
drop mean_d_index_se
drop score_se_check

*Filling in gaps:
*Sri Lank National Assessment:
replace subject = "math" if cntabb == "LKA" & test == "National Assessment"
replace n_res = 1 if cntabb == "LKA" & test == "National Assessment"
replace score = HLO if cntabb == "LKA" & test == "National Assessment"
*China PISA - non-nationally representative
replace n_res = 0 if cntabb == "CHN" & test == "PISA"
*Venezuela - 2009 PISA - non-nationally representative
replace n_res = 0 if cntabb == "VEN" & test == "PISA" & year == 2009
*Ethiopia - 2010 EGRA - non-nationally representative
replace n_res = 0 if cntabb == "ETH" & test == "EGRA" & year == 2010
*Dropping unnecessary observations:
drop if grade == "2" & test == "PASEC_2014"
*Filling in missing for nationally representative
replace n_res = 1 if missing(n_res)
*cf _all using "${path}\2-output\HLO_MEAN_DSEX_SE_v01.dta", verbose
replace test = "TIMSS-equivalent NAS" if cntabb == "UZB"
save "${clone}/03_harmonization/033_output/HLO_MEAN_DSEX_SE_v01.dta", replace


