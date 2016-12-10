
clear
set obs 53
gen electionid=_n
gen election=""
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
	local electionid = `electionid'+1
	replace election="`election'" if electionid==`electionid'
}
compress
cd B:\Business\Data
save electionids, replace
