#!/bin/bash
# date 2021-07-06 19:46:01
# author calllivecn <c-all@qq.com>

END=0

alarm(){
	echo -n "按任意键退出"
	while :
	do
		if [ $END = 1 ];then
			echo "alarm exit"
			break
		fi
		termux-vibrate -d 1000

		read -n 1 -t 1 any_char
		if [ $? -eq 0 ];then
			echo -n "退出"
			END=1
		fi
	done
}

RAND=$[RANDOM%10]

# 19:50
T=1950

# sign
s=$[RANDOM%2]
if [ $s -eq 1 ];then
	T=$[T+s]
else
	T=$[T-s]
fi

# 这里是测试使用
#T="2314"

while :
do
	timestamp=$(date +%H%M)
	if [ "$timestamp" = "$T" ] && [ $END = 0 ];then
		alarm
	elif [ "$timestamp" != "$T" ] && [ $END = 1 ];then
		END=0
	fi
	sleep 10
	#sleep 50
done
