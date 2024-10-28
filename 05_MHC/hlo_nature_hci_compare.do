/* =====================================================================================================

Title: HLO Nature scores and HCI 2018 Comparison

Overall Results: Scores and Ranks robust with correlations of .97 or greater

Sources of Difference:

[ ]	Linear & Regression Method vs Ratio Linking Method 
[ ] Aggregated vs Disaggregated  
[ ] Paramater choices (e.g., only use math scores for PASEC countries for Nature HLO)

Inputs:

[ ]	hlo_disag -- Nature HLO metadata
[ ]	hci_final -- 2018 World Bank HCI data

* =====================================================================================================*/
	
	*------ set up
	
	clear matrix
	set mem 1000m
	set matsize 10000
	set more off
	global path = "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production\05_MHC\051_input"

	*------ merging datasets

	use "$path/hlo_disag.dta", replace // Nature HLO data

	* aggregate HLO disaggregated scores from Nature paper using the approximate HCI aggregation procedure for comparison
	
	// average across subjects and levels as per HCI procedure
	collapse hlo, by(year code)
	
	// keep latest score
	gsort code -year
	bys code: gen n = _n
	keep if n == 1 
	
	* merge with 2018 HCI scores, 157 matches since 157 countries included in HCI
	
	rename code wbcode
	merge 1:1 wbcode using "$path/hci_final.dta"
	keep if _merge ==3
	keep wbcode year hlo countryname region incomegroup harmonizedtestscores
	replace hlo = round(hlo, 1)
	
	*------ comparisons

	** correlations and figures of scores and ranks
	** PASEC countries vary the most since omitted math scores due to less reliable linking function

	corr harmonizedtestscores hlo // .97
	local corr: di %4.3f r(rho) 
	scatter harmonizedtestscores hlo, mlabel(wbcode) xtitle("New HLO Score") ytitle("Old HCI HLO Score") ///
	subtitle("Correlation `corr'", position(4) ring(0) margin(small) size(small) box fcolor(white))
		
	egen rank_hci = rank(harmonizedtestscores)
	egen rank_new_hlo = rank(hlo)
	
	corr rank_hci rank_new_hlo // .97
	local corr: di %4.3f r(rho) 
	scatter rank_hci rank_new_hlo, mlabel(wbcode) xtitle("New HLO Rank") ytitle("Old HCI HLO Rank") ///
	subtitle("Correlation `corr'", position(4) ring(0) margin(small) size(small) box fcolor(white))
		
	// without PASEC countries
	
	drop if wbcode == "BDI" | wbcode == "COM" | wbcode == "TGO" | wbcode == "SEN" | wbcode == "BFA" ///
	| wbcode == "BEN" | wbcode == "COD" | wbcode == "MLI" | wbcode == "GIN" | wbcode == "NER"  
	
	corr rank_hci rank_new_hlo // .984
	local corr: di %4.3f r(rho) 
	scatter rank_hci rank_new_hlo, mlabel(wbcode) xtitle("New HLO Rank") ytitle("Old HCI HLO Rank") ///
	subtitle("Correlation `corr'", position(4) ring(0) margin(small) size(small) box fcolor(white))
		
	