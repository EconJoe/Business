
cd B:\Business\Data\Ohio\StateWide
import delimited "SWVF_1_44.txt", clear delimiter(comma) varnames(1)
compress
save SWVF_1_44, replace

cd B:\Business\Data\Ohio\StateWide
import delimited "SWVF_45_88.txt", clear delimiter(comma) varnames(1)
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
keep if first_name_id<=100
keep first_name
compress
cd B:\Business\Data\Genni
export delimited using "genni_firstnamelist.txt", delimiter(tab) novarnames replace



