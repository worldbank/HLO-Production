* BURUNDI - BDI
set seed 10051990
set sortseed 10051990


// 2011
use "${path}/CNT/BDI/BDI_2011_EGRA/BDI_2011_EGRA_v01_M/Data/Stata/2011.dta", clear

*Data is svyset.

ren (IPROINCLU strate_base codecole FPC1 femme classe_eleve) (wt_final strata school_code fpc1 female grade)

svyset school_code [pweight = wt_final], fpc(fpc1) strata(strata) vce(linearized)

gen date2 = date(date, "DMY")
gen year = year(date2)

*Generating variables of interest:
foreach var of varlist read_comp* female{
	replace `var' = "1" if `var' == "Oui"
	replace `var' = "0" if `var' == "Non"
	destring `var', replace
}

egen read_comp_score_pcnt = rowtotal(read_comp*)
gen read_comp_score_zero = (read_comp_score_pcnt == 1)
replace read_comp_score_pcnt = (read_comp_score_pcnt/4)*100

*Generating index for socio-economic status:
*Indicators - Unsure of what the question for the indicators available in the dataset

gen n_res = 1 
gen r_res = 0
gen lang_instr = "French"
gen language = "French"
gen w = 1




save "${path}\CNT\BDI\BDI_2011_EGRA\BDI_2011_EGRA_v01_M_v01_A_BASE\BDI_2011_EGRA_v01_M_v01_A_BASE.dta" , replace
keep year age clpm year cwpm orf wt_final strata school_code grade fpc1 female read_comp_score_pcnt read_comp_score_zero n_res r_res lang_instr language w

gen country = "Burundi"
gen cntabb = "BDI"
gen idcntry = 108
gen n = _n
*Other variables difficult to find as variables are labelled in french
*Missing: 15 missing for female, 13 for cwpm and 34 for orf.

*Standardizing survey variables:
gen su1 = school_code
gen strata1 = strata
codebook, compact
cf _all using "${path}\CNT\BDI\BDI_2011_EGRA\BDI_2011_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\BDI\BDI_2011_EGRA\BDI_2011_EGRA_v01_M_v01_A_HAD.dta", replace
