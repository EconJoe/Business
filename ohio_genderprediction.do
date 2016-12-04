
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
replace first_name=trim(first_name)
* Replace all hyphens with a space
replace first_name = subinstr(first_name, "-", " ", .) 
* Keep only letters and space. This space is for names like "Mary Jo".
* I trimmed above to eliminate leading and lagging whitespace.
egen first_name_ = sieve(first_name), char(abcdefghijklmnopqrstuvwxyz )
gen first_name_count=1
collapse (sum) first_name_count, by(first_name) fast
gsort -first_name_count
keep first_name
compress
cd B:\Business\Data\GenderPrediction
export delimited using "ohio_firstnamelist.txt", delimiter(tab) novarnames replace
