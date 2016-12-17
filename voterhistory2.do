

*cd B:\Business\Data\Ohio\StateWide
*use SWVF_1_44, clear
*keep sos_voterid date_of_birth registration_date primary* general* special*
*tempfile hold
*save `hold', replace
cd B:\Business\Data\Ohio\StateWide
use SWVF_45_88, clear
keep sos_voterid date_of_birth registration_date primary* general* special*
*append using `hold'
tempfile hold
save `hold', replace

clear
gen sos_voterid=""
tempfile voterhistory
save `voterhistory', replace

* List elections by order in which they occur
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
set more off
foreach election in `electionlist' {
	
	*use temp, clear
	use `hold', clear
	keep sos_voterid  date_of_birth registration_date `election'
	gen election="`election'"
	cd B:\Business\Data
	merge m:1 election using electionids
	drop if _merge==2
	drop _merge
	
	gen date_of_election=regexs(4)+"-"+regexs(2)+"-"+regexs(3) if regexm(election, "^([a-z]+)([0-9][0-9])([0-9][0-9])([0-9][0-9][0-9][0-9])$")
	gen doe=date(date_of_election,"YMD")                                              									 								 
	gen dob=date(date_of_birth,"YMD")
	gen dor=date(registration_date, "YMD")
	gen election_type=""
	replace election_type="P" if regexm(election, "primary")
	replace election_type="G" if regexm(election, "general")
	replace election_type="S" if regexm(election, "special")
	
	rename `election' election_partic	
	*drop if `election'==""
	keep sos_voterid doe dob dor election_type election_partic electionid
	compress
	append using `voterhistory'
	save `voterhistory', replace
	desc
}

gen age=doe-dob
* 18*365=6570
gen eligble_age=(age>=6570)
gen eligble_reg=(doe>=dor)
drop age
drop doe dob dor

gen byte vote_ALL=(election_partic!="")

* Identify elections in which a person voted in a republican, democratic, or other primary
gen byte vote_G=(election_partic=="X" & election_type=="G")
gen byte vote_P_D=(election_partic=="D" & election_type=="P")
gen byte vote_P_R=(election_partic=="R" & election_type=="P")
gen byte vote_P_O=(election_partic!="R" & election_partic!="D" & election_type=="P")
gen byte vote_P_T=vote_P_D+vote_P_R+vote_P_O

gen year=year(doe)
gen pres=(year==2000 | year==2004 | year==2008 | year==2012 | year==2016)
gen midt=(year==2002 | year==2006 | year==2010 | year==2014)
drop year

gen byte vote_G_pres=(election_partic=="X" & election_type=="G" & pres==1)
gen byte vote_P_D_pres=(election_partic=="D" & election_type=="P" & pres==1)
gen byte vote_P_R_pres=(election_partic=="R" & election_type=="P" & pres==1)
gen byte vote_P_O_pres=(election_partic!="R" & election_partic!="D" & election_type=="P" & pres==1)
gen byte vote_P_T_pres=vote_P_D_pres+vote_P_R_pres+vote_P_O_pres

gen byte vote_G_midt=(election_partic=="X" & election_type=="G" & midt==1)
gen byte vote_P_D_midt=(election_partic=="D" & election_type=="P" & midt==1)
gen byte vote_P_R_midt=(election_partic=="R" & election_type=="P" & midt==1)
gen byte vote_P_O_midt=(election_partic!="R" & election_partic!="D" & election_type=="P" & midt==1)
gen byte vote_P_T_midt=vote_P_D_midt+vote_P_R_midt+vote_P_O_midt

drop year pres midt election_partic election_type

* Compute the running totals of how many times a person voted in each primary type
sort sos_voterid electionid
bysort sos_voterid: gen byte cum_vote_G = sum(vote_G)
bysort sos_voterid: gen byte cum_vote_P_D = sum(vote_P_D)
bysort sos_voterid: gen byte cum_vote_P_R = sum(vote_P_R)
bysort sos_voterid: gen byte cum_vote_P_O = sum(vote_P_O)
bysort sos_voterid: gen byte cum_vote_P_T = sum(vote_P_T)

bysort sos_voterid: gen byte cum_vote_G_pres = sum(vote_G_pres)
bysort sos_voterid: gen byte cum_vote_P_D_pres = sum(vote_P_D_pres)
bysort sos_voterid: gen byte cum_vote_P_R_pres = sum(vote_P_R_pres)
bysort sos_voterid: gen byte cum_vote_P_O_pres = sum(vote_P_O_pres)
bysort sos_voterid: gen byte cum_vote_P_T_pres = sum(vote_P_T_pres)

bysort sos_voterid: gen byte cum_vote_G_midt = sum(vote_G_midt)
bysort sos_voterid: gen byte cum_vote_P_D_midt = sum(vote_P_D_midt)
bysort sos_voterid: gen byte cum_vote_P_R_midt = sum(vote_P_R_midt)
bysort sos_voterid: gen byte cum_vote_P_O_midt = sum(vote_P_O_midt)
bysort sos_voterid: gen byte cum_vote_P_T_midt = sum(vote_P_T_midt)

sort sos_voterid electionid
compress
cd B:\Business\Data
save voterhistory_2, replace



cd B:\Business\Data
use voterhistory, clear

gen date_of_election=regexs(4)+"-"+regexs(2)+"-"+regexs(3) if regexm(election, "^([a-z]+)([0-9][0-9])([0-9][0-9])([0-9][0-9][0-9][0-9])$")
gen doe=date(date_of_election,"YMD")                                              									 								 
gen dob=date(date_of_birth,"YMD")
gen dor=date(registration_date, "YMD")

gen age=doe-dob
* 18*365=6570
gen eligble_age=(age>=6570)
gen eligble_reg=(doe>=dor)

* Idnetify elections in which a person voted in a republican, democratic, or other primary
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
gen score_R = 0.25*voteprop_R + 0.75*affil_R
gen score_D = 0.25*voteprop_D + 0.75*affil_D
gen score_O = 0.25*voteprop_O + 0.75*affil_O


