version 16
*==============================================================================*
* HLO
* Project information at: https://github.com/worldbank/
*
* TASK 02_Hotfixes: fills in observations that we couldn't replicated with data from the original WLD_ALL network file
*==============================================================================*



*-------------------------------------------------------------------------------
* Setup for this task
*-------------------------------------------------------------------------------
* Check that project profile was loaded, otherwise stops code
cap assert ${HLO_profile_is_loaded} == 1
if _rc != 0 {
  noi disp as error "Please execute the profile_HLO_production initialization do in the root of this project and try again."
  exit
}

*-------------------------------------------------------------------------------
* Execution parameters
global master_seed  17893   // Ensures reproducibility


*-------------------------------------------------------------------------------
* Subroutines for this task
*-------------------------------------------------------------------------------

do "${clone}/02_hotfixes/022_programs/0221_prepare.do"



*-----------------------------------------------------------------------------

