*Cleaning of mean files for publication:

use "N:\GDB\WorldBank_HLO_workingcopy\HLO\HLO_v01\1-cleaninput\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta", clear
replace subject = "math" if cntabb == "LKA" & test == "National Assessment"
replace n_res = 1 if cntabb == "LKA" & test == "National Assessment"
replace score = 400 if cntabb == "LKA" & test == "National Assessment" & year == 2009
*China PISA - non-nationally representative
replace n_res = 0 if cntabb == "CHN" & test == "PISA"
*Venezuela - 2009 PISA - non-nationally representative
replace n_res = 0 if cntabb == "VEN" & test == "PISA" & year == 2009
*Ethiopia - 2010 EGRA - non-nationally representative
replace n_res = 0 if cntabb == "ETH" & test == "EGRA" & year == 2010
*Dropping unnecessary observations:
drop if grade == "2" & test == "PASEC_2014"
*n_res = 0 for El Salvador - 2018 EGRA data.
replace n_res = 0 if cntabb == "SLV" & test == "EGRA" & year == 2018
*Filling in missing for nationally representative
replace n_res = 1 if missing(n_res)
drop if test == "MLA"
save "N:\GDB\WorldBank_HLO_workingcopy\HLO\HLO_v01\2-output\WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta"

