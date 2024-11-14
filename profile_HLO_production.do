*==============================================================================*
* Measuring Human Capital - Harmonized Learning Outcomes
* Project information at: https://github.com/worldbank/__
*
* This initialization do sets paths, globals and install programs for Repo
*==============================================================================*
* quietly {

  /*
  Steps in this do-file:
  1) General program setup
  2) Define user-dependant path for local clone repo
  3) Check if can access WB network path and WB datalibweb
  4) Download and install required user written ado's
  5) Flag that profile was successfully loaded
  */

  *-----------------------------------------------------------------------------
  * 1) General program setup
  *-----------------------------------------------------------------------------
  clear               all
  capture log         close _all
  set more            off
  set varabbrev       off, permanently
  set emptycells      drop
  set maxvar          32000
  set linesize        135
  version             15
  *-----------------------------------------------------------------------------

/*
  *-----------------------------------------------------------------------------
  * Define network path
  *-----------------------------------------------------------------------------
  * Network drive is always the same for everyone, but may not be available
  global network 	"//wbgfscifs01/GEDEDU/"
  cap cd "${network}"
  if _rc == 170   global network_is_available 1
  else            global network_is_available 0
  *-----------------------------------------------------------------------------
*/

  *-----------------------------------------------------------------------------
  * 2) Define user-dependant path for local clone repo
  *-----------------------------------------------------------------------------
  * Change here only if this repo is renamed
  local this_repo     "HLO-production"
  * Change here only if this master run do-file is renamed
  local this_run_do   "run_HLO_Production.do"

  * The remaining of this section is standard in EduAnalytics repos

  * One of two options can be used to "know" the clone path for a given user
  * A. the user had previously saved their GitHub location with -whereis-,
  *    so the clone is a subfolder with this Project Name in that location
  * B. through a window dialog box where the user manually selects a file

  * Method A - Github location stored in -whereis-
  *---------------------------------------------
  capture whereis github
  if _rc == 0 global clone "`r(github)'/`this_repo'"

  * Method B - clone selected manually
  *---------------------------------------------
  else {
    * Display an explanation plus warning to force the user to look at the dialog box
    noi disp as txt `"{phang}Your GitHub clone local could not be automatically identified by the command {it: whereis}, so you will be prompted to do it manually. To save time, you could install -whereis- with {it: ssc install whereis}, then store your GitHub location, for example {it: whereis github "C:/Users/AdaLovelace/GitHub"}.{p_end}"'
    noi disp as error _n `"{phang}Please use the dialog box to manually select the file `this_run_do' in your machine.{p_end}"'

    * Dialog box to select file manually
    capture window fopen path_and_run_do "Select the master do-file for this project (`this_run_do'), expected to be inside any path/`this_repo'/" "Do Files (*.do)|*.do|All Files (*.*)|*.*" do

    * If user clicked cancel without selecting a file or chose a file that is not a do, will run into error later
    if _rc == 0 {

      * Pretend user chose what was expected in terms of string lenght to parse
      local user_chosen_do   = substr("$path_and_run_do",   - strlen("`this_run_do'"),     strlen("`this_run_do'") )
      local user_chosen_path = substr("$path_and_run_do", 1 , strlen("$path_and_run_do") - strlen("`this_run_do'") - 1 )

      * Replace backward slash with forward slash to avoid possible troubles
      local user_chosen_path = subinstr("`user_chosen_path'", "\", "/", .)

      * Check if master do-file chosen by the user is master_run_do as expected
      * If yes, attributes the path chosen by user to the clone, if not, exit
      if "`user_chosen_do'" == "`this_run_do'"  global clone "`user_chosen_path'"
      else {
        noi disp as error _newline "{phang}You selected $path_and_run_do as the master do file. This does not match what was expected (any path/`this_repo'/`this_run_do'). Code aborted.{p_end}"
        error 2222
      }
    }
  }

  * Regardless of the method above, check clone
  *---------------------------------------------
  * Confirm that clone is indeed accessible by testing that master run is there
  cap confirm file "${clone}/`this_run_do'"
  if _rc != 0 {
    noi disp as error _n `"{phang}Having issues accessing your local clone of the `this_repo' repo. Please double check the clone location specified in the run do-file and try again.{p_end}"'
    error 2222
  }
  *-----------------------------------------------------------------------------

  *-----------------------------------------------------------------------------
  * 3) Check if can access WB network path and WB datalibweb
  *-----------------------------------------------------------------------------
  * Network drive is always the same for everyone, but may not be available
  * if the user is not connected to the World Bank intranet
  global network 	"//wbgfscifs01/GEDEDU/"
  cap cd "${network}"
  if _rc == 0     global network_is_available 1
  else            global network_is_available 0

  * Datalibweb is only available in Stata for internal World Bank users
  * but external users can access it through SOL (TODO add link here)
  cap which datalibweb
  if _rc == 0     global datalibweb_is_available 1
  else            global datalibweb_is_available 0

  *-----------------------------------------------------------------------------


  *-----------------------------------------------------------------------------
  * Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
  local user_commands fs pv seq mdesc alphawgt touch keeporder eststo // polychoric

  * Loop over all the commands to test if they are already installed, if not, then install
  foreach command of local user_commands {
    cap which `command'
    if _rc == 111 {
      * Polychoric is not in SSC so is checked separately -- line of code below does not work
      *if "`command'" == "polychoric" net install polychoric, from("http://staskolenikov.net/stata")
	  if "`command'" == "eststo" net install eststo, from("http://www.stata-journal.com/software/sj14-2/")
      *All other commands installed through SSC
      else  ssc install `command'
    }
  }


  *-----------------------------------------------------------------------------
  * 5) Flag that profile was successfully loaded
  *-----------------------------------------------------------------------------
  noi disp as result _n `"{phang}`this_repo' clone sucessfully set up (${clone}).{p_end}"'
  global HLO_profile_is_loaded = 1
  *-----------------------------------------------------------------------------
*}


/*
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


