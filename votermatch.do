

cd B:\Business\Data\Genni
import delimited "data.txt", clear varnames(1)
keep name _2008
split _2008, p(|) gen(p_)
drop _2008
destring p_*, replace
replace name=lower(name)
rename name firstname
compress
tempfile hold
save `hold', replace

* Construct voter history file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
keep firstname
gen count=1
collapse (sum) count, by(firstname)
replace firstname=lower(firstname)
gsort -count
merge 1:1 firstname using `hold'






cd B:\Business\Data\Ohio\FranklinCounty\BOE
import delimited "VOTERFILE.txt", clear delimiter(tab) varnames(1)
compress 
save VOTERFILE, replace


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

cd B:\Business\Data
compress
save temp, replace

tempfile hold
save `hold', replace

clear
gen stateid=""
tempfile hold
save `hold', replace

local varlist S_082016 P_032016 G_112015 P_052015 G_112014 P_052014 G_112013 P_052013 G_112012 P_032012 G_112011 P_052011 G_112010 ///
              P_052010 G_112009 S_082009 P_052009 G_112008 P_032008 G_112007 S_082007 P_052007 L_022007 G_112006 L_082006 P_052006 ///
              L_022006 G_112005 P_052005 L_022005 G_112004 P_032004 G_112003 S_082003 L_052003 S_022003 G_112002 S_082002 P_052002 ///
              G_112001 S_082001 L_052001 S_022001 G_112000 P_032000

foreach var in `varlist' {

	use temp, clear
	keep stateid `var'
	rename `var' partic
	gen election="`var'"
	append using `hold'
	save `hold', replace
}

gen election_type=regexs(1) if regexm(election, "([PGSL])")
gen election_year=regexs(1) if regexm(election, "([0-9][0-9][0-9][0-9])$")
gen election_month=regexs(1) if regexm(election, "([0-9][0-9])[0-9][0-9][0-9][0-9]$")
sort stateid election_year election_month
compress
cd B:\Business\Data
save panel, replace

* Construct voter history file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
keep stateid dateofbirth registered
cd B:\Business\Data
merge 1:m stateid using panel
drop _merge
sort stateid election_year election_month
destring election_year election_month, replace
gen age=election_year-dateofbirth
drop if election_year==2016

gen elec_tot_any=(partic!="")
gen elec_tot_g=(partic!="" & election_type=="G")
gen elec_tot_p=(partic!="" & election_type=="P")
gen elec_tot_s=(partic!="" & election_type=="S")
gen elec_tot_l=(partic!="" & election_type=="L")

gen elec_elig_any=(age>17)
gen elec_elig_g=(election_type=="G" & age>17)
gen elec_elig_p=(election_type=="P" & age>17)
gen elec_elig_s=(election_type=="S" & age>17)
gen elec_elig_l=(election_type=="L" & age>17)

gen elec_last_1_any=(partic!="" & election_year==2015)
gen elec_last_1_g=(partic!="" & election_year==2015 & election_type=="G")
gen elec_last_1_p=(election_year==2015 & election_type=="P")
gen elec_last_1_s=(partic!="" & election_year==2015 & election_type=="S")
gen elec_last_1_l=(partic!="" & election_year==2015 & election_type=="L")

gen elec_last_3_any=partic!="" & (election_year>=2013)
gen elec_last_3_g=(partic!="" & election_year>=2013 & election_type=="G")
gen elec_last_3_p=(partic!="" & election_year>=2013 & election_type=="P")
gen elec_last_3_s=(partic!="" & election_year>=2013 & election_type=="S")
gen elec_last_3_l=(partic!="" & election_year>=2013 & election_type=="L")

gen elec_pres2008_any=(partic!="" & election_year==2008)
gen elec_pres2008_g=(partic!="" & election_year==2008 & election_type=="G")
gen elec_pres2008_p=(partic!="" & election_year==2008 & election_type=="P")
gen elec_pres2008_s=(partic!="" & election_year==2008 & election_type=="S")
gen elec_pres2008_l=(partic!="" & election_year==2008 & election_type=="L")

gen elec_pres2004_any=(partic!="" & election_year==2004)
gen elec_pres2004_g=(partic!="" & election_year==2004 & election_type=="G")
gen elec_pres2004_p=(partic!="" & election_year==2004 & election_type=="P")
gen elec_pres2004_s=(partic!="" & election_year==2004 & election_type=="S")
gen elec_pres2004_l=(partic!="" & election_year==2004 & election_type=="L")

gen elec_pres2000_any=(partic!="" & election_year==2000)
gen elec_pres2000_g=(partic!="" & election_year==2000 & election_type=="G")
gen elec_pres2000_p=(partic!="" & election_year==2000 & election_type=="P")
gen elec_pres2000_s=(partic!="" & election_year==2000 & election_type=="S")
gen elec_pres2000_l=(partic!="" & election_year==2000 & election_type=="L")


collapse (sum) elec_*, by(stateid)
compress
cd B:\Business\Data
save votinghistory, replace

* Construct voter history file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
cd B:\Business\Data
merge 1:1 stateid using votinghistory
drop _merge
gen outcome=(p!="")
gen age=2016-dateofbirth

