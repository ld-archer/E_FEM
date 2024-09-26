mpiexec -n 10 ./FEM $1
rc=$?
export sub=FEM:$HOSTNAME
tail log_error.txt | mail -s $sub $LOGNAME@$HOSTNAME
exit $rc
