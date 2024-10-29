*Author: Syedah Aroob Iqbal

/*This do file:
1)	Analyzes item statistics for pilot data.
*/

import excel "N:\GDB\WorldBank_HLO_workingcopy\HLO\2_Step\Learning Losses\input\LLA_PILOT_UZB.xlsx", sheet("Sheet2") firstrow clear
*Bringing in answer key
ren (M0* MP* S0* SP*) (QM0* QMP* QS0* QSP*)
*Two students have same School, Class and Student ID.
reshape long Q, i(SchoolID SectionName ClassID Firstnameofstudent Familynameofstudent StudentID) j(itemid) string
save "N:\GDB\WorldBank_HLO_workingcopy\HLO\2_Step\Learning Losses\input\LLA_PILOT_UZB.dta", replace

import excel "N:\GDB\WorldBank_HLO_workingcopy\HLO\2_Step\Learning Losses\input\Math_Science_UZB_2021.xlsx", sheet("Math 2021") firstrow clear
ren ItemID itemid
drop if missing(itemid)
save "$program\input\items_UZB_Math_2021.dta", replace
merge 1:m itemid using "N:\GDB\WorldBank_HLO_workingcopy\HLO\2_Step\Learning Losses\input\LLA_PILOT_UZB.dta", assert(match using) keep(match) nogen

*Scoring all responses:
gen score = 1 if Q == CorrectResponse


