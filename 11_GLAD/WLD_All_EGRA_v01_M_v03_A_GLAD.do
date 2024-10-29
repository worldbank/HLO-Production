*Compile and scale all EGRAs for HLO 2022

use "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production2\MHC-HLO-Production\11_GLAD/113_outputs/RWA/RWA_2018_EGRA/RWA_2018_EGRA_v01_M_wrk_A_GLAD_ALL.dta", clear 
local mean_EGRA_v01 = 29.36718
local std_EGRA_v01 = 34.96901 
drop if idgrade < 2 
drop if idgrade > 4 & !missing(idgrade)
drop if missing(score_egra_read)
*The harmonized learning outcomes database only uses grades 2-4:
gen read_comp_scaled = [(score_egra_read - `mean_EGRA_v01')/`std_EGRA_v01'] * 100 + 500
save "$clone\113_outputs\WLD_All_EGRA_v01_M_v03_A_GLAD.dta", replace
