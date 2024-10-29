set seed 10051990
set sortseed 10051990


*Ethiopia
use "${path}\CNT\ETH\ETH_2010_EGRA\ETH_2010_EGRA_v01_M\Data\Stata\2010.dta", clear
sort region urban id
gen school_id = .
replace school_id = id[_n] - id[_n-1] - 1 if grade == 2
gen school_id_new = id if school_id != 0 & !missing(school_id)
replace school_id_new = id if missing(school_id) & _n == 1
replace school_id_new = school_id_new[_n-1] if missing(school_id_new)
drop school_id
ren school_id_new school_code

*Standardizing weight components:
gen su1 =  s_citySVY 
gen su2 = school_code
gen strata3 = ClassGender
gen su3 = id
*Based on language, the initial, final or all sounds in words are asked in the phonemic awareness test.
*Consolidating the phonemics score in different langugages using different methods:
gen pa_init_sound_score = pa_df_fnl_snd_score
replace pa_init_sound_score = pa_num_sound_score if missing(pa_init_sound_score)
replace pa_init_sound_score =  pa_df_init_snd_score if missing(pa_init_sound_score)

gen pa_init_sound_score_pcnt = pa_df_fnl_snd_score_pcnt
replace pa_init_sound_score_pcnt = pa_num_sound_score_pcnt if missing(pa_init_sound_score_pcnt)
replace pa_init_sound_score_pcnt = pa_df_init_snd_score_pcnt if missing(pa_init_sound_score_pcnt)

gen pa_init_sound_score_zero = pa_df_fnl_snd_score_zero
replace pa_init_sound_score_zero = pa_num_sound_score_zero if missing(pa_init_sound_score_zero)
replace pa_init_sound_score_zero = pa_df_init_snd_score_zero if missing(pa_init_sound_score_zero)

gen pa_init_sound_attempted = pa_df_fnl_snd_attempted
replace pa_init_sound_attempted = pa_num_sound_attempted if missing(pa_init_sound_attempted)
replace  pa_init_sound_attempted = pa_df_init_snd_attempted if missing( pa_init_sound_attempted)

gen pa_init_sound_attempted_pcnt = pa_df_fnl_snd_attempted_pcnt
replace pa_init_sound_attempted_pcnt = pa_num_sound_attempted_pcnt if missing(pa_init_sound_attempted_pcnt)
replace  pa_init_sound_attempted_pcnt = pa_df_init_snd_attempted_pcnt if missing( pa_init_sound_attempted_pcnt)
*
foreach var of varlist *_pcnt {
		replace `var' = `var'*100
	}
gen n_res = 1
gen r_res = 1
gen w = 1
decode region, gen(region_s)
drop region
ren region_s region
decode language, gen(language_s)
drop language
ren language_s language
gen lang_instr = language
gen s_res = 1

*Constructing index for socio-economic status:
*Identifying variables for index:
*radio2 phone2 elect2 tel2 toilet2 bike2 m_cycle2 car2 animals n_ani roof floor
replace roof = . if inlist(roof,0,4,9)
replace floor = . if floor == 9

tab roof, gen(roof_d)
tab floor, gen(floor_d)
mdesc radio2 phone2 elect2 tel2 toilet2 bike2 m_cycle2 car2 animals n_ani roof_d* floor_d*
foreach var of varlist radio2 phone2 elect2 tel2 toilet2 bike2 m_cycle2 car2 animals n_ani roof_d* floor_d* {
	bysort region school_code: egen `var'_mean = mean(`var')
	bysort region school_code: egen `var'_count = count(`var')
	bysort region: egen `var'_mean_reg = mean(`var')
	bysort region: egen `var'_count_reg = count(`var')
	egen `var'_mean_cnt = mean(`var')
	replace `var' = `var'_mean if missing(`var') & `var'_count > 5 & !missing(`var'_count)
	replace `var' = `var'_mean_reg if missing(`var') & `var'_count_reg > 10 & !missing(`var'_count_reg)
	replace `var' = `var'_mean_cnt if missing(`var') 
	egen `var'_std = std(`var')
}

alphawgt radio2_std phone2_std elect2_std tel2_std toilet2_std bike2_std m_cycle2_std car2_std animals_std n_ani_std roof_d*_std floor_d*_std [weight = wt_final], detail item std label  // 0.9123
pca radio2_std phone2_std elect2_std tel2_std toilet2_std bike2_std m_cycle2_std car2_std animals_std n_ani_std roof_d*_std floor_d*_std [weight = wt_final]
predict ESCS
gen cntabb = "ETH"
gen idcntry = 231

*Generating asset variables:
gen radio_yn = radio2
gen telephone_yn = phone2
gen electricity_yn = elect2
gen television_yn = tel2
gen toilet_yn = toilet2
gen bicycle_yn = bike2
gen motorcycle_yn = m_cycle2
gen four_wheeler_yn = car2
gen animals_yn = animals
gen animals_n = n_ani
gen roof_hidmo_yn = roof_d1
gen roof_thatched_yn = roof_d2
gen roof_corriron_yn = roof_d3
gen floor_earth_yn = floor_d1
gen floor_tile_yn = floor_d2
gen floor_cement_yn = floor_d3

save "${path}\CNT\ETH\ETH_2010_EGRA\ETH_2010_EGRA_v01_M_v01_A_BASE\ETH_2010_EGRA_v01_M_v01_A_BASE.dta" , replace
keep country cntabb idcntry year n_res wt_final strata* su* fpc* read_comp_score_pcnt *_yn grade w
codebook, compact
cf _all using "${path}\CNT\ETH\ETH_2010_EGRA\ETH_2010_EGRA_v01_M_v01_A_HAD.dta"
save "${path}\CNT\ETH\ETH_2010_EGRA\ETH_2010_EGRA_v01_M_v01_A_HAD.dta" , replace

/*replace country = "Ethiopia"
gen cntabb = "ETH"
gen idcntry = 231
save "${gsdData}/0-RawOutput/merged/Ethiopia.dta", replace
