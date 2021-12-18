#!/bin/bash
# date 2021-08-10 01:10:42
# author calllivecn <c-all@qq.com>


LOG=~/alarm-clock.log
PID=~/alarm-clock.pid

safe_exit(){
	pidfile=$(cat "$PID")
	if [ "$pidfile"x = "$$"x ];then
		rm -vf "$PID" |tee -a "$LOG"
	else
		echo "不用删除pid文件"
	fi
}

trap safe_exit EXIT

if [ -f "$PID" ];then
	echo "job scheduler 成功，本次退出... pid:$$" |tee -a "$LOG"
	exit 0
else
	echo "$$" |tee "$PID"
fi

#python ~/storage/downloads/termux/shortcuts/random-alarm-clock.py
python ~/termux/shortcuts/random-alarm-clock.py
