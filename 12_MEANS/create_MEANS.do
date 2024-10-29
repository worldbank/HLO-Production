*==============================================================================*
*Create Means from GLADs
*Author: Syedah Aroob Iqbal
*==============================================================================*
set trace on
*-------------------------------------------------------------------------------
* Program setup
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* Loop over all GLADs to create means
*-------------------------------------------------------------------------------
* Basically, it runs region_year_assessment_v_M_v_A_MEANS.do files in 12_MEANS


* Loop over all surveys to process (ie: WLD_2001_PIRLS)
global surveys_to_process = "EGRA"
foreach survey of global surveys_to_process {

	do "${clone}/WLD_ALL_`survey'_v01_M_v01_MEANS.do"

}

