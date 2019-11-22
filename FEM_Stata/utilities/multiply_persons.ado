program define multiply_persons
args efactor

scalar expansion_factor=`efactor'
scalar expansion_size=round(log10(expansion_factor)) + 1

if(expansion_factor != 1) {
  expand expansion_factor
  replace weight = weight / expansion_factor
  bys hhidpn: replace hhid = hhid * 10^expansion_size + (_n-1)
  bys hhidpn: replace hhidpn = hhidpn * 10^expansion_size + (_n-1)

  foreach v of varlist hhid hhidpn {
    qui sum `v'
    local max = r(max)
    local max = round(log10(`max')) + 2
    format %`max'.0g `v'
  }
}

end
