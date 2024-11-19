*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 032_run
* Authors: EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 2024-November-13

/* Description: Run the .do files that execute Step 3 of the Repo */

/*This do file:
1) Runs the do file in sequence to procure the HLO database v1.0

*Raw Input files used:
-	HLO Metadatabase version 0 - Metadata_HLO_se
-	A combined file of all original means (overall and by gender) - WLD_ALL_ALL_v01_M_v01_A_MEAN_DSEX
-	File with doubloon indices - All_d_index

Steps:
1) Develop exchange rate and standard error for exchange rate for the new assessment introduced in HLO version 2 - PILNA
2) Harmonize country-level means to HLO units 
3) Develop standard errors for HLO
*/
*==============================================================================*


* Execution parameters
global master_seed  17893   // Ensures reproducibility

*Step 1: 
do "${clone}/03_harmonization/032_programs/0321_pilna_exchange_rate.do"
*Step 2: 
do "${clone}/03_harmonization/032_programs/0322_HLO_MEAN_DSEX_v01.do"
*Step 3:
do "${clone}/03_harmonization/032_programs/0323_HLO_MEAN_DSEX_SE_v01.do"

