#! /bin/bash

TEST=$1
MEMSLAP=/home/markuze/libmemcached-1.0.18/clients/memaslap
IP=$2
PORT=$3
RCPU=28
TIME=180

CPU_LINE=`nproc`
#` lscpu|grep -P '^CPU\(s\):'|cut -d: -f2`
cfg_file="`dirname $0`/conf.memc"

function set_memcached {

	LOCAL=$1
	mport=$2
        mcore=0
	[ -z "$mport" ] && mport=11211

	for i in `seq 1 $CPU_LINE`; do
		taskset -c $mcore memcached -l $LOCAL:$mport -m 3072 -d -t 1 -I 1M
		let mport++
		let mcore++
	done
}

function lunch_memcslap {

	REMOTE=$1
	port$2
	cpu=`nproc`

	[ -z "$port" ] && port=11211
	if [ -z "$TIME" ]; then
		TIME=40s
	fi

	while [ "$cpu" -gt 0 ];
	do
		rcpu=$RCPU
		while [ "$rcpu" -gt 0 ];
		do
			let cpu--
			let rcpu--
			$MEMSLAP -s $REMOTE:$port  -T 1 -o 0.5 -d 4 --concurrency=128 -t $TIME -F $cfg_file &
			let port++
		done
	done
	wait
}

function cleanup {
	echo "sudo pkill -9 memcached"
	sudo pkill -9 memcached
}

case "$TEST" in

"memcached")
	echo "seting up memcached"
	if [ -z "$IP" ]; then
		echo "usage $0 $TEST <IP>"
	fi
	set_memcached $IP $PORT
    ;;
"memslap")
	echo  "staring memslap"
	if [ -z "$IP" ]; then
		echo "usage $0 $TEST <IP>"
	fi
	lunch_memcslap $IP $PORT
    ;;
"cleanup")
	echo "Cleanup"
	cleanup
	;;
*) 	echo "ERROR : Unsuported switch $1"
   ;;
esac


