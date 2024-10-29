/******************************************************************************/
// Purpose		: Creates an HLO panel for 2010, 2018 and 2020
// Input data	: hlo.dta 
// Output data	: hlo_data.dta; hlo_data_8May2020.dta
// Last edited	: Aug 19, 2020
// Last run		: Aug 19, 2020
// Written by	: Ritika

/* Structure of this do file:
1. Preliminaries
2. Constructing HLO Panel with observations in 2010, 2018 and 2020
*/
/******************************************************************************/

set more off
clear

use "$hlodta_out\hlo.dta", clear


/******************************************************************************/
// 2. Constructing HLO Panel with observations in 2010, 2017 and 2019
/******************************************************************************/
// How many tests does each country have
	bys wbcode: egen ct=count(hlo_mf_rep)	
	
	sort countrynumber year
	xtset countrynumber year

// Fill the 2020 cross-section with the most recent observation as of 2019
	foreach gen in mf m f {
		foreach var in fill year lower upper {
			gen hlo_`gen'_`var'_2020=L1.hlo_`gen'_`var' if year==2020
			}
		gen hlo_`gen'_source_2020=hlo_`gen'_source[_n-1] if year==2020
	}
	gen hlo_new_2020=L1.hlo_new_fill if year==2020
	
// Fill the 2018 cross-section with the most recent observation as of 2019
	foreach gen in mf m f {
		foreach var in fill year upper lower {
			gen hlo_`gen'_`var'_2018=L3.hlo_`gen'_`var' if year==2020
			}
		gen hlo_`gen'_source_2018=hlo_`gen'_source[_n-3] if year==2020
	}
	gen hlo_new_2018=L3.hlo_new_fill if year==2020

// Some rules for building the 2010 cross section
// 0. If country has only one test, it will not show up in 2010 cross section
	foreach gen in mf m f {
		foreach var in fill year upper lower {
			gen hlo_`gen'_`var'_2010=.
			}
		gen hlo_`gen'_source_2010=""
	}

	foreach gen in mf m f {
	// 1. If PISA 2009 exists, take it (this is default in code above)
		replace hlo_`gen'_fill_2010=L11.hlo_`gen'_rep if year==2020 & hlo_`gen'_source[_n-11]=="PISA"
		replace hlo_`gen'_year_2010=L11.hlo_`gen'_year if year==2020 & hlo_`gen'_source[_n-11]=="PISA"
		replace hlo_`gen'_upper_2010=L11.hlo_`gen'_upper if year==2020 & hlo_`gen'_source[_n-11]=="PISA"
		replace hlo_`gen'_lower_2010=L11.hlo_`gen'_lower if year==2020 & hlo_`gen'_source[_n-11]=="PISA"	
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-11] if year==2020 & hlo_`gen'_source[_n-11]=="PISA"
	
	// 2. If TIMSS/PIRLS 2011 round exists, take it 
		replace hlo_`gen'_year_2010=L9.hlo_`gen'_year if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & L9.hlo_mf_year==2011
		replace hlo_`gen'_upper_2010=L9.hlo_`gen'_upper if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & L9.hlo_mf_year==2011 
		replace hlo_`gen'_lower_2010=L9.hlo_`gen'_lower if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & L9.hlo_mf_year==2011
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-9] if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & L9.hlo_mf_year==2011
		replace hlo_`gen'_fill_2010=L9.hlo_`gen'_rep if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & L9.hlo_mf_year==2011
	
	// 3. If country is in PASEC, use the 2006 PASEC round 
		replace hlo_`gen'_year_2010=L14.hlo_`gen'_year if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-14]=="PASEC" & L14.hlo_mf_year==2006
		replace hlo_`gen'_upper_2010=L14.hlo_`gen'_upper if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-14]=="PASEC" & L14.hlo_mf_year==2006
		replace hlo_`gen'_lower_2010=L14.hlo_`gen'_lower if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-14]=="PASEC" & L14.hlo_mf_year==2006
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-14] if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-14]=="PASEC" & L14.hlo_mf_year==2006
		replace hlo_`gen'_fill_2010=L14.hlo_`gen'_rep if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-14]=="PASEC" & L14.hlo_mf_year==2006
	
	// 4. If country is in SACMEQ, use the 2007 SACMEQ round 
		replace hlo_`gen'_year_2010=L13.hlo_`gen'_year if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-13]=="SACMEQ"
		replace hlo_`gen'_upper_2010=L13.hlo_`gen'_upper if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-13]=="SACMEQ" 
		replace hlo_`gen'_lower_2010=L13.hlo_`gen'_lower if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-13]=="SACMEQ" 
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-13] if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-13]=="SACMEQ"
		replace hlo_`gen'_fill_2010=L13.hlo_`gen'_rep if year==2020 & hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-13]=="SACMEQ"
	
	
	// 5. If country is in PILNA, use the 2012 PILNA in 2010 (and 2018 is used for 2019)
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-8] if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-8]=="PILNA"
		replace hlo_`gen'_year_2010=L8.hlo_`gen'_year if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-8]=="PILNA"
		replace hlo_`gen'_upper_2010=L8.hlo_`gen'_upper if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-8]=="PILNA" 
		replace hlo_`gen'_lower_2010=L8.hlo_`gen'_lower if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-8]=="PILNA" 
		replace hlo_`gen'_fill_2010=L8.hlo_`gen'_rep if year==2020 &  hlo_`gen'_fill_2010==. & hlo_`gen'_source[_n-8]=="PILNA"
	
	}


// 43 member countries still missing a 2010 number; 30 EGRA/EGRANR
	cou if year==2020 & hlo_mf_fill_2020!=. & ct>1 // 148
	cou if year==2020 & hlo_mf_fill_2020!=. & hlo_mf_fill_2010==. & ct>1 // 51
	tab wbcode if year==2020 & hlo_mf_fill_2020!=. & hlo_mf_fill_2010==. & ct>1 // 51

// First, a filled-in series for rates and years
	foreach gen in mf m f {
		qui gen fill_`gen'_2010= hlo_`gen'_rep if year>2004 & year<2015
		qui gen lower_`gen'_2010= hlo_`gen'_lower if year>2004 & year<2015 & fill_`gen'_2010!=. 
		qui gen upper_`gen'_2010= hlo_`gen'_upper if year>2004 & year<2015 & fill_`gen'_2010!=. 
		qui gen year_`gen'_2010= year if fill_`gen'_2010!=. 
	}

	foreach gen in mf m f {
		forvalues y=1/5 {
			foreach x in L F {
				replace fill_`gen'_2010= `x'`y'.hlo_`gen'_rep if missing(fill_`gen'_2010) & (`x'`y'.year>=2005 & `x'`y'.year<=2014)
				replace lower_`gen'_2010= `x'`y'.hlo_`gen'_lower if missing(lower_`gen'_2010) & fill_`gen'_2010!=.
				replace upper_`gen'_2010= `x'`y'.hlo_`gen'_upper if missing(upper_`gen'_2010) & fill_`gen'_2010!=.
				replace year_`gen'_2010= `x'`y'.year if missing(year_`gen'_2010) & fill_`gen'_2010!=.
			}
		}
	}
