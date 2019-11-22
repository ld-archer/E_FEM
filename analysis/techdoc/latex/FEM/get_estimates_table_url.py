##### Open the link file.
with open("estimates_table_link.tex") as ifile:
	cururl = ifile.read()

##### Extract the URL.
cururl = cururl[5:-1]

##### Interact w/ user to update URL
disptxt = '''\n
The technical documentation is currently using this URL
to link to the estimates table:\n\n''' + cururl + '''\n
If you want to use a different URL, please type it now
and then press Enter/Return. Otherwise, don't type
anything and just press Enter/Return to continue using 
the current URL.\n
New URL: '''

newurl = raw_input(disptxt)

if newurl == "":
	print "\nYou did not type a new URL."
	newurl = cururl
else:
	print "\nThe URL has been updated."

print '''
The technical documentation will use this URL to link 
to the table of estimates:\n\n''' + newurl

#### Overwrite the link file with the URL (new or old).

newurl = "\\url{" + newurl + "}"
with open("estimates_table_link.tex", 'w') as ofile:
	ofile.write(newurl)

print '''
Finished updating link to estimates table. Now you
need to remake (or finish making) the technical
documentation to include the updated URL.
'''
