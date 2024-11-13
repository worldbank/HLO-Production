*==============================================================================*
* Harmonized Learning Outcome (HLO)
* Project information at: https://github.com/worldbank/...

* 01 MASTER
* EduAnalytics Team
* Authors: Felipe Puga Novillo (fpuganovillo@worldbank.org)
* Date created: 2024-November-11

/* Description: this do-file create globals and runs the do files that will
download the CLOs, and  */
*==============================================================================*

* =========================================== *
* Preamble
* =========================================== *

* Date created
global year		2024
global month 	11
global day 		11
global date		"${year}${month}${day}"

/*

Justin to edit this part

* Root folder
** Note: add your root directory below line 28
if c(username) == "wb607872" {
	global root "C:\Users\\`c(username)'\OneDrive - WBG\Documents\EduAnalytics\HLO" 
}

* Change directory 
cd "${root}" 

* Subfolders
global raw 		"${root}/01_rawdata"
global code 	"${root}/02_code"
global output 	"${root}/03_output"

*/


* =========================================== *
* Run the do files
* =========================================== *

* Download the CLOs
run "${clone}/01_data/012_programs/0121_dataquery.do"

* Prepare the dataset
run "${clone}/01_data/012_programs/0122_prepare.do"