/*
br wbcode year hlo_mf_rep hlo_mf_lower hlo_mf_upper hlo_fill_mf_2010 lower_mf_2010 upper_mf_2010 year_mf_2010 if ///
	inlist(wbcode,"ATG","BGD","DOM","NGA","PAK","TTO","MLI") & year>2000	
	
	
br wbcode year hlo_mf_source hlo_mf_rep hlo_mf_lower hlo_mf_upper fill_mf_2010 lower_mf_2010 upper_mf_2010 year_mf_2010 if ///
	inlist(wbcode,"ATG","BGD","DOM","NGA","PAK","TTO","MLI") & year>2000
*/	
// Then, a filled-in series for the source
	foreach gen in mf m f {
		qui gen q_`gen'= hlo_`gen'_source if hlo_`gen'_rep!=.
		qui gen source_`gen'_2010= q_`gen' if fill_`gen'_2010!=.
	}

	foreach gen in mf m f {
		forvalues j=1/5 {
			replace source_`gen'_2010= q_`gen'[_n-`j'] if missing(source_`gen'_2010) & fill_`gen'_2010!=.
			replace source_`gen'_2010= q_`gen'[_n+`j'] if missing(source_`gen'_2010) & fill_`gen'_2010!=.
		}
	}
/*
br wbcode year hlo_mf_rep hlo_mf_lower hlo_mf_upper fill_mf_2010 hlo_mf_fill_2010 ///
	lower_mf_2010 hlo_mf_lower_2010 upper_mf_2010 hlo_mf_upper_2010 year_mf_2010 hlo_mf_year_2010 if ///
	inlist(wbcode,"ATG","BGD","DOM","NGA","PAK","TTO","MLI") & year>2000 & year<2021
	
br wbcode year hlo_mf_source hlo_mf_rep hlo_mf_lower hlo_mf_upper hlo_mf_fill_2010 ///
	hlo_mf_lower_2010 hlo_mf_upper_2010 hlo_mf_year_2010 if ///
	inlist(wbcode,"ATG","BGD","DOM","NGA","PAK","TTO","MLI") & year>2000 & year<2021	
	*/
