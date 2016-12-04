
cd B:\Business\Data\Ohio\StateWide
import delimited "SWVF_1_44.txt", clear delimiter(comma) varnames(1) stringcols(_all) 
compress
save SWVF_1_44, replace

cd B:\Business\Data\Ohio\StateWide
import delimited "SWVF_45_88.txt", clear delimiter(comma) varnames(1) stringcols(_all)
compress
save SWVF_45_88, replace

cd B:\Business\Data\Ohio\StateWide
use SWVF_1_44, clear
keep sos_voterid date_of_birth registration_date

gen year_of_birth=regexs(1) if regexm(date_of_birth, "^([0-9][0-9][0-9][0-9])-[0-9][0-9]-[0-9][0-9]$")
gen month_of_birth=regexs(1) if regexm(date_of_birth, "^[0-9][0-9][0-9][0-9]-([0-9][0-9])-[0-9][0-9]$")
gen day_of_birth=regexs(1) if regexm(date_of_birth, "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-([0-9][0-9])$")

gen registration_year=regexs(1) if regexm(registration_date, "^([0-9][0-9][0-9][0-9])-[0-9][0-9]-[0-9][0-9]$")
gen registration_month=regexs(1) if regexm(registration_date, "^[0-9][0-9][0-9][0-9]-([0-9][0-9])-[0-9][0-9]$")
gen registration_day=regexs(1) if regexm(registration_date, "^[0-9][0-9][0-9][0-9]-[0-9][0-9]-([0-9][0-9])$")
gen registration_month_day=registration_month+"_"+registration_day
gen count=1
collapse (sum) count, by(registration_month_day) fast
gsort -count



* First names for gender prediction
cd B:\Business\Data\Ohio\StateWide
use SWVF_1_44, clear
keep first_name
tempfile hold
save `hold', replace
cd B:\Business\Data\Ohio\StateWide
use SWVF_45_88, clear
keep first_name
append using `hold'
replace first_name=lower(first_name)
gen first_name_count=1
collapse (sum) first_name_count, by(first_name) fast
gsort -first_name_count
gen first_name_id=_n
keep if first_name_id<=5000
keep first_name
compress
cd B:\Business\Data\Genni
export delimited using "genni_firstnamelist.txt", delimiter(tab) novarnames replace

cd B:\Business\Data\BabyNameGuesser
import delimited "BNG_Harvest.txt", clear delimiter(tab)
rename v1 first_name
rename v2 gender
replace first_name=trim(first_name)
gen female=(gender=="girl")
keep first_name female
tempfile gender
save `gender', replace

* First names for gender prediction
cd B:\Business\Data\Ohio\StateWide
use SWVF_1_44, clear
keep sos_voterid first_name
tempfile hold
save `hold', replace
cd B:\Business\Data\Ohio\StateWide
use SWVF_45_88, clear
keep sos_voterid first_name
append using `hold'
replace first_name=lower(first_name)
merge m:1 first_name using `gender'
sort sos_voterid


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
	replace election=regexs(1) if regexm(election, "primary(.*)")
	append using `demrep'
	save `demrep', replace
}

sort sos_voterid election
compress
cd B:\Business\Data
save demrep, replace

cd B:\Business\Data
use demrep, clear
gen election_year=regexs(1) if regexm(election, "[0-9][0-9][0-9][0-9]([0-9][0-9][0-9][0-9])")
gen election_month=regexs(1) if regexm(election, "([0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]")
gen election_day=regexs(1) if regexm(election, "[0-9][0-9]([0-9][0-9])[0-9][0-9][0-9][0-9]")
destring election_year election_month election_day, replace


gen affil_R=(party_affiliation=="R")
gen affil_D=(party_affiliation=="D")
gen affil_O=(party_affiliation!="R" & party_affiliation!="D")

gen vote_R=(election_partic=="R")
gen vote_D=(election_partic=="D")
gen vote_O=(election_partic!="R" & election_partic!="D")
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
