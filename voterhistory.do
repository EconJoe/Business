
* Construct voter history file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
keep stateid dateofbirth registered s p g v*

rename s S_082016
rename p P_032016
rename g G_112015
rename v34 P_052015
rename v35 G_112014
rename v36 P_052014
rename v37 G_112013
rename v38 P_052013
rename v39 G_112012
rename v40 P_032012
rename v41 G_112011
rename v43 P_052011
rename v44 G_112010
rename v45 P_052010
rename v46 G_112009
rename v47 S_082009
rename v48 P_052009
rename v49 G_112008
rename v50 P_032008
rename v51 G_112007
rename v52 S_082007
rename v53 P_052007
rename v54 L_022007
rename v55 G_112006
rename v56 L_082006
rename v57 P_052006
rename v58 L_022006
rename v59 G_112005
rename v60 P_052005
rename v61 L_022005
rename v62 G_112004
rename v63 P_032004
rename v64 G_112003
rename v65 S_082003
rename v66 L_052003
rename v67 S_022003
rename v68 G_112002
rename v69 S_082002
rename v70 P_052002
rename v71 G_112001
rename v72 S_082001
rename v73 L_052001
rename v74 S_022001
rename v75 G_112000
rename v76 P_032000


* Number of times voted
* Number of times eligible to vote

* Number of times voted in primary
* Number of times voted in Democratic primary
* Number of times voted in Republican Primary

* Number of times voted in primary and then voted in the subsequent general election


* Proportion of times voted in Democratic primaries


* Tranform the data from long to wide
tempfile hold1
save `hold1', replace

clear
gen stateid=""
tempfile hold2
save `hold2', replace

local varlist S_082016 P_032016 G_112015 P_052015 G_112014 P_052014 G_112013 P_052013 G_112012 P_032012 G_112011 P_052011 G_112010 ///
              P_052010 G_112009 S_082009 P_052009 G_112008 P_032008 G_112007 S_082007 P_052007 L_022007 G_112006 L_082006 P_052006 ///
              L_022006 G_112005 P_052005 L_022005 G_112004 P_032004 G_112003 S_082003 L_052003 S_022003 G_112002 S_082002 P_052002 ///
              G_112001 S_082001 L_052001 S_022001 G_112000 P_032000
set more off
foreach var in `varlist' {

	use `hold1', clear
	keep stateid registered dateofbirth `var'
	rename `var' election_partic
	gen election="`var'"
	append using `hold2'
	save `hold2', replace
}

label var election_partic "Participated in election"

gen election_type=regexs(1) if regexm(election, "([PGSL])")
gen election_year=regexs(1) if regexm(election, "([0-9][0-9][0-9][0-9])$")
gen election_month=regexs(1) if regexm(election, "([0-9][0-9])[0-9][0-9][0-9][0-9]$")
destring election_year election_month, replace
sort stateid election_year election_month
compress
cd B:\Business\Data
save panel, replace



cd B:\Business\Data
use panel, clear
tab election_partic election_type

gen vote_A_cnt=(election_partic!="")
gen vote_G_cnt=(election_partic!="" & election_type=="G")
gen vote_P_cnt=(election_partic!="" & election_type=="P")
gen vote_L_cnt=(election_partic!="" & election_type=="L")
gen vote_S_cnt=(election_partic!="" & election_type=="S")

gen vote_P_D_cnt=(election_type=="P" & election_partic=="D")
gen vote_P_R_cnt=(election_type=="P" & election_partic=="R")
gen vote_P_O_cnt=(election_type=="P" & election_partic!="" & election_partic!="D" & election_partic!="R")

collapse (sum) vote_*, by(stateid registered dateofbirth) fast




