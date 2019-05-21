if [ -z "$dip1" ]; then
	echo "dip not set..."
	exit -1
fi

[ -z "$TIME" ] && TIME=60
[ -z "$MSG_SIZE" ] && MSG_SIZE='63K'
[ -z "$core" ] && core=0
[ -z "$rcore" ] && rcore=3


ssh $loader1 netperf -H $ip2 -t UDP_STREAM -T $rcore,$core -l $TIME -- -m $MSG_SIZE &
wait