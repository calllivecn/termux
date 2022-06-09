#!/bin/bash
# date 2021-12-19 01:16:27
# author calllivecn <c-all@qq.com>


# 需要新思路，如果之前的pid不存在，OR pid存在,但cmd不是$program, 说明后台进程被干了。

PROGRAM="${0##*/}"
PROGRAM="${PROGRAM%.sh}"
DIR="$(dirname ${0})"

PIDFILE="${DIR}/${PROGRAM}.pid"
LOG="${DIR}/${PROGRAM}.log"

# 这种方案不行;安卓里被干掉时，类似kill -9 $pid, 进程收不到。
# safe_exit(){
# 	pidfile=$(cat "$PID")
# 	if [ "$pidfile"x = "$$"x ];then
# 		rm -vf "$PID" |tee -a "$LOG"
# 	else
# 		echo "不用删除pid文件"
# 	fi
# }
# 
# trap safe_exit EXIT

# 这里查看后台进程是否被干掉。
JobScheduler(){
	if [ -f "$PIDFILE" ];then
		pid="$(cat $PIDFILE)"
		if ps -h -f -p "$pid" 2>/dev/null |grep -v grep |grep -q "$program" ;then
			echo "job scheduler 成功，本次退出... pid:$$"
			echo "job scheduler 成功，本次退出... pid:$$" >> "$LOG"
			exit 0
		else
			echo "$$" > "$PIDFILE"
			echo "本次重新启动：$(date +%F-%R) ... pid:$$"
			echo "本次重新启动：$(date +%F-%R) ... pid:$$" >> "$LOG"
		fi
	else
		# 正常启动
		echo "$$" > "$PIDFILE"
		echo "本次正常启动：$(date +%F-%R) ... pid:$$"
		echo "本次正常启动：$(date +%F-%R) ... pid:$$" >> "$LOG"
	fi
}

JobScheduler

check_battery(){
	S="$(termux-battery-status)"
	battery_status="$(echo "$S" |jsonfmt.py -d status)"
	
	if [ "$battery_status"x = "CHARGING"x ];then
		# 看看充到多少了
		B100="$(echo "$S" |jsonfmt.py -d percentage)"
	
		# 是不是在使用无线充电
		wireless="$( echo "$S" |jsonfmt.py -d plugged)"
		if [ "$wireless"x = "PLUGGED_WIRELESS"x ];then

			if [ $B100 -ge 49  ] && [ $B100 -le 51 ];then
				termux-tts-speak "当前手机已经无线充电到50%了。"
				sleep 5
				termux-tts-speak "当前手机已经无线充电到50%了。"
			fi 

			if [ $B100 -ge 79  ] && [ $B100 -le 81 ];then
				termux-tts-speak "当前手机已经无线充电到80%了。"
				sleep 5
				termux-tts-speak "当前手机已经无线充电到80%了。"
			fi 

			if [ $B100 -ge "$1" ];then
				termux-tts-speak "已经无线充电到${B100}%了，可以，也必须要拿开我了。"
				sleep 5
				termux-tts-speak "已经无线充电到${B100}%了，可以，也必须要拿开我了。"
				sleep 5
				termux-tts-speak "已经无线充电到${B100}%了，可以，也必须要拿开我了。"
			fi
		fi
	fi
}

if [ "$1"x == x ];then
	p=95
else
	if [ "$1" -ge 10 ] && [ "$1" -le 95 ];then
		p=$1
	else
		echo "Usage: $program [10~95]"
		exit 1
	fi
fi

while :
do
	check_battery $p
	sleep 180
done

