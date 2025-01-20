*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 0221 - Prepare Hotfixes for data
* Authors: Justin Kleczka (jkleczka@worldbank.org), EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 

/* Description: 

*/
*==============================================================================*

use "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_final.dta", clear
*use "${clone}/02b_exchange_rates/021b_rawdata/Metadata_HLO_sd.dta", clear

*** Edits to WLD_ALL to match format of Metadata file
gen sd = se * sqrt(n)

*-----------
* Clean
* ----------

// drop grades
    drop if grade == "2" | grade == "3" 

// gen levels
	gen level = "pri" if inlist(grade,"2","2-4","3","4","5","6")
    replace level = "sec" if missing(level)

// duplicate check
	bys cntabb year subject level test: gen dup = cond(_N==1,0,_n)
	drop if dup ==2

//other
	drop dup
	replace sd = . if sd == 0
	replace year = 2014 if cntabb == "MDG" & test == "PASEC" & year == 2015 // recent MDG data
    replace test = "PASEC_2014" if test == "PASEC" & year == 2014
    replace year = 2014 if cntabb == "TGO" & test == "PASEC" & year == 2006	 // keep Togo for within PASEC conversion
    
save "${clone}/02b_exchange_rates/021b_rawdata/master.dta", replace

*-----------------------------------------
* Create indvidual datasets for each test
*-----------------------------------------

use "${clone}/02b_exchange_rates/021b_rawdata/master.dta", replace

	drop if n_res != 1 
	drop if test == "SACMEQ" & cntabb == "ZAF" // not nationally representative

	// keep exchange rate HCI tests (national)
    keep if inlist(test,"EGRA","LLECE","PASEC","PASEC_2014","PISA","SACMEQ","PIRLS","TIMSS", "MLA")
 
    foreach level in pri sec {
    foreach sub in reading math science {
    foreach var in PISA TIMSS LLECE SACMEQ EGRA PIRLS MLA PASEC PASEC_2014 {
    use "${clone}/02b_exchange_rates/021b_rawdata/master.dta", replace
	
	keep if test == "`var'" & subject == "`sub'" & level == "`level'"
    drop if score ==. 
    rename score `var'score
    rename se `var'se
    rename sd `var'sd 
    save "${clone}/02b_exchange_rates/021b_rawdata/individual_datasets/`var'_`sub'_`level'.dta", replace
    }
    }
    }

*-----------------------------------------
* Produce all possible exchange rates
*-----------------------------------------

    eststo clear

    foreach anchor in PISA SACMEQ LLECE EGRA MLA PASEC PASEC_2014 {
    foreach ref in TIMSS PIRLS SACMEQ PASEC { 
    foreach sub in math science reading { 
    foreach lev in pri sec { 
    cap use "${clone}/02b_exchange_rates/021b_rawdata/individual_datasets/`anchor'_`sub'_`lev'.dta", replace
    cap nearmrg cntabb using "${clone}/02b_exchange_rates/021b_rawdata/individual_datasets/`ref'_`sub'_`lev'.dta", nearvar(year) limit(4) roundup type(m:m) genmatch(linkyear)
    encode cntabb, gen(cnt_num)

    set seed 1122335588
    gen rand = runiform()
    egen rank = rank(rand)
    replace n = _N
    gen randselect = 1 if rank > n/2 // random set of countries and time intervals

    gen coef = .
    gen cons = .
    gen N = .
    gen R = .

    gen coef_c = .
    gen cons_c = .
    gen R_c = .   

    save "${clone}/02b_exchange_rates/021b_rawdata/doubloons/doubloons_`anchor'_`ref'_`sub'_`lev'", replace

    cap noisily eststo `anchor'_`ref'_`sub'_`lev': reg `ref'score `anchor'score // i.year i.cnt_num 
            
       cap replace coef = _b[`anchor'score]              // method 1 - regression
       cap replace cons = _b[_cons]                     // method 1 - regression
       cap replace R = e(r2)                           // method 1 - regression
       
     cap noisily eststo `anchor'_`ref'_`sub'_`lev'_c: reg `ref'score `anchor'score i.cnt_num
            
       cap  replace coef_c = _b[`anchor'score]              // method 1 - regression
       cap replace cons_c = _b[_cons]                     // method 1 - regression
       cap  replace R_c = e(r2)                           // method 1- regression
 
        cap    gen ratio_linking = `ref'score/`anchor'score      // method 2 - ratio
        cap    gen mean_linking = `ref'score-`anchor'score       // method 3 - mean
        cap    sum mean_linking ratio_linking coef cons  
        cap    gen linlink = `ref'score-(`ref'sd/`anchor'sd)*`anchor'score        // linear linking
        cap    gen sdlink = `ref'sd/`anchor'sd                                 // linear linking

        cap    gen ratio_linking_rand = `ref'score/`anchor'score                  if randselect ==1   // method 2 - ratio
        cap    gen mean_linking_rand = `ref'score-`anchor'score                   if randselect ==1   // method 3 - mean
        cap    gen linlink_rand = `ref'score-(`ref'sd/`anchor'sd)*`anchor'score   if randselect ==1      // method 4 - linear linking
        cap    gen sdlink_rand = `ref'sd/`anchor'sd                               if randselect ==1       // method 4 - linear linking

       cap     gen reftest = "`ref'"
       replace N = _N

    cap collapse mean_linking* ratio_linking* coef* cons* linlink* sdlink* N R, by(subject test reftest)
    save "${clone}/02b_exchange_rates/021b_rawdata/linked_datasets/link_`anchor'_`ref'_`sub'_`lev'", replace
    }
    }
    }
    }

