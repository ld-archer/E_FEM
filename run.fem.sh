nice -n19 ./FEM $1
rc=$?
export sub=FEM:$HOSTNAME
tail log_info.txt | mail -s $sub $LOGNAME@$HOSTNAME
exit $rc
