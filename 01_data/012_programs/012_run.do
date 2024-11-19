*==============================================================================*
* Harmonized Learning Outcomes (HLO)
* Project information at: https://github.com/worldbank/HLO-production

* Step: 012_run
* Authors: Felipe Puga Novillo (fpuganovillo@worldbank.org), EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]
* Date created: 2024-November-11

/* Description: this do-file create globals and runs the do files that will
execute Step 1 of the Repo */
*==============================================================================*

* =========================================== *
* Preamble
* =========================================== *

* Date created
global year		2024
global month 	11
global day 		11
global date		"${year}${month}${day}"


* =========================================== *
* Run the do files
* =========================================== *

* Download the CLOs
run "${clone}/01_data/012_programs/0121_dataquery.do"

* Prepare the dataset
run "${clone}/01_data/012_programs/0122_prepare.do"