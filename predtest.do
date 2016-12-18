

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
cd B:\Business\Data
merge m:1 sos_voterid using icf
drop if _merge==2
drop _merge
save hold, replace

tempfile hold
save `hold', replace

use `hold' if electionid==10, clear
keep sos_voterid vote_ALL
rename vote_ALL target
tempfile hold2
save `hold2', replace

use `hold' if election==9, clear
keep sos_voterid cum_* dob dor voter_status party_affiliation gender
merge 1:1 sos_voterid using `hold2'
drop _merge
order sos_voterid target

cd B:\Business\Data
export delimited using "rftest2", replace

encode voter_status, gen(status)
encode party_affil, gen(party)
encode gender, gen(sex)

logit target cum_*
logit target cum_* dob dor i.status i.party i.sex

logit target cum_*##c.dob cum_*##c.dor i.status i.party i.sex

