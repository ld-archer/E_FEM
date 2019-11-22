#!/bin/bash
# This is a quicky program to run SAS and display pertinent log results that wouldn't throw an error.
# Make sure that all SAS system options get specified after the sas script name. This script assumse that the first argument is the name of the file to run.

# workopt="-work /tmp"
t=`expr $HOSTNAME : sch`
if [ $t -ne 0 ]
then
    workopt=" "
fi
set -e
# nice sas $workopt -rsasuser "$@"
nice sas -rsasuser "$@"
set +e
grep -iE "uninitialized|WARNING|ERROR|Invalid" ${1%sas}log
let $?
exit 