*-----------------------------------------
* Merge exchange rates datasets -- need to convert RSAT-RSAT -- to RSAT-ISAT for linear
*-----------------------------------------

use "${clone}/02b_exchange_rates/021b_rawdata/linked_datasets/link_PISA_TIMSS_math_sec.dta", replace
    save "${clone}/02b_exchange_rates/021b_rawdata/master2.dta", replace

    foreach anchor in PISA SACMEQ LLECE PASEC EGRA MLA PASEC_2014 {
        foreach ref in TIMSS PIRLS SACMEQ PASEC {
        foreach sub in math reading science {
        foreach lev in sec pri {
    use "${clone}/02b_exchange_rates/021b_rawdata/master2.dta", replace
            cap append using "${clone}/02b_exchange_rates/021b_rawdata/linked_datasets/link_`anchor'_`ref'_`sub'_`lev'"
            save "${clone}/02b_exchange_rates/021b_rawdata/master2.dta", replace
        }
        }
        }
        }

    drop if mean_linking == 0 | mean_linking ==.
    collapse mean_linking ratio_linking coef coef_c cons cons_c linlink* sdlink* N R, by(subject test reftest)
    sort test subject

    * keep and generate final exchange rates
    drop if test == "EGRA" & (reftest == "SACMEQ" | reftest == "PASEC")
    drop if test == "MLA" & (reftest == "PIRLS" | reftest == "TIMSS")
    drop if test == "SACMEQ" & reftest == "PASEC"
    replace coef = . if test == "SACMEQ" | test == "PASEC" | test == "PASEC_2014" // | test == "MLA"
    replace cons = . if test == "SACMEQ" | test == "PASEC" | test == "PASEC_2014" // | test == "MLA"
    replace coef_c = . if test == "SACMEQ" | test == "PASEC" | test == "PASEC_2014" // | test == "MLA"
    replace cons_c = . if test == "SACMEQ" | test == "PASEC" | test == "PASEC_2014" // | test == "MLA"

    rename mean_linking mean
    rename ratio_linking ratio

    foreach var in ratio mean coef coef_c linlink linlink_rand sdlink sdlink_rand cons cons_c {
    gen `var'_i = .
    }

    ** mla/pasecs
    foreach var in ratio sdlink sdlink_rand coef coef_c {
    foreach subject in math reading {
    sum `var' if test == "SACMEQ" & subject == "`subject'"
        local `var'_`subject' = r(min)  
    cap   replace `var'_i = `var'*``var'_`subject'' if reftest == "SACMEQ" & subject == "`subject'"
    cap sum `var'_i if reftest == "SACMEQ" & test == "PASEC" & subject == "`subject'"
        cap local `var'_`subject' = r(min)  
        cap replace `var'_i = `var'*``var'_`subject'' if reftest == "PASEC" & subject == "`subject'"
    }
    }

    foreach var in mean linlink linlink_rand cons {
    foreach subject in math reading {
    sum `var' if test == "SACMEQ" & subject == "`subject'"
        local `var'_`subject' = r(min)  
        cap replace `var'_i = `var'+``var'_`subject'' if reftest == "SACMEQ" & subject == "`subject'"
    cap sum `var'_i if reftest == "SACMEQ" & test == "PASEC" & subject == "`subject'"
        cap local `var'_`subject' = r(min)  
        cap replace `var'_i = `var'+``var'_`subject'' if reftest == "PASEC" & subject == "`subject'"
    }
    }  

    foreach var in ratio mean coef coef_c linlink linlink_rand sdlink sdlink_rand cons cons_c {
    replace `var'_i = `var' if `var'_i == .
    }

    gen level = "pri"
    replace level = "sec" if test == "PISA"

    replace R = sqrt(R)
   // replace N = . if test == "MLA"
   // replace R = . if test == "MLA"

    keep test subject level reftest *_i *link* cons N R

