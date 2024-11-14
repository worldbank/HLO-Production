
*==============================================================================*
*! HLO
*! Project information at: https://github.com/worldbank/...
*! EduAnalytics Team, World Bank Group [eduanalytics@worldbank.org]

*! MASTER RUN: Executes all tasks sequentially
*==============================================================================*

* Check that project profile was loaded, otherwise stops code
cap assert ${HLO_profile_is_loaded} == 1
if _rc {
  noi disp as error "Please execute the profile initialization do in the root of this project and try again."
  exit 601
}

*-------------------------------------------------------------------------------
* Run all tasks in this project
*-------------------------------------------------------------------------------
* TASK 01: Replication data
do "${clone}/01_data/012_programs/012_run.do"

* TASK 02: Hotfixes
do "${clone}/02_hotfixes/022_programs/022_run.do"

* TASK 03: Harmonization
do "${clone}/03_harmonization/032_programs/032_run.do"

* TASK 04: Creating HLOS
do "${clone}/04_creating_hlos/042_programs/042_run.do"


*-------------------------------------------------------------------------------
