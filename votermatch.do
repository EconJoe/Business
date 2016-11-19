
cd B:\Business\Data\Ohio\FranklinCounty\BOE
import delimited "VOTERFILE.txt", clear delimiter(tab) varnames(1)


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

