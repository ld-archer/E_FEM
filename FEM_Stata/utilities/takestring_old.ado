/** \file
This program takes an existing list, removes a bunch of elements, and then saves the resulting list with a new
global name.

@param[in] oldlist a complete list of variables
@param[in] extlist a list of variables to exclude from oldlist
@param[in] newname the name of the global for the new list
@returns The resulting list (oldlist - extlist) is saved in the global named newname

\bug This program does not check for typos in extlist, which would be really handy
*/

cap program drop takestring_old
program define takestring_old
	version 8.0
	syntax [varlist] [if] [in], oldlist(string) [extlist(string)] newname(string)

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
					local new `new' `old'
				}
			}
			
			global `newname'
			global `newname' `new'
		}		
	}


end
