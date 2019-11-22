cap program drop takestring2
program define takestring2
	version 8.0
	syntax [varlist] [if] [in], oldlist(string) [extlist(string)] newname(string)

*** oldlist: a complete list of variables
*** extlist: a list of variables to exclude from "oldlist"
*** newname: name of the new list of variables generated after removing "extlist" variables
*** Modified on Apr 10, 2008, per Zhutou's request,allow for excluding a word based on partial match
*** For example, if extlist includes "abc", then any word with "abc" in it will be excluded
*** Stupid program

	* First make sure oldlist is not emply
	local nword = wordcount("`oldlist'")
	if `nword' == 0 {
		dis "Non-empty string required for extraction"
		exit(333)
	}
	else {
		local nword = wordcount("`extlist'")
		if `nword' == 0 {
			global `newname'
			global `newname' `oldlist'
		}
		else{
			foreach old in `oldlist' {
				if strpos("`extlist'","`old'") == 0 {
					local i = 0
					foreach ext in `extlist'{
						local i = `i' + strpos("`old'","`ext'")
					}
					if `i' == 0{
						local new `new' `old'
					}
				}
			}
			
			global `newname'
			global `newname' `new'
		}		
	}


end
