
* Construct voter history file
cd B:\Business\Data\Ohio\FranklinCounty\BOE
use VOTERFILE, clear
keep stateid s p g v*


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

drop S_* L_*
* List of general elections
local electionlist_gen G_112015 G_112014 G_112013 G_112012 G_112011 G_112010 ///
                       G_112009 G_112008 G_112007 G_112006 G_112005 G_112004 ///
					   G_112003 G_112002 G_112001 G_112000 

* List of primary elections
local electionlist_prim P_032016 P_052015 P_052014 P_052013 P_032012 P_052011 ///
                        P_052010 P_052009 P_032008 P_052007 P_052006 P_052005 ///
						P_032004 P_052002 P_032000
				   
set more off
foreach election in `electionlist_gen' {
	gen tar_`election'=(`election'!="")
	drop `election'
}

set more off
foreach election in `electionlist_prim' {
	gen tar_`election'=(`election'!="")
	gen tar_`election'_D=(`election'=="D")
	gen tar_`election'_R=(`election'=="R")
	drop `election'
}

sort stateid
compress
cd B:\Business\Data
save votertargetvars, replace
