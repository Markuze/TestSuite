#Config collected info as well

[ -z "$OUT_FILE" ] && OUT_FILE=/tmp/
#rm -rf $OUT_FILE/*

Test=$1
[ -z "$Test" ] && echo "$0 ERROR: not test defined" && exit -1;
[  ! -e "$Test/test.sh" ] && echo "No File" && exit -1

source $Test/config.sh >> $OUT_FILE/test_raw.txt
[ -z "$repeat" ] && repeat=1
[ -z "$DELAY" ] && DELAY=5
[ -z "$TAIL_DELAY" ] && TAIL_DELAY=5

export TIME=40
echo "source $Test/config.sh"

rm -rf $OUT_FILE/result.txt

echo "$date starting ($Test $repeat [$DELAY])"
for i in `seq 1 $repeat`; do
	date=`date +"%H:%M.%S:"`
	export OUT_FILE=$OUT_FILE
	echo "Sock: $SOCK_SIZE"
	echo "$date starting $Test ($i/$repeat)"
	$Test/test.sh >> $OUT_FILE/test_raw.txt &
	testid=$!
	echo "$date $Test/test.sh & $OUT_FILE"
	sleep $DELAY
	sudo OUT_FILE=$OUT_FILE DataCollector/collect_membw.sh &>> $OUT_FILE/result.txt
	cp $OUT_FILE/result.txt $OUT_FILE/result_pcm.txt
	#DataCollector/collect_pcm.sh &>> $OUT_FILE/result_pcm.txt
	# collection is ±40sec
	date=`date +"%H:%M.%S:"`
	echo "$date waiting for test and collector ($Test)"
	sleep $TAIL_DELAY
	sudo pkill netperf
	sudo pkill pktgen
	sleep $TAIL_DELAY
	#	wait ${!}
	date=`date +"%H:%M.%S:"`
	echo "$date running post ($Test)"
	#DataCollector/post_process.sh &>> $OUT_FILE/post.txt
done
date=`date +"%H:%M.%S:"`
echo "$date Done ($Test)"
