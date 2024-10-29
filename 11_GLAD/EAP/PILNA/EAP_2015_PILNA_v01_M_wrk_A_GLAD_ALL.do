*=========================================================================*
* GLOBAL LEARNING ASSESSMENT DATABASE (GLAD)
* Project information at: https://github.com/worldbank/GLAD
*
* Metadata to be stored as 'char' in the resulting dataset (do NOT use ";" here)
local region      = "EAP"   /* LAC, SSA, WLD or CNT such as KHM RWA */
local year        = "2015"  /* 2015 */
local assessment  = "PILNA" /* pilna, PISA, EGRA, etc */
local master      = "v01_M" /* usually v01_M, unless the master (eduraw) was updated*/
local adaptation  = "wrk_A_GLAD" /* no need to change here */
local module      = "ALL"  /* for now, we are only generating ALL and ALL-BASE in GLAD */
local ttl_info    = "Joao Pedro de Azevedo [eduanalytics@worldbank.org]" /* no need to change here */
local dofile_info = "last modified by Syedah Aroob Iqbal in October 30, 2019"  /* change date*/
*
* Steps:
* 0) Program setup (identical for all assessments)
* 1) Open all rawdata, lower case vars, save in temp_dir
* 2) Combine all rawdata into a single file (merge and append)
* 3) Standardize variable names across all assessments
* 4) ESCS and other calculations
* 5) Bring WB countrycode & harmonization thresholds, and save dtas
*=========================================================================*


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

    // Filter the master country list to only this assessment-year
    use "${clone}/01_harmonization/011_rawdata/master_countrycode_list.dta", clear
    keep if (assessment == "`assessment'") & (year == `year')
    // Most assessments use the numeric idcntry_raw but a few (ie: PASEC 1996) have instead idcntry_raw_str
    /*if use_idcntry_raw_str[1] == 1 {
      drop   idcntry_raw
      rename idcntry_raw_str idcntry_raw
    }*/
    keep idcntry_raw national_level countrycode
	drop if missing(idcntry_raw)
    save "`temp_dir'/countrycode_list.dta", replace

    // Tokenized elements from the header to be passed as metadata
    local glad_description  "This dataset is part of the Global Learning Assessment Database (GLAD). It contains microdata from `assessment' `year'. Each observation corresponds to one learner (student or pupil), and the variables have been harmonized."
    local metadata          "region `region'; year `year'; assessment `assessment'; master `master'; adaptation `adaptation'; module `module'; ttl_info `ttl_info'; dofile_info `dofile_info'; description `glad_description'"

    *---------------------------------------------------------------------------
    * 1) Open all rawdata, lower case vars, save in temp_dir
    *---------------------------------------------------------------------------

    /* NOTE: Some assessments will loop over `prefix'`cnt' (such as pilna, TIMSS),
       then create a temp file with all prefixs of a cnt merged.
       but other asssessments only need to loop over prefix (such as LLECE).
       See the two examples below and change according to your needs */


    *Appending Literacy files:
       // Temporary copies of the 4 rawdatasets needed for each country (new section)
	   foreach file in P15_Y4_Lit_WB P15_Y6_Lit_WB {
         if `from_datalibweb' == 1 {
           noi edukit_datalibweb, d(country(`region') year(`year') type(EDURAW) surveyid(`surveyid') filename(`file'.dta) `shortcut')
         }
         else {
           use "`input_dir'/`file'.dta", clear
         }
         rename *, lower
         compress
         save "`temp_dir'/`file'.dta", replace
       }



    noi disp as res "{phang}Step 1 completed (`output_file'){p_end}"


    *---------------------------------------------------------------------------
    * 2) Combine all rawdata into a single file (merge and append)
    *---------------------------------------------------------------------------

    /* NOTE: the merge / append of all rawdata saved in temp in above step
       will vary slightly by assessment.
	 */  
	  // Merge the rawdatasets into a single TEMP country file
       use "`temp_dir'/P15_Y4_Lit_WB.dta", clear


    noi disp as res "{phang}Step 2 completed (`output_file'){p_end}"


    *---------------------------------------------------------------------------
    * 3) Standardize variable names across all assessments
    *---------------------------------------------------------------------------
    // For each variable class, we create a local with the variables in that class
    //     so that the final step of saving the GLAD dta  knows which vars to save

    // Every manipulation of variable must be enclosed by the ddi tags
    // Use clonevar instead of rename (preferable over generate)
    // The labels should be the same.
    // The generation of variables was commented out and should be replaced as needed

    // ID Vars:
    local idvars "idcntry_raw year idgrade idlearner"

    *<_idcntry_raw_>
    clonevar idcntry_raw = country
    label var idcntry_raw "Country ID, as coded in rawdata"
    *</_idcntry_raw_>
	
	*<_year_>
		drop year
	gen year = 2015
	label var year "Year"
	*</_year_>


    /*<_idschool_>
	clonevar idschool = schoolid
    label var idschool "School ID"
    *</_idschool_>*/

    *<_idgrade_>
	*clonevar idgrade = grade
    label var idgrade "Grade ID"
    *</_idgrade_>

    /*<_idclass_> Not available
    label var idclass "Class ID"
    *</_idclass_>*/

    *<_idlearner_>
    gen idlearner = _n
    label var idlearner "Learner ID"
    *</_idlearner_>

    // Drop any value labels of idvars, to be okay to append multiple surveys
    foreach var of local idvars {
      label values `var' .
    }
*/

    * VALUE Vars: 	  /* CHANGE HERE FOR YOUR ASSESSMENT!!! pilna EXAMPLE */ Not available for now.
    local valuevars	"score_pilna* "
	
	order grade gender country schoolauthority schoollocality nmcount idgrade year idcntry_raw idlearner
	
	ds grade gender country schoolauthority schoollocality nmcount idgrade year idcntry_raw idlearner, not
	local list = r(varlist)
	foreach var of local list {
		tab `var'
		clonevar `var'_cleaned = `var'
		replace `var'_cleaned = 0 if `var' == 9
		tab `var'_cleaned
	}
	ds *_cleaned
	local cleaned_items = r(varlist)
	egen score_pilna_lit_1 = rowtotal(`cleaned_items')
	egen score_pilna_writ_1 = 	///
	rowtotal(content_cleaned structures_cleaned organisation_cleaned spelling_cleaned	///
	punctuation_cleaned sentencestructure_cleaned partsofspeech_cleaned vocabulary_cleaned)
	gen score_pilna_read_1 = score_pilna_lit_1 - score_pilna_writ_1
	
	*Converting to percentage correct - Dividing by maximum possible points = 57 , as obtained from the sheet Item desc.
	
	replace score_pilna_lit_1 = (score_pilna_lit_1/57)*100
	replace score_pilna_writ_1 = (score_pilna_writ_1/24)*100
	replace score_pilna_read_1 = (score_pilna_read_1/33)*100



    /*<_score_assessment_subject_pv_> 
    foreach pv in 1 2 3 4 5 {
      clonevar score_pilna_read_`pv' = pv`pv'_d1
      label var score_pilna_read_`pv' "Plausible value `pv': `assessment' score for reading"
    }
    *</_score_assessment_subject_pv_>

    *<_level_assessment_subject_pv_> - Levels not available
    *foreach pv in 01 02 03 04 05 {
      clonevar level_pilna_read_`pv' = pl_pv`pv'_d1
      label var level_pilna_read_`pv' "Plausible value `pv': `assessment' level for reading"
    *}
    *</_level_assessment_subject_pv_>*/


    // TRAIT Vars:
    local traitvars	"urban* male"

    /*<_age_>
    *gen age = asdage		if  !missing(asdage)	& asdage!= 99
    label var age "Learner age at time of assessment"
    *</_age_>*/

    *<_urban_> 
    gen byte urban = 1 if (schoollocality == 1) 
	replace urban = 0 if schoollocality == 2
    label var urban "School is located in urban/rural area"
    *</_urban_>

    *<_urban_o_>
    *decode acbg05a, g(urban_o)
    *label var urban_o "Original variable of urban: population size of the school area"
    *</_urban_o_>

    *<_male_>
    gen byte male = 1 if gender == 2
	replace male = 0 if gender == 1
	label define male 1 "male" 0 "female"
	label values male male
    label var male "Learner gender is male/female"
    *</_male_>
	*/

    // SAMPLE Vars:		 	  /* CHANGE HERE FOR YOUR ASSESSMENT!!! pilna EXAMPLE */ Not available - 2015 PILNA did not have weights
    local samplevars "learner_weight nationally_representative fpc"

    *<_learner_weight_>
    gen learner_weight  = 1
    label var learner_weight "Total learner weight"
    *</_learner_weight_>

    *<_jkzone_>
    *label var jkzone "Jackknife zone"
    *</_jkzone_>

    *<_jkrep_>
    *label var jkrep "Jackknife replicate code"
    *</_jkrep_>
	
		*<_nationally_representative_>
    gen nationally_representative = 1
	label var nationally_representative "Nationally Representative"
    *</_nationally_representative_>
	
	*<_fpc_>
	/*Applying finite population correction for countries where census approach was employed:
	Note from 2015 Regional Report: The design uses a census approach for the relatively
smaller countries of Cook Islands, Niue, Palau, Tokelau and
Tuvalu, and a sampling approach for Federated States of
Micronesia, Papua New Guinea, Republic of the Marshall
Islands, Samoa, Solomon Islands, Tonga and Vanuatu.
Although it is a comparatively larger country population-wise,
Kiribati was granted its request that a census approach be
applied to its PILNA administration.*/
	gen fpc = 1  if inlist(country,184,570,585,772,798,296)
	replace fpc = 1 if missing(fpc)
	*</_fpc_>




    noi disp as res "{phang}Step 3 completed (`output_file'){p_end}"


    *---------------------------------------------------------------------------
    * 4) ESCS and other calculations
    *---------------------------------------------------------------------------

    // Placeholder for other operations that we may want to include (kept in ALL-BASE) Not available
    *<_escs_>
    * code for ESCS
    * label for ESCS
    *</_escs_>

    noi disp as res "{phang}Step 4 completed (`output_file'){p_end}"
	
	*---------------------------------------------------------------------------
	*Save grade 4
	*---------------------------------------------------------------------------
	save "`temp_dir'/TEMP_`surveyid'_grade4.dta", replace
	
	*---------------------------------------------------------------------------
	*Repeat the process for grade 6
	*---------------------------------------------------------------------------

       use "`temp_dir'/P15_Y6_Lit_WB.dta", clear

    noi disp as res "{phang}Step 2 completed (`output_file'){p_end}"


    *---------------------------------------------------------------------------
    * 3) Standardize variable names across all assessments
    *---------------------------------------------------------------------------
    // For each variable class, we create a local with the variables in that class
    //     so that the final step of saving the GLAD dta  knows which vars to save

    // Every manipulation of variable must be enclosed by the ddi tags
    // Use clonevar instead of rename (preferable over generate)
    // The labels should be the same.
    // The generation of variables was commented out and should be replaced as needed

    // ID Vars:
    local idvars "idcntry_raw year idgrade idlearner"

    *<_idcntry_raw_>
    clonevar idcntry_raw = country
    label var idcntry_raw "Country ID, as coded in rawdata"
    *</_idcntry_raw_>
	
	*<_year_>
		drop year
	gen year = 2015
	label var year "Year"
	*</_year_>


    /*<_idschool_>
	clonevar idschool = schoolid
    label var idschool "School ID"
    *</_idschool_>*/

    *<_idgrade_>
	*clonevar idgrade = grade
    label var idgrade "Grade ID"
    *</_idgrade_>

    /*<_idclass_> Not available
    label var idclass "Class ID"
    *</_idclass_>*/

    *<_idlearner_>
    gen idlearner = _n
    label var idlearner "Learner ID"
    *</_idlearner_>

    // Drop any value labels of idvars, to be okay to append multiple surveys
    foreach var of local idvars {
      label values `var' .
    }
*/

    * VALUE Vars: 	  /* CHANGE HERE FOR YOUR ASSESSMENT!!! pilna EXAMPLE */ Not available for now.
    local valuevars	"score_pilna* "
	
	order grade gender country schoolauthority schoollocality nmcount idgrade idcntry_raw year idlearner
	
	ds grade gender country schoolauthority schoollocality nmcount idgrade idcntry_raw year idlearner, not
	local list = r(varlist)
	foreach var of local list {
		tab `var'
		clonevar `var'_cleaned = `var'
		replace `var'_cleaned = 0 if inlist(`var',8,9)
		tab `var'_cleaned
	}
	ds *_cleaned
	local cleaned_items = r(varlist)
	egen score_pilna_lit_1 = rowtotal(`cleaned_items')
	egen score_pilna_writ_1 = 	///
	rowtotal(content_cleaned structure_cleaned organisation_cleaned spelling_cleaned 	///
	punctuation_cleaned sentencestructure_cleaned partsofspeech_cleaned vocabulary_cleaned)
	gen score_pilna_read_1 = score_pilna_lit_1 - score_pilna_writ_1
	
	*Converting to percentage correct - Dividing by maximum possible points = 73 , as obtained from the sheet Item desc.
	
	replace score_pilna_lit_1 = (score_pilna_lit_1/73)*100
	replace score_pilna_writ_1 = (score_pilna_writ_1/24)*100
	replace score_pilna_read_1 = (score_pilna_read_1/49)*100



    /*<_score_assessment_subject_pv_> 
    foreach pv in 1 2 3 4 5 {
      clonevar score_pilna_read_`pv' = pv`pv'_d1
      label var score_pilna_read_`pv' "Plausible value `pv': `assessment' score for reading"
    }
    *</_score_assessment_subject_pv_>

    *<_level_assessment_subject_pv_> - Levels not available
    *foreach pv in 01 02 03 04 05 {
      clonevar level_pilna_read_`pv' = pl_pv`pv'_d1
      label var level_pilna_read_`pv' "Plausible value `pv': `assessment' level for reading"
    *}
    *</_level_assessment_subject_pv_>*/


    // TRAIT Vars:
    local traitvars	"urban* male"

    /*<_age_>
    *gen age = asdage		if  !missing(asdage)	& asdage!= 99
    label var age "Learner age at time of assessment"
    *</_age_>*/

    *<_urban_> 
    gen byte urban = 1 if (schoollocality == 1) 
	replace urban = 0 if schoollocality == 2
    label var urban "School is located in urban/rural area"
    *</_urban_>

    *<_urban_o_>
    *decode acbg05a, g(urban_o)
    *label var urban_o "Original variable of urban: population size of the school area"
    *</_urban_o_>

    *<_male_>
    gen byte male = 1 if gender == 2
	replace male = 0 if gender == 1
	label define male 1 "male" 0 "female"
	label values male male
    label var male "Learner gender is male/female"
    *</_male_>
	*/

    // SAMPLE Vars:		 	  /* CHANGE HERE FOR YOUR ASSESSMENT!!! pilna EXAMPLE */ Not available - 2015 PILNA did not have weights
    local samplevars "learner_weight nationally_representative fpc"

    *<_learner_weight_>
    gen learner_weight  = 1
    label var learner_weight "Total learner weight"
    *</_learner_weight_>

    *<_jkzone_>
    *label var jkzone "Jackknife zone"
    *</_jkzone_>

    *<_jkrep_>
    *label var jkrep "Jackknife replicate code"
    *</_jkrep_>
	
	*<_nationally_representative_>
    gen nationally_representative = 1
	label var nationally_representative "Nationally Representative"
    *</_nationally_representative_>

		*<_fpc_>
	/*Applying finite population correction for countries where census approach was employed:
	Note from 2015 Regional Report: The design uses a census approach for the relatively
smaller countries of Cook Islands, Niue, Palau, Tokelau and
Tuvalu, and a sampling approach for Federated States of
Micronesia, Papua New Guinea, Republic of the Marshall
Islands, Samoa, Solomon Islands, Tonga and Vanuatu.
Although it is a comparatively larger country population-wise,
Kiribati was granted its request that a census approach be
applied to its PILNA administration.*/
	gen fpc = 0  if inlist(country,184,570,585,772,798,296)
	replace fpc = 1 if missing(fpc)
	*</_fpc_>


    noi disp as res "{phang}Step 3 completed (`output_file'){p_end}"


    *---------------------------------------------------------------------------
    * 4) ESCS and other calculations
    *---------------------------------------------------------------------------

    // Placeholder for other operations that we may want to include (kept in ALL-BASE) Not available
    *<_escs_>
    * code for ESCS
    * label for ESCS
    *</_escs_>

    noi disp as res "{phang}Step 4 completed (`output_file'){p_end}"
	
	*---------------------------------------------------------------------------
	*Save grade 6
	*---------------------------------------------------------------------------
	save "`temp_dir'/TEMP_`surveyid'_grade6.dta", replace
	*Appending grade 4:
	append using "`temp_dir'/TEMP_`surveyid'_grade4.dta"

    *---------------------------------------------------------------------------
    * 5) Bring WB countrycode & harmonization thresholds, and save dtas
    *---------------------------------------------------------------------------

    // Brings World Bank countrycode from ccc_list
    // NOTE: the *assert* is intentional, please do not remove it.
    // if you run into an assert error, edit the 011_rawdata/master_countrycode_list.csv
	merge m:1 idcntry_raw using "`temp_dir'/countrycode_list.dta", keep(match) assert(match using) nogen
	*Tonga participated in numeracy but not in literacy

    // Surveyid is needed to merge harmonization proficiency thresholds
    gen str surveyid = "`region'_`year'_`assessment'"
    label var surveyid "Survey ID (Region_Year_Assessment)"

    // New variable class: keyvars (not IDs, but rather key to describe the dataset)
    local keyvars "surveyid countrycode national_level"

    /* Harmonization of proficiency on-the-fly, based on thresholds as CPI - Not available
    glad_hpro_as_cpi
    local thresholdvars "`r(thresholdvars)'"
    local resultvars    "`r(resultvars)'"

    // Update valuevars to include newly created harmonized vars (from the ado)
    local valuevars : list valuevars | resultvars
	*/

    // This function compresses the dataset, adds metadata passed in the arguments as chars, save GLAD_BASE.dta
    // which contains all variables, then keep only specified vars and saves GLAD.dta, and delete files in temp_dir - Ask about this
    edukit_save,  filename("`output_file'") path("`output_dir'") dir2delete("`temp_dir'")              ///
                idvars("`idvars'") varc("key `keyvars'; value `valuevars'; trait `traitvars'; sample `samplevars'") ///
                metadata("`metadata'") collection("GLAD_RAW")
	*/
	/*save "`output_dir'\EAP_2015_PILNA_v01_M_v01_wrk_GLAD.dta", replace
    noi disp as res "Creation of `output_file'.dta completed"


  /*else {
    noi disp as txt "Skipped creation of `output_file'.dta (already found in clone)"
    // Still loads it, to generate documentation
    use "`output_dir'/`output_file'.dta", clear
  }
