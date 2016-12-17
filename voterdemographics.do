
* Construct voter demographics file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
keep stateid lastname firstname middle suffix dateofbirth

gen firstnamecount=1
collapse (sum) firstnamecount, by(firstname)
gsort -firstnamecount