reg outcome age c.age#c.age elec_*
logit outcome age c.age#c.age elec_*

cd B:\Business\Data\Ohio\FranklinCounty\BOE
import delimited "VOTERFILE.txt", clear delimiter(tab) varnames(1)
keep stateid registered lastname firstname status party dateofbirth res_zip precinctsplit
drop if stateid=="OH0017278327"
* Strip the time element that is contained in some of the registered entries.
replace registered=regexs(1) if regexm(registered, "([0-9]+/[0-9]+/[0-9]+)")
gen registered_date = date(registered, "MDY")
gen registered_year=year(registered_date)
gen registered_month=month(registered_date)
gen registered_day=day(registered_date)
gen registered_age=registered_year-dateofbirth

cd B:\Business\Data
merge 1:m stateid using panel
drop if _merge==2
drop _merge
order stateid partic election election_type election_year election_month age
sort stateid election_year election_month

destring election_year, replace
gen age=election_year-dateofbirth
drop if age>100
drop if age<17



cd C:\Users\JoeS\Desktop
import delimited "Test.txt", clear delimiter(comma) varnames(1)

keep voterid res_house res_street res_apt
rename res_house house
rename res_street street
rename res_apt apt

tostring house, replace
replace house=lower(house)
replace street=lower(street)
replace apt=lower(apt)
replace house=trim(house)
replace street=trim(street)
replace apt=trim(apt)

gen streetname=regexs(1) if regexm(street, "(.*) ([a-z]+)?")
gen streetsuffix=regexs(2) if regexm(street, "(.*) ([a-z]+)?")
drop street

egen streetname_=sieve(streetname), char(abcdefghijklmnopqrstuvwxyz0123456789 )
drop streetname
rename streetname_ streetname
drop if streetname==""

tempfile hold
save `hold', replace



cd C:\Users\JoeS\Desktop
import delimited "parcel.csv", clear delimiter(comma) varnames(1)

keep if regexm(mailad4, "43209") | regexm(owner_add2, "43209") | zip_code==43209
keep pid mailad3

rename mailad3 address
replace address=lower(address)
replace address=trim(address)
egen address_=sieve(address), char(abcdefghijklmnopqrstuvwxyz0123456789 )
drop address
rename address_ address
replace address=" "+address+" "

drop if address=="  "
drop if regexm(address, "po box")

gen house=""
replace house=regexs(1) if regexm(address, "^ ([0-9]+) ")

gen misc=""
replace misc=regexs(2) if regexm(address, " (rd)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (st)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (pl)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (ave)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (dr)( .*) ?")
replace misc=regexs(2) if regexm(address, " (ct)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (ln)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (blvd)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (pkwy)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (loop)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (ctr)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (sq)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (hwy)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (way)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (cir)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (trl)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (fwy)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (path)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (pike)( .* ) ?")
replace misc=regexs(2) if regexm(address, " (plz)( .* ) ?")


gen streetsuffix=""
replace streetsuffix=regexs(1) if regexm(address, "( rd )")
replace streetsuffix=regexs(1) if regexm(address, "( st )")
replace streetsuffix=regexs(1) if regexm(address, "( pl )")
replace streetsuffix=regexs(1) if regexm(address, "( ave )")
replace streetsuffix=regexs(1) if regexm(address, "( dr )")
replace streetsuffix=regexs(1) if regexm(address, "( ct )")
replace streetsuffix=regexs(1) if regexm(address, "( ln )")
replace streetsuffix=regexs(1) if regexm(address, "( blvd )")
replace streetsuffix=regexs(1) if regexm(address, "( pkwy )")
replace streetsuffix=regexs(1) if regexm(address, "( loop )")
replace streetsuffix=regexs(1) if regexm(address, "( ctr )")
replace streetsuffix=regexs(1) if regexm(address, "( sq )")
replace streetsuffix=regexs(1) if regexm(address, "( hwy )")
replace streetsuffix=regexs(1) if regexm(address, "( way )")
replace streetsuffix=regexs(1) if regexm(address, "( cir )")
replace streetsuffix=regexs(1) if regexm(address, "( trl )")
replace streetsuffix=regexs(1) if regexm(address, "( fwy )")
replace streetsuffix=regexs(1) if regexm(address, "( path )")
replace streetsuffix=regexs(1) if regexm(address, "( pike )")
replace streetsuffix=regexs(1) if regexm(address, "( plz )")

gen streetname=""
replace streetname=address
replace streetname=subinstr(streetname, house, "", .) if house!=""
replace streetname=subinstr(streetname, misc, "", .) if misc!=""
replace streetname=subinstr(streetname, streetsuffix, "", .) if streetsuffix!=""

replace house=trim(house)
replace streetname=trim(streetname)
replace streetsuffix=trim(streetsuffix)
replace misc=trim(misc)
keep pid house streetname streetsuffix misc
order pid house streetname streetsuffix misc

gen id=_n

compress

reclink streetname streetsuffix house using `hold', gen(myscore) idmaster(id) idusing(voterid) required(house) wmatch(10 1 1)




keep pid mailad3 owner_add1
gen ownerocc=(mailad3==owner_add1)

