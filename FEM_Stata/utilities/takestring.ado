/** \file
This program takes an existing list, removes a bunch of elements, and then saves the resulting list with a new
global name.

@param[in] oldlist a complete list of variables
@param[in] extlist a list of variables to exclude from oldlist
@param[in] newname the name of the global for the new list
@returns The resulting list (oldlist - extlist) is saved in the global named newname

*/

cap program drop takestring
program define takestring
	version 14.0
	syntax [varlist] [if] [in], oldlist(string) [extlist(string)] newname(string)

	* First make sure oldlist is not empty
	local nword = wordcount("`oldlist'")
	if `nword' == 0 {
		dis "Original varlist is empty"
		exit(333)
	}

	else {
		local eword = wordcount("`extlist'")
		* If not excluding anything, return the old list
		if `eword' == 0 {
			global `newname' `oldlist'
		}
		else {
			* initial list
			unab full : `oldlist'
			* variables to remove
			unab remove : `extlist'
			* remove the variables
			local new: list full - remove
			* return the shortened list
			global `newname' `new'
		}
	}


end
