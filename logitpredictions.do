

cd B:\Business\Data\Ohio\StateWide
use SWVF_45_88, clear
keep if state_representative_district=="38"
keep sos_voterid
cd B:\Business\Data
merge 1:m sos_voterid using voterhistory_2
drop if _merge==2
drop _merge
sort sos_voterid electionid
drop if electionid>10
save hold, replace

tempfile hold
save `hold', replace

use `hold' if electionid==10, clear
keep sos_voterid vote_ALL
rename vote_ALL target
tempfile hold2
save `hold2', replace

use `hold' if election==9, clear
keep sos_voterid cum_*
merge 1:1 sos_voterid using `hold2'
drop _merge
order sos_voterid target

compress
save temp, replace


use temp, clear
set seed 1234567
chaidforest target, ordered(cum_*)
predict prob
gen pred=(prob1>0.5)
tab target pred, row
gen pred2=(prob1>0.4)
tab target pred2, row

logit target cum_*, r
predict yhat
gen predlog=(yhat>0.5)
tab target predlog, row
gen predlog2=(yhat>0.4)
tab target predlog2, row
gen predlog3=(yhat>0.3)
tab target predlog3, row
gen predlog4=(yhat>0.2)
tab target predlog4, row

tab target pred, row

order sos_voterid target prob* yhat

twoway (kdensity prob1) ///
       (kdensity yhat, lpattern(dash))

compress
save predict, replace
