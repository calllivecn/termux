#!/bin/bash
# date 2021-06-13 03:43:01
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

while :
do
	echo "$(date +%F-%R)" |tee -a "$LOG"
	sleep 60
done
