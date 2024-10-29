*=========================================================================*
* GLOBAL LEARNING ASSESSMENT DATABASE (GLAD)
* Project information at: https://github.com/worldbank/GLAD
*
* Metadata to be stored as 'char' in the resulting dataset (do NOT use ";" here)
local region      = "ATG" // Rwanda *Make a change here:
local year        = "2016" // Specify the year here
local assessment  = "EGRA"
local master      = "v01_M"
local adaptation  = "wrk_A_GLAD"
local module      = "ALL"
local ttl_info    = "Joao Pedro de Azevedo [jazevedo@worldbank.org]"
local dofile_info = "last modified by Syedah Aroob Iqbal 4th Nov, 2019"
*
* Steps:
* 0) Program setup (identical for all assessments)
* 1) Open all rawdata, lower case vars, save in temp_dir
* 2) Combine all rawdata into a single file (merge and append)
* 3) Standardize variable names across all assessments
* 4) ESCS and other calculations (by Aroob, from Feb 2019)
* 5) Bring WB countrycode & harmonization thresholds, and save dtas
*=========================================================================*


*Open the file:
*use "M:\CNT\ATG\ATG_2016_EGRA\ATG_2016_EGRA_v01_M\Data\Stata\ATG-AB_2016_EGRA.dta", clear

  *---------------------------------------------------------------------------
  * 0) Program setup (identical for all assessments)
  *---------------------------------------------------------------------------

  // Parameters ***NEVER COMMIT CHANGES TO THOSE LINES!***
  //  - whether takes rawdata from datalibweb (==1) or from indir (!=1), global in 01_run.do
  local from_datalibweb = $from_datalibweb
  //  - whether checks first if file exists and attempts to skip this do file
  local overwrite_files = $overwrite_files
  //  - optional shortcut in datalibweb
  local shortcut = "$shortcut"
  //  - setting random seed at the beginning of each do for reproducibility
  set seed $master_seed

  // Set up folders in clone and define locals to be used in this do-file
  glad_local_folder_setup , r("`region'") y("`year'") as("`assessment'") ma("`master'") ad("`adaptation'")
  local temp_dir     "`r(temp_dir)'"
  local output_dir   "`r(output_dir)'"
  local surveyid     "`r(surveyid)'"
  local output_file  "`surveyid'_`adaptation'_`module'"

  // If user does not have access to datalibweb, point to raw microdata location
  if `from_datalibweb' == 0 {
    local input_dir	= "${input}/`region'/`region'_`year'_`assessment'/`surveyid'/Data/Stata"
  }

  // Confirm if the final GLAD file already exists in the local clone
  cap confirm file "`output_dir'/`output_file'.dta"
  // If the file does not exist or overwrite_files local is set to one, run the do
  *if (_rc == 601) | (`overwrite_files') {

    /* Filter the master country list to only this assessment-year - Not needed for EGRAs
    use "${clone}/01_harmonization/011_rawdata/master_countrycode_list.dta", clear
    keep if (assessment == "`assessment'") & (year == `year')
    // Most assessments use the numeric idcntry_raw but a few (ie: PASEC 1996) have instead idcntry_raw_str
    if use_idcntry_raw_str[1] == 1 {
      drop   idcntry_raw
      rename idcntry_raw_str idcntry_raw
    }
    keep idcntry_raw national_level countrycode
    save "`temp_dir'/countrycode_list.dta", replace
	*/

    // Tokenized elements from the header to be passed as metadata
    local glad_description  "This dataset is part of the Global Learning Assessment Database (GLAD). It contains microdata from `assessment' `year'. Each observation corresponds to one learner (student or pupil), and the variables have been harmonized."
    local metadata          "region `region'; year `year'; assessment `assessment'; master `master'; adaptation `adaptation'; module `module'; ttl_info `ttl_info'; dofile_info `dofile_info'; description `glad_description'"

    *---------------------------------------------------------------------------
    * 1) Open all rawdata, lower case vars, save in temp_dir
    *---------------------------------------------------------------------------

    /* NOTE: Some assessments will loop over `prefix'`cnt' (such as PIRLS, TIMSS),
       then create a temp file with all prefixs of a cnt merged.
       but other asssessments only need to loop over prefix (such as LLECE).
       See the two examples below and change according to your needs */

         if `from_datalibweb'==1 {
           noi edukit_datalibweb, d(country(`region') year(`year') type(EDURAW) surveyid(`surveyid') filename(ATG-AB_2016_EGRA.dta) `shortcut')
         }
         else {
           use "`input_dir'/ATG-AB_2016_EGRA.dta", clear
         }
         rename *, lower
         compress
         save "`temp_dir'/ATG-AB_2016_EGRA.dta", replace
       }

    noi disp as res "{phang}Step 1 completed (`output_file'){p_end}"


		*---------------------------------------------------------------------------
		* 3) Standardize variable names across all assessments
		*---------------------------------------------------------------------------
		// For each variable class, we create a local with the variables in that class
		//     so that the final step of saving the GLAD dta  knows which vars to save

		// ID Vars:
		local idvars	"countrycode year idschool idgrade idlearner"  // no idclass & idcntry_raw does not exist for EGRA (single country)

		*<_countrycode_>
		gen countrycode = "ATG"
		label var countrycode "ATG"
		*</_countrycode_>

		*<_year_>
		label var year "2016"
		*</_year_>

		*<_idschool_>
		clonevar idschool = schoolnum
		label var idschool "School ID"
		*</_idschool_>

		*<_idgrade_>
		gen idgrade = 2
		*</_idgrade_>

		*<_idclass_>
		gen int idclass = -99	// PLACEHOLDER: double check documentation to make sure it doesnt exist / give more informative missing value
		label var idclass "Class ID"
		*</_idclass_>

		*<_idlearner_>
		gen  idlearner = id 
		label var idlearner "Learner ID"
		*</_idlearner_>

		// Drop any value labels of idvars, to be okay to append multiple surveys
		foreach var of local idvars {
			cap label values `var' .
		}

		*<_read_comp_score_pcnt_>
		destring A2q1 A2q2 A2q3 A2q4 A2q5, generate(A2q1_n A2q2_n A2q3_n A2q4_n A2q5_n)
		replace A2q1_n =0 if A2q1_n==.
		replace A2q2_n=0 if A2q2_n==.
		replace A2q3_n=0 if A2q3_n==.
		replace A2q4_n=0 if A2q4_n==.
		replace A2q5_n=0 if A2q5_n==.
		egen sum = rowtotal(A2q1_n A2q2_n A2q3_n A2q3_n A2q4_n A2q5_n)
		gen read_comp_score_pcnt=sum/5*100
		*</_read_comp_score_pcnt_>
		
		*<_score_assessment_subject_pv_> keep 
		// PLACEHOLDER!!! WHICH ONE TO USE? SCORE OR PCNT?
		clonevar  score_egra_read  = read_comp_score_pcnt
		label var score_egra_read	 "Egra score for read (pcnt)"
		*</_score_assessment_subject_pv_>
	

		*<_urban_>
		gen urban=location
		replace urban=0 if urban==2
		label var urban "School is located in urban/rural area"
		*</_urban_>

		*<_male_>
		gen male=sex
		replace male=0 if male==2
		*</_male_>
		
		*<_learner_weight_>
		gen learner_weight=1
		*</_learner_weight_>
		
		*<_Language_test_>
		gen language_test = "English"

		*<_Language_instruction_>
		gen language_instruction = "English"
		*</_Language_instruction_>
		
		*<_Language_home_> 
		gen language_home= langhome
		label define languageathome 1 "English" 2 "Creole" 3 "Spanish" 4 “other”
		label value language_home languageathome

		*<_Nationally_representative_> 
		gen nationally_representative = 1
		*</_Nationally_representative_>
		
		*<_Regionally_representative_> 
		gen regionally_representative = 0
		*<_Regionally_representative_>
		
		*<_Has_learner_weights_>
		gen has_learner_weights=0
		*<_Has_learner_weights_>
				
		*<_age_>
		label var age "Learner age at time of assessment"
		*</_age_>

		
		// TRAIT Vars:
		local traitvars	"age urban* male escs"   // PLACEHOLDER: TBD


		// SAMPLE Vars:
		local samplevars "learner_weight"


		noi disp as res "{phang}Step 3 completed (`output_file'){p_end}"

		*---------------------------------------------------------------------------
		* 4) ESCS and other calculations (by Aroob, from Feb 2019)
		*---------------------------------------------------------------------------
		// There was never a ESCS for this file, so this section is TBD
		gen escs = .a

		noi disp as res "{phang}Step 4 completed (`output_file'){p_end}"


		*---------------------------------------------------------------------------
		* 5) Bring WB countrycode and save GLAD and GLAD_BASE dta
		*---------------------------------------------------------------------------

		// Brings World Bank countrycode from ccc_list
		*** SEGMENT NOT NEEDED FOR EGRA, BY DEFAULT A SINGLE COUNTRY ***

		// Additional metadata: EGRA characteristics
		char _dta[language_test]                "English"
		char _dta[language_instruction]         "English"
		char _dta[nationally_representative]    "1"
		char _dta[regionally_representative]    "0"
		char _dta[has_learner_weights]			    "1"

		// updates the metadata local to include the above
		local egrachars  "language_test language_instruction nationally_representative regionally_representative has_learner_weights"
		local metadata   "`metadata'; egrachars `egrachars'"

		// This function compresses the dataset, adds metadata passed in the arguments as chars, save GLAD_BASE.dta
		// which contains all variables, then keep only specified vars and saves GLAD.dta, and delete files in temp_dir
		
save "M:\CNT\ATG\ATG_2016_EGRA\ATG_2016_EGRA_v01_M_wrk_HAD\ATG-AB_2016_EGRA_v01_M_wrk_A_HAD.dta", replace

*Please save in the network drive
