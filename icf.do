
* First names for gender prediction
cd B:\Business\Data\Ohio
use SWVF_1_44, clear
keep sos_voterid date_of_birth first_name last_name registration_date voter_status party_affiliation
tempfile hold
save `hold', replace
use SWVF_45_88, clear
keep sos_voterid date_of_birth first_name last_name registration_date voter_status party_affiliation
append using `hold'

* Process names
gen first_name_=trim(lower(first_name))
* Replace all hyphens with a space
replace first_name_ = subinstr(first_name_, "-", " ", .) 
* Keep only letters and space. This space is for names like "Mary Jo".
* I trimmed above to eliminate leading and lagging whitespace.
egen first_name__ = sieve(first_name_), char(abcdefghijklmnopqrstuvwxyz )
drop first_name_
rename first_name__ first_name_

tempfile hold
save `hold', replace

cd B:\Business\Data\GenderPrediction\BabyNameGuesser
import delimited "BNG_OhioHarvest.txt", clear delimiter(tab) varnames(1)
rename first_name first_name_
merge 1:m first_name_ using `hold'
drop if _merge==1
drop _merge
drop first_name_
replace gender="F" if gender=="girl"
replace gender="M" if gender=="boy"
replace gender="N/A" if gender==""

replace party_affiliation="O" if party_affiliation==""
                                           									 								 
gen dob=date(date_of_birth,"YMD")
gen dor=date(registration_date, "YMD")

keep sos_voterid dob dor voter_status party_affiliation gender
order sos_voterid dob dor voter_status party_affiliation gender
sort sos_voterid

cd B:\Business\Data
save icf, replace
