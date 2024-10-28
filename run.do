*The do file executes all the do files to develop HLOs feeding into HCIs.

do "$clone/02_exchangerate/exchange_rates.do"
do "$clone/02_exchangerate/exchange_rates_se.do"
do "$clone/03_HLO/01-1-HLO_MEAN_DSEX_v01.do"
do "$clone/03_HLO/01-2-HLO_MEAN_DSEX_SE_v01.do"
do "$clone/04_HLO-HCI/1_hlo.do"
do "$clone/04_HLO-HCI/2_hlo_prep.do"


