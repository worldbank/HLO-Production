*==============================================================================*
* Measuring Human Capital - Harmonized Learning Outcomes
* Project information at: https://github.com/worldbank/MHC-HLO-Production
*
* This initialization do sets paths, globals and install programs for Repo
*==============================================================================*



  *-----------------------------------------------------------------------------
  * General program setup
  *-----------------------------------------------------------------------------
  clear               all
  capture log         close _all
  set more            off
  set varabbrev       off, permanently
  set maxvar          120000, permanently
  version             14
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Define network path
  *-----------------------------------------------------------------------------
  * Network drive is always the same for everyone, but may not be available
  global network 	"//wbgfscifs01/GEDEDU/"
  cap cd "${network}"
  if _rc == 170   global network_is_available 1
  else            global network_is_available 0
  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Define user-dependant global paths
  *-----------------------------------------------------------------------------
  * User-dependant paths for local repo clone and 11_GLAD folder within the repo
  * Aroob
  if inlist("`c(username)'","wb504672","WB504672") {
    global clone "N:\GDB\Personal\WB504672\WorldBank_Github\MHC-HLO-Production\"
  }



  /* WELCOME!!! ARE YOU NEW TO THIS CODE?
     Add yourself by copying the lines above, making sure to adapt your clone */
  else {
    noi disp as error _newline "{phang}Your username [`c(username)'] could not be matched with any profile. Please update profile_MHC-HLO-Production do-file accordingly and try again.{p_end}"
    error 2222
  }

  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
  local user_commands fs pv seq mdesc alphawgt touch polychoric eststo

  * Loop over all the commands to test if they are already installed, if not, then install
  foreach command of local user_commands {
    cap which `command'
    if _rc == 111 {
      * Polychoric is not in SSC so is checked separately
      if "`command'" == "polychoric" net install polychoric, from("http://staskolenikov.net/stata")
	  if "`command'" == "eststo" net install eststo, from("http://www.stata-journal.com/software/sj14-2/")
      *All other commands installed through SSC
      else  ssc install `command'
    }
  }


  *-----------------------------------------------------------------------------
  * Flag that profile was successfully loaded
  *-----------------------------------------------------------------------------
  global profile_is_loaded = 1
  noi disp as res _newline "{phang} Profile sucessfully loaded.{p_end}"
  *-----------------------------------------------------------------------------

  *-------------------------------------------------------------------------------
* Setup for this task
*-------------------------------------------------------------------------------
* Check that project profile was loaded, otherwise stops code
cap assert ${profile_is_loaded} == 1
if _rc != 0 {
  noi disp as error "Please execute the profile_MHC-HLO-Production initialization do in the root of this project and try again."
  exit
}

* Execution parameters
global master_seed  10051990
set seed 10051990 
set sortseed 10051990   // Ensures reproducibility
global from_datalibweb = 0   // If 1, uses datalibweb, if not 1, it takes raw .dtas in $network_HLO_DB
global overwrite_files = 0   // If 1, it always creates each GLAD.dta file, even if it already exists, and overwrites any old file
global shortcut = "${shortcut_GLAD}"  // NEVER COMMIT ANY CHANGES IN THIS LINE

* Global paths that may serve as input and output for the overall task
global input  "${network}/GDB/HLO_Database" // Where EDURAW files will be read from if datalibweb==0
global output "${clone}/outputs"  // Where GLAD.dta files will be saved

*Creating folder structure:
foreach folder in 02_exchangerate 03_HLO 04_HLO-HCI 05_MHC {
	cd $clone/`folder'
	capture quietly: mkdir temp
	capture quietly: mkdir output
}


