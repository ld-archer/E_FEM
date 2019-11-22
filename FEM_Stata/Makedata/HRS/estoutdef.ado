*! version 1.00, Ben Jann, 17aug2004

program define estoutdef, rclass
	version 8.2
	syntax anything(id="style name") [ , View Edit STARbang ]
	if ("`view'"!="") + ("`edit'"!="") + ("`starbang'"!="") > 1 {
		di as error "view, edit and starbang are mutually exclusive"
		exit 198
	}
	capture findfile estout_`anything'.def
	if _rc {
		di as error `"`anything' defaults not available (file estout_`anything'.def not found)"'
		exit 601
	}
	local fn `"`r(fn)'"'
	if "`edit'"!="" doedit `"`fn'"'
	else if  "`view'"!="" view `"`fn'"'
	else type `"`fn'"' , `starbang'
	return local fn `"`fn'"'
end
