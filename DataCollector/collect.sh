#!/bin/bash

export HOME=/homes/markuze
perf="/homes/markuze/copy/tools/perf/perf"
pcm=/homes/markuze/pcm/
time=5

function collect_cpu {
#	echo " in collect cpu" >&2
	`dirname $0`/collect_net_cpu.pl &
#	echo " out collect cpu" >&2
}

function collect_pstats {
	echo " in collect pstas" >&2
	sudo taskset -c 0 $perf stat -a -B -e cycles,instructions,cache-misses,cache-references sleep $time
	sudo taskset -c 0 $perf stat -a -B -e LLC-store,LLC-store-misses sleep $time
	sudo taskset -c 0 $perf stat -a -B -e LLC-load,LLC-load-misses sleep $time
	echo " out collect pstas" >&2
}

function collect_mem_bw {
	echo " in collect mem bw" >&2
	sudo $pcm/pcm-memory.x -- sleep $time
	echo " out collect mem bw" >&2
}

function collect_functions {
	echo " in collect funcs" #>&2
	sudo taskset -c 0 $perf mem record -e ldlat-loads,ldlat-stores &
	sleep $time
	#sudo pkill perf #$!
	#ps -ef|grep "perf mem"
	#ps -ef|grep "perf mem"|head -2|tail -1|cut -d" " -f 7
	## Magic line to kill perf mem - pkill perf : kills netperf, kill $! : kills something...
	sudo kill `ps -ef|grep "perf mem"|head -2|tail -1|cut -d" " -f 7`
	echo " out collect funcs" #>&2
}

function collect_pcm {
	echo " in collect pcm" >&2
	sudo $pcm/pcm.x -- sleep $time
	sudo $pcm/pcm-pcie.x -- sleep $time
	echo " out collect pcm" >&2
}

[ "$collect_cpu" != "no" ] && collect_cpu
[ "$collect_pstats" != "no" ] && collect_pstats
[ "$collect_mem_bw" != "no" ] && collect_mem_bw
#[ "$collect_functions" != "no" ] && collect_functions
#[ "$collect_pcm" != "no" ] && collect_pcm

wait

#35s

echo "Data collected"
