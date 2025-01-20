*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 022_run
* Authors: EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 2024-November-13

/* Description: Runs the .do file needed to execute Step 2 of the Repo */
*==============================================================================*


* =========================================== *
* Run the do file
* =========================================== *
do "${clone}/02b_exchange_rates/022b_programs/0222b_exchange_rates_values.do"
do "${clone}/02b_exchange_rates/022b_programs/0222b_exchange_rates_se.do"
*-----------------------------------------------------------------------------

