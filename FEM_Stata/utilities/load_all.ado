program define load_all
version 10
args keeplist

shell ls *.dta > filelist.txt

file open myfile using filelist.txt, read

file read myfile line
use `line', clear
if "`keeplist'" != "_all" keep `keeplist'

file read myfile line
while r(eof)==0 {
  append using `line'
  if "`keeplist'" != "_all" keep `keeplist'
  file read myfile line
}

file close myfile
rm filelist.txt

end
