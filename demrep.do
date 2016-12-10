

* Determine the "Democrat-ness" and the "Republican-ness" of each voter
cd B:\Business\Data\Ohio\StateWide
use SWVF_1_44, clear
keep sos_voterid voter_status party_affiliation primary*
tempfile hold
save `hold', replace
* Determine the "Democrat-ness" and the "Republican-ness" of each voter
cd B:\Business\Data\Ohio\StateWide
use SWVF_45_88, clear
keep sos_voterid voter_status party_affiliation primary*
append using `hold'
save `hold', replace

clear
gen sos_voterid=""
tempfile demrep
save `demrep', replace

local electionlist_primary primary03072000 primary05072002 primary03022004 primary05032005 ///
                           primary09132005 primary05022006 primary05082007 primary09112007 ///
						   primary11062007 primary03042008 primary10142008 primary05052009 ///
						   primary09082009 primary09152009 primary09292009 primary05042010 ///
						   primary07132010 primary09072010 primary05032011 primary09132011 ///
						   primary03062012 primary05072013 primary09102013 primary10012013 ///
						   primary05062014 primary05052015 primary09152015 primary03152016 ///
						   primary09132016

set more off
foreach election in `electionlist_primary' {
	
	use `hold', clear
	keep sos_voterid voter_status party_affiliation `election'
	drop if `election'==""
	rename `election' election_partic
	gen election="`election'"
	*replace election=regexs(1) if regexm(election, "primary(.*)")
	append using `demrep'
	save `demrep', replace
}

sort sos_voterid election
compress
cd B:\Business\Data
save demrep, replace

cd B:\Business\Data
use demrep, clear
replace election="primary"+election
cd B:\Business\Data
merge m:1 election using electionids
drop if _merge==2
drop _merge
order sos_voterid electionid election

* Idnetify elections in which a person voted in a primary
gen vote_R=(election_partic=="R")
gen vote_D=(election_partic=="D")
gen vote_O=(election_partic!="R" & election_partic!="D")
gen vote_T=vote_R+vote_D+vote_O
* Compute the running totals of how many times a person voted in each primary type
sort sos_voterid electionid
bysort sos_voterid: gen cum_vote_R = sum(vote_R)
bysort sos_voterid: gen cum_vote_D = sum(vote_D)
bysort sos_voterid: gen cum_vote_O = sum(vote_O)
bysort sos_voterid: gen cum_vote_T = sum(vote_T)
* Compute running proportions of primary votes
gen voteprop_R=cum_vote_R/cum_vote_T
gen voteprop_D=cum_vote_D/cum_vote_T
gen voteprop_O=cum_vote_O/cum_vote_T

* Identify party affiliation
gen affil_R=(party_affiliation=="R")
gen affil_D=(party_affiliation=="D")
gen affil_O=(party_affiliation!="R" & party_affiliation!="D")

keep sos_voterid electionid election voter_status party_affiliation voteprop_* cum_vote_T affil_*

gen score_R = 0.5*voteprop_R + 0.5*affil_R
gen score_D = 0.5*voteprop_D + 0.5*affil_D
gen score_O = 0.5*voteprop_O + 0.5*affil_O

* Weight the proportions by the total number of times a person has voted. 
* We are more confident about people who have voted many times.
gen score_R = 0.5*voteprop_R + 0.5*affil_R
gen voteprop_weight_R=voteprop_R*cum_vote_T
su voteprop_weight_R, meanonly 
replace voteprop_weight_R = (voteprop_weight_R - r(min)) / (r(max) - r(min)) 
gen score_R = 0.5*voteprop_weight_R + 0.5*affil_R
egen score_R_std = std(score_R)
su score_R_std, meanonly 
replace score_R_std = (score_R_std - r(min)) / (r(max) - r(min)) 

reshape wide voteprop_*


gen election_year=regexs(1) if regexm(election, "[0-9][0-9][0-9][0-9]([0-9][0-9][0-9][0-9])")
gen election_month=regexs(1) if regexm(election, "([0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]")
gen election_day=regexs(1) if regexm(election, "[0-9][0-9]([0-9][0-9])[0-9][0-9][0-9][0-9]")
destring election_year election_month election_day, replace
sort sos_voterid election_year election_month election_day
egen election_id=group(election_year election_month election_day)
order sos_voterid election_id

* Idnetify elections in which a person voted in a primary
gen vote_R=(election_partic=="R")
gen vote_D=(election_partic=="D")
gen vote_O=(election_partic!="R" & election_partic!="D")
gen vote_T=vote_R+vote_D+vote_O
sort sos_voterid election_id
bysort sos_voterid: gen cum_vote_R = sum(vote_R)
bysort sos_voterid: gen cum_vote_D = sum(vote_D)
bysort sos_voterid: gen cum_vote_O = sum(vote_O)
bysort sos_voterid: gen cum_vote_T = sum(vote_T)

* Identify party affiliation
gen affil_R=(party_affiliation=="R")
gen affil_D=(party_affiliation=="D")
gen affil_O=(party_affiliation!="R" & party_affiliation!="D")

gen voteprop_R=cum_vote_R/cum_vote_T
gen voteprop_D=cum_vote_D/cum_vote_T
gen voteprop_O=cum_vote_O/cum_vote_T





collapse (max) affil_* (sum) vote_*, by(sos_voterid voter_status)

gen votetot=vote_R+vote_D+vote_O
gen voteprop_R=vote_R/votetot
gen voteprop_D=vote_D/votetot
gen voteprop_O=vote_O/votetot

egen affil_R_std = std(affil_R)
egen affil_D_std = std(affil_D)
egen affil_O_std = std(affil_O)

egen voteprop_R_std = std(voteprop_R)
egen voteprop_D_std = std(voteprop_D)
egen voteprop_O_std = std(voteprop_O)

gen score_R=(0.5*affil_R_std + 0.5*voteprop_R_std)
su score_R, meanonly 
replace score_R = (score_R - r(min)) / (r(max) - r(min)) 

gen score_D=(0.5*affil_D_std + 0.5*voteprop_D_std)
su score_D, meanonly 
replace score_D = (score_D - r(min)) / (r(max) - r(min))

gen score_O=(0.5*affil_O_std + 0.5*voteprop_O_std)
su score_O, meanonly 
replace score_O = (score_O - r(min)) / (r(max) - r(min))  

hist score_R
hist score_D
reg score_R score_D score_O
twoway (kdensity score_R)


* registration
* number of elections
* most recent elections
