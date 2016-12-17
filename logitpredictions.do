

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
