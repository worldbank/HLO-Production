
set seed 10051990
set sortseed 10051990

use "${path}/CNT/MMR/MMR_2015_EGRA/MMR_2015_EGRA_v01_M/Data/Stata/2015.dta", clear

ren sq9presch tppri
*Renaming variables for consistency:
ren (schid studid eg0fmonth eg0fyear egfemale eggrade sq6lang strataid) (school_code id month year female grade lan_at_home strata) 
*Renaming survey set variables:
ren analysisweight wt_final
*Generating missing variables required for analysis:
gen read_comp_score_zero = (read_comp_score==0)
gen read_comp_score_pcnt = (read_comp_score/6)*100
gen oral_read_score_zero = (orf == 0)
egen oral_read_score = rowtotal(egst6aor*)
gen oral_read_score_pcnt = (oral_read_score/44)*100
recode wealthgr (0=1) (1 = 2) (2=3) (3=4) (4 = 5), gen(tses0)
keep strata school_code id month year female grade language lan_at_home tses0 wt_final orf oral_read_score_pcnt oral_read_score_zero read_comp_score_zero read_comp_score_pcnt
svyset school_code [pweight = wt_final], strata(strata) singleunit(scaled) vce(linearized)
gen n_res = 0
gen r_res = 0
gen w = 1
replace year = 2015 if missing(year)
gen lang_instr = "Myanmar"

gen country = "Myanmar"
gen cntabb = "MMR"
gen idcntry = 104
codebook, compact
cf _all using "${path}\CNT\MMR\MMR_2015_EGRA\MMR_2015_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\MMR\MMR_2015_EGRA\MMR_2015_EGRA_v01_M_v01_A_HAD.dta", replace
