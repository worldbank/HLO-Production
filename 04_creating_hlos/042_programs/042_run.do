version 16
*==============================================================================*
* HLO
* Project information at: https://github.com/worldbank/
*
* TASK 04_creating_hlos:
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

do "${clone}/04_creating_hlos/042_programs/0421_hlo.do"
do "${clone}/04_creating_hlos/042_programs/0422_hlo_prep.do"



*-----------------------------------------------------------------------------

