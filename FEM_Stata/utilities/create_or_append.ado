program create_or_append
	* TWO PITFALLS: 
		* This program's use should be preceded by a command of the form "capture rm `destination'.
		* Use the full filename, with .dta suffix.
			* Otherwise the "confirm file" command will always fail, causing overwrite without accumulation.
		* Note that neither of these is a problem when using a tempfile.
	args destination
	capture confirm file `destination'
		* determine whether that file already exists
	if _rc==0 {
		* in this case, it does already exist
		append using `destination'
		if(floor(c(version))>=14) {
			saveold `destination',replace v(12)
		}
		else{
			saveold `destination',replace
		}
	}
	else {
		if(floor(c(version))>=14) {
			saveold `destination',replace v(12)
		}
		else{
			saveold `destination',replace
		}
	}
end
