
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






cd B:\Business\Data\Ohio\StateWide
use SWVF_1_44, clear
keep sos_voterid primary* general* special*
tempfile hold
save `hold', replace
use SWVF_45_88, clear
keep sos_voterid primary* general* special*
append using `hold'

local electionlist primary03072000 general11072000 ///
                   special05082001 general11062001 ///
				   primary05072002 general11052002 ///
				   special05062003 general11042003 ///
				   primary03022004 general11022004 ///
				   special02082005 primary05032005 primary09132005 general11082005 ///
				   special02072006 primary05022006 general11072006 ///
				   primary05082007 primary09112007 general11062007 primary11062007 general12112007 ///
				   primary03042008 primary10142008 general11042008 general11182008 ///
				   primary05052009 primary09082009 primary09152009 primary09292009 general11032009 ///
				   primary05042010 primary07132010 primary09072010 general11022010 ///
				   primary05032011 primary09132011 general11082011 ///
				   primary03062012 general11062012 ///
				   primary05072013 primary09102013 primary10012013 general11052013 ///
				   primary05062014 general11042014 ///
				   primary05052015 primary09152015 general11032015 ///
				   primary03152016 general06072016 primary09132016 general11082016

local electionid=0
set more off
foreach election in `electionlist' {

	local electionid=`electionid'+1
	rename `election' election_`electionid'
	gen election_`electionid'_date="`election'"
	
	if (regexm(election_`electionid'_date, "primary")) {
		rename election_`electionid' election_`electionid'_p
		replace election_`electionid'_date=regexs(1) if regexm(election_`electionid'_date, "primary(.*)")
		rename election_`electionid'_date election_`electionid'_p_date
		compress
	}
	else if (regexm(election_`electionid'_date, "general")) {
		rename election_`electionid' election_`electionid'_g
		replace election_`electionid'_date=regexs(1) if regexm(election_`electionid'_date, "general(.*)")
		rename election_`electionid'_date election_`electionid'_g_date
		compress
	}
	else if (regexm(election_`electionid'_date, "special")) {
		rename election_`electionid' election_`electionid'_s
		replace election_`electionid'_date=regexs(1) if regexm(election_`electionid'_date, "special(.*)")
		rename election_`electionid'_date election_`electionid'_s_date
		compress
	}
}
order sos_voterid election_*
compress
cd B:\Business\Data
save electionfile, replace


cd B:\Business\Data
use electionfile, clear
keep sos_voterid *_p *_p_date
local electionids 1 5 9 12 13 16 18 19 21 23 24 27 28 29 30 32 33 34 36 37 39 41 42 43 45 47 48 50 52
	



keep sos_voterid election_1_p election_5_p election_9_p


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


			   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
				   
local electionlist_primary primary03072000 primary05072002 primary03022004 primary05032005 ///
                           primary09132005 primary05022006 primary05082007 primary09112007 ///
						   primary11062007 primary03042008 primary10142008 primary05052009 ///
						   primary09082009 primary09152009 primary09292009 primary05042010 ///
						   primary07132010 primary09072010 primary05032011 primary09132011 ///
						   primary03062012 primary05072013 primary09102013 primary10012013 ///
						   primary05062014 primary05052015 primary09152015 primary03152016 ///
						   primary09132016

local electionlist_general general11072000 general11062001 general11052002 general11042003 ///
                           general11022004 general11082005 general11072006 general11062007 ///
						   general12112007 general11042008 general11182008 general11032009 ///
						   general11022010 general11082011 general11062012 general11052013 ///
						   general11042014 general11032015 general06072016 general11082016
local electionlist_special special05082001 special05062003 special02082005 special02072006
foeach i in `electionlist_primary'

keep `electionlist_primary' `electionlist_general' `electionlist_special'



*ds, has(char primary)

local ds="`r(varlist)'"
foreach i in `ds' {
	display in red "`i'"
}

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