// Keep data only for 2010
	foreach gen in mf m f {
		replace fill_`gen'_2010=. if year!=2010
		replace lower_`gen'_2010=. if year!=2010
		replace upper_`gen'_2010=. if year!=2010
		replace year_`gen'_2010=. if year!=2010
		replace source_`gen'_2010="" if year!=2010
	}
	
	foreach gen in mf m f {
		replace hlo_`gen'_fill_2010=L10.fill_`gen'_2010 if year==2020 & hlo_`gen'_fill_2010==.
		replace hlo_`gen'_lower_2010=L10.lower_`gen'_2010 if year==2020 & hlo_`gen'_fill_2010!=. & hlo_`gen'_lower_2010==.
		replace hlo_`gen'_upper_2010=L10.upper_`gen'_2010 if year==2020 & hlo_`gen'_fill_2010!=. & hlo_`gen'_upper_2010==.
		replace hlo_`gen'_year_2010=L10.year_`gen'_2010 if year==2020 & hlo_`gen'_fill_2010!=. & hlo_`gen'_year_2010==.
		replace hlo_`gen'_source_2010=source_`gen'_2010[_n-10] if year==2020 & hlo_`gen'_fill_2010!=. & hlo_`gen'_source_2010==""
	}
	
	foreach gen in mf m f {
		replace hlo_`gen'_fill_2010=. if hlo_`gen'_year_2010==hlo_`gen'_year_2020
		replace hlo_`gen'_source_2010="" if hlo_`gen'_fill_2010==.
		replace hlo_`gen'_lower_2010=. if hlo_`gen'_fill_2010==.
		replace hlo_`gen'_upper_2010=. if hlo_`gen'_fill_2010==.
		replace hlo_`gen'_year_2010=. if hlo_`gen'_fill_2010==.
	}

/*
br wbcode year hlo_mf_source hlo_mf_rep hlo_mf_lower hlo_mf_upper fill_mf_2010 hlo_mf_fill_2010 ///
	lower_mf_2010 hlo_mf_lower_2010 upper_mf_2010 hlo_mf_upper_2010 year_mf_2010 hlo_mf_year_2010 if ///
	inlist(wbcode,"BLZ","TGO","PHL") & year>2000 & year<2021


br wbcode year hlo_mf_source hlo_mf_rep hlo_mf_lower hlo_mf_upper fill_mf_2010 hlo_mf_fill_2010 ///
	lower_mf_2010 hlo_mf_lower_2010 upper_mf_2010 hlo_mf_upper_2010 year_mf_2010 hlo_mf_year_2010 if ///
	(hlo_mf_fill_2010<hlo_mf_lower_2010|hlo_mf_fill_2010>hlo_mf_upper_2010) & year>2000 & year<2021
*/	


