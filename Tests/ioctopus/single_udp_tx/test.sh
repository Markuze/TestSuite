if [ -z "$dip1" ]; then
	echo "dip not set..."
	exit -1
fi

[ -z "$TIME" ] && TIME=60
[ -z "$MSG_SIZE" ] && MSG_SIZE='63K'
[ -z "$core" ] && core=0
[ -z "$rcore" ] && rcore=3


netperf -H $dip2 -t UDP_STREAM -T $core,$rcore -l $TIME -- -m $MSG_SIZE &
wait