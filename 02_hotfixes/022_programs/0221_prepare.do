*==============================================================================*
* Harmonized Learning Outcome (HLO)
* Project information at: https://github.com/worldbank/...

* 02_hotfixes
* EduAnalytics Team
* Authors: Justin Kleczka (jkleczka@worldbank.org)
* Date created: 2024-November-13

/* Description: 
This do-file compares the WLD_ALL_ALL_clo.dta that was created 
in the 01_data step with 'WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX', located in the network 
and prepares the replicated dataset for use in Step 3
*/

*==============================================================================*


* ========================================================== *
* Merging and Comparing the Original and Replicated datasets
* ========================================================== *

* Note: below is the same file as that in network folder "\\wbgfscifs01\GEDEDU\GDB\WorldBank_HLO_workingcopy\HLO\HLO_v01\1-cleaninput"
use "${clone}/02_hotfixes/021_rawdata/WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX.dta", clear
merge 1:1 cntabb test year subject grade using "${clone}/01_data/013_output/WLD_ALL_ALL_clo.dta"

* Note: our replicated database is representend by all the "_clo variables"

* Below is our so called "hotfix" to make our replicated database useable in Step 3
* This loop replaces any empty observations in our replicated database with the values from the original database
local variables = "score se score_m se_m score_f se_f n_f n_m n"
foreach var of local variables {
	replace `var'_clo = `var' if _merge == 1
	replace `var'_clo = `var' if _merge == 3 & `var'_clo != `var'
}

* Dropping the observations that are present in the replicated database and not the original database
* We do not need these extra observations for the task of replicating HLO 2020. We will, however, want to use them for future HLO updates 
drop if _merge == 2

* Saving the file that we can use to compare the two datasets
save "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_for_comparison.dta", replace 

*Preliminary comparison of the two datasets, looking for differences in the scores for those that were matched during the merge (i.e. _merge == 3)
compare score score_clo if _merge == 3

* ========================================================== *
* Preparing the Replicated Dataset for Step 3
* ========================================================== *

* We want to keep the replicated scores (with hotfixes) and reformat the dataset to look like the original dataset, so that it runs smoothly in Step 3
* To do this, we will want to drop the variables from the original dataset and rename the remaining "_clo" variables to the names from the original database
drop score se score_m se_m score_f se_f n_f n_m n surveyid code _merge
local variables = "score se score_m se_m score_f se_f n_f n_m n"
foreach var of local variables {
	rename `var'_clo `var'
}

* reordering the dataset to exactly match the original dataset
order cntabb test year n_res subject grade score se score_m se_m score_f se_f n_f n_m n
browse

* Saving the dataset for use in Step 3
save "${clone}/02_hotfixes/023_output/WLD_ALL_ALL_clo_final.dta", replace

*JK note to self: should we keep the merge indicator so we can know which observations were recreated and which were hotfixed?