// Manual overrides
	local ct COD DOM GHA KGZ HTI PHL PNG TZA PNG TON VUT SLV KHM HND 
	
	foreach wbc in `ct' {
		foreach gen in mf m f {
			replace hlo_`gen'_fill_2010=. if wbcode=="`wbc'" & year==2020
			replace hlo_`gen'_lower_2010=. if wbcode=="`wbc'" & year==2020
			replace hlo_`gen'_upper_2010=. if wbcode=="`wbc'" & year==2020
			replace hlo_`gen'_year_2010=. if wbcode=="`wbc'" & year==2020
			replace hlo_`gen'_source_2010="" if wbcode=="`wbc'" & year==2020
			}
		}

	foreach gen in mf m f {
		foreach var in rep lower upper {
			gen p_`gen'_`var'= L11.hlo_`gen'_`var' if year==2020 & hlo_`gen'_source[_n-11]=="PISA" & wbcode=="TTO"
			gen t_`gen'_`var'= L9.hlo_`gen'_`var' if year==2020 & hlo_`gen'_source[_n-9]=="TIMSS/PIRLS" & wbcode=="TTO"
			gen x_`gen'_`var'= ((p_`gen'_`var' + t_`gen'_`var')/2) if year==2020 & wbcode=="TTO"
		}
	}

	foreach gen in mf m f {
		replace hlo_`gen'_fill_2010= x_`gen'_rep if year==2020  & wbcode=="TTO"
		replace hlo_`gen'_lower_2010= x_`gen'_lower if year==2020  & wbcode=="TTO"
		replace hlo_`gen'_upper_2010= x_`gen'_upper if year==2020  & wbcode=="TTO"
		replace hlo_`gen'_source_2010= "PISA+TIMSS/PIRLS" if year==2020  & wbcode=="TTO"
	}

	foreach gen in mf m f {
		replace hlo_`gen'_fill_2010=L13.hlo_`gen'_rep if year==2020 & hlo_`gen'_source[_n-13]=="SACMEQ" & wbcode=="MUS"
		replace hlo_`gen'_lower_2010=L13.hlo_`gen'_lower if year==2020 & hlo_`gen'_source[_n-13]=="SACMEQ" & wbcode=="MUS"
		replace hlo_`gen'_upper_2010=L13.hlo_`gen'_upper if year==2020 & hlo_`gen'_source[_n-13]=="SACMEQ" & wbcode=="MUS"
		replace hlo_`gen'_year_2010=L13.hlo_`gen'_year if year==2020 & hlo_`gen'_source[_n-13]=="SACMEQ" & wbcode=="MUS"
		replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-13] if year==2020 & hlo_`gen'_source[_n-13]=="SACMEQ" & wbcode=="MUS"
	}

	foreach ct in ECU GTM PRY {
		foreach gen in mf m f {
			replace hlo_`gen'_fill_2010=L14.hlo_`gen'_rep if year==2020 & hlo_`gen'_source[_n-14]=="LLECE" & wbcode=="`ct'"
			replace hlo_`gen'_lower_2010=L14.hlo_`gen'_lower if year==2020 & hlo_`gen'_source[_n-14]=="LLECE" & wbcode=="`ct'"
			replace hlo_`gen'_upper_2010=L14.hlo_`gen'_upper if year==2020 & hlo_`gen'_source[_n-14]=="LLECE" & wbcode=="`ct'"
			replace hlo_`gen'_year_2010=L14.hlo_`gen'_year if year==2020 & hlo_`gen'_source[_n-14]=="LLECE" & wbcode=="`ct'"
			replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-14] if year==2020 & hlo_`gen'_source[_n-14]=="LLECE" & wbcode=="`ct'"
		}
	}
	
	
	drop p* q* t* x* fill_* year_* source_*	
	
// Drop non-representative EGRAs in the 2010 cross-section because they can't be compared over time
foreach gen in mf m f {
	replace hlo_`gen'_fill_2010=. if hlo_`gen'_source_2010=="EGRANR"
	replace hlo_`gen'_lower_2010=. if hlo_`gen'_source_2010=="EGRANR"
	replace hlo_`gen'_upper_2010=. if hlo_`gen'_source_2010=="EGRANR"
	replace hlo_`gen'_year_2010=. if hlo_`gen'_source_2010=="EGRANR"
	replace hlo_`gen'_source_2010="" if hlo_`gen'_source_2010=="EGRANR"
	}
	
// Replace EGRA 2009 for The Gambia with EGRA 2011 because the team has said the 2009 test had sampling issues
foreach gen in mf m f {
	replace hlo_`gen'_fill_2010=L9.hlo_`gen'_fill if year==2020 & wbcode=="GMB"
	replace hlo_`gen'_lower_2010=L9.hlo_`gen'_lower if year==2020 & wbcode=="GMB"
	replace hlo_`gen'_upper_2010=L9.hlo_`gen'_upper if year==2020 & wbcode=="GMB"
	replace hlo_`gen'_year_2010=L9.hlo_`gen'_year if year==2020 & wbcode=="GMB"
	replace hlo_`gen'_source_2010=hlo_`gen'_source[_n-9] if year==2020 & wbcode=="GMB"
	}

save "$hlodta_out\hlo_data.dta", replace
save "$hlodta_out\hlo_data_20Aug2020.dta", replace

/*

gen genmiss=.
replace genmiss=1 if inlist(wbcode,"KHM","CAF","KEN","LSO","MWI")
replace genmiss=1 if inlist(wbcode,"MUS","NAM","NPL","SYC","SSD")
replace genmiss=1 if inlist(wbcode,"LKA","SWZ","TJK","UGA","ZMB","ZWE")
br wbcode year hlo_mf_source hlo_mf_rep hlo_m_rep hlo_f_rep ///
	hlo_mf_source_2020 hlo_mf_year_2020 if year>1999 & year<2021 & genmiss==1
