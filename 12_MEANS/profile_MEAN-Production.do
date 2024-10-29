*==============================================================================*
* 
* Project information at: https://github.com/worldbank/MHC-HLO
*
* This initialization do sets paths, globals and install programs for calculating MEANS.
*==============================================================================*



  *-----------------------------------------------------------------------------
  * Define user-dependant global paths
  *-----------------------------------------------------------------------------
  * User-dependant paths for local repo clone and 11_GLAD folder within the repo
  * Aroob
  if inlist("`c(username)'","wb504672","WB504672") {
	global clone "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production2\MHC-HLO-Production\"
    global means "$clone\12_MEANS"
  }
    else if inlist("`c(username)'","Wb588482","Wb588482") {
    global clone "Y:\Personal\WB588482\MHC-HLO-Production"
    global means "$clone\12_MEANS"
  }
  *-------------------------------------------------------------------------------
* Setup for this task
*-------------------------------------------------------------------------------
* Check that project profile was loaded, otherwise stops code
cap assert ${GLAD_profile_is_loaded} == 1
if _rc != 0 {
  noi disp as error "Please execute the profile_GLAD initialization do in the root of this project and try again."
  exit
}


* Global paths that may serve as input and output for this task
global input  "${clone}\11_GLAD\113_outputs" // Where EDURAW files will be read from if datalibweb==0
global output "${means}\123_outputs"  // Where GLAD.dta files will be saved
global temp "${means}\temp"  // Where GLAD.dta files will be saved


