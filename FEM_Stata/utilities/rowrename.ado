program rowrename
args row
foreach v of varlist * {
  local vn = `v'[`row']
  label variable `v' "`vn'"
}
drop in `row'
end
