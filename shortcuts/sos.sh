#!/bin/bash
# date 2023-01-09 07:25:45
# author calllivecn <c-all@qq.com>


off(){
	termux-torch off
}


trap off EXIT

gettime(){
	python -c 'import time;print(time.time())'
}

timeinterval(){
python <<EOF
print($1 - $2)
EOF
}

avgvalue(){
python <<EOF
print(($1 + $2)/2)
EOF
}

x2(){
python <<EOF
print($1 * 2)
EOF
}

test_interval(){
	for i in $(seq 10)
	do
		t1=$(gettime)
		termux-torch on
		t2=$(gettime)
		interval=$(timeinterval $t2 $t1)
		echo "执行开启的时间: $interval"

		t3=$(gettime)
		termux-torch off
		t4=$(gettime)
		interval=$(timeinterval $t4 $t3)
		echo "执行关闭的时间: $interval"

		t=$(timeinterval $t4 $t1)
		echo "开关一次耗时: $t"
	done
}


avgtime=0
flush(){
	local t1 t2
	t1=$(gettime)
	termux-torch on
	termux-torch off
	t2=$(gettime)

	# 更新平均时间
	if [ $avgtime = "0" ];then
		avgtime=$(timeinterval $t2 $t1)
	else
		t2=$(timeinterval $t2 $t1)
		avgtime=$(avgvalue $avgtime $t2)
	fi
}

flushx2(){
	termux-torch on
	sleep $1
	termux-torch off
}


#test_interval;exit 0

while :;
do
	# S
	flush
	flush
	flush

	# O
	flushx2 $avgtime
	flushx2 $avgtime
	flushx2 $avgtime

	# S
	flush
	flush
	flush
	sleep 3

done