save "${clone}/023b_output/xchange_new.dta", replace 



/* LEFTOVER CODE FROM NOAM'S ORIGINAL EXCHANGE RATE CODE



*-----------------------------------------
* Generate new HLO scores
*-----------------------------------------

use "${clone}/master.dta", replace
    replace year = 2006 if cntabb == "TGO" & test == "PASEC" & year == 2014  // keep Togo for within PASEC conversion
	merge m:m test level subject using "${clone}/xchange_new.dta"

** Generate core HLO for Nature paper, regression & linear methods

foreach var in score score_m score_f {
gen hlo_reg_`var' = cons+`var'*coef_i
gen hlo_lin_`var' = linlink_i+sdlink_i*`var'
}

foreach var in score score_m score_f {
gen HLO_new_`var' = hlo_reg_`var'
    replace HLO_new_`var' = hlo_lin_`var' if hlo_reg_`var' ==. & _merge == 3
    replace HLO_new_`var' = `var' if _merge == 1
}

local vars cntabb year grade test n_res subject country score se score_m se_m score_f se_f HLO HLO_se HLO_new_score HLO_new_score_m HLO_new_score_f
keep `vars'

rename HLO_new_score HLO_n 
rename HLO_new_score_m HLO_n_m
rename HLO_new_score_f HLO_n_f

//kdensity HLO_n
corr HLO HLO_n

gen level = "pri" if inlist(grade,"2","2-4","3","4","5","6")
    replace level = "sec" if missing(level)

save "${clone}/HLO_nature.dta", replace

*--------- Robustness Tests File

use "${clone}/master.dta", replace
    replace year = 2006 if cntabb == "TGO" & test == "PASEC" & year == 2014  // keep Togo for within PASEC conversion
	merge m:m test level subject test using "${clone}/xchange_new.dta"
	replace score = 456 if country == "China" // recent China score from SES adjustment
	replace score = 456 if country == "China" // recent China score from SES adjustment
	replace score = 456 if country == "China" // recent China score from SES adjustment
	drop if country == "Yemen" & test != "EGRA" // take EGRA Yemen score
	drop if country == "England" | country == "Scotland" | country == "Northern Ireland"
	replace test = "PASEC" if test == "PASEC_2014"
	replace grade = "4" if grade == "2-4"
	destring, replace
    drop if test == "NAEQ"
    drop if test == "MLA" // not included in HCI and not robust link
	
    replace test = "PISA" if test == "National Assessment" & level == "pri" // Sri Lanka PISA-linked test
    replace level = "sec" if cntabb == "LKA" // Sri Lanka linked test

	gen hlo_mean = score+mean_i
	gen hlo_ratio = score*ratio_i
	gen hlo_reg = cons_i+score*coef_i
	gen hlo_lin = linlink_i+sdlink_i*score

	sum sdlink_i if reftest == "PIRLS" & test == "SACMEQ" & subject == "reading"
			local sdlink_i_sacmeq_r = r(min)  
	sum linlink_i if reftest == "TIMSS" & test == "SACMEQ" & subject == "math"
			local linlink_i_sacmeq_r = r(min)  

	gen hlo_lin_rand = linlink_rand_i+sdlink_rand_i*score // random
	gen hlo_reg_fe = cons_c_i+score*coef_c_i // fixed effects

	keep cntabb year level test n_res sd subject country score se HLO_se reftest hlo*
	
save "${clone}/robustness.dta", replace
