#!/data/data/com.termux/files/usr/bin/bash
# date 2023-01-08 09:05:43
# author calllivecn <c-all@qq.com>


# 目前遇到的问题，
# 1. 只要有两个 以上的进程同时使用就会卡死。
# 2. 直接长期放后台也不行，长期sleep 也会 死。
#
#

PROGRM="termux-tts-speak"
FIFO="$HOME/.tmp/fifo-tts"

if [ -p $FIFO ];then
	:
else
	[ -f $FIFO ] && rm -rv $FIFO
	mkfifo $FIFO
fi

check_service(){
	ps -e -o pid,cmd |grep -v grep |grep -q $PROGRM
}


service(){
	while :
	do
		cat $FIFO
	done | $PROGRM
}

openfile(){
	exec 9<>$FIFO
}

close(){
	exec 9<&-
	exec 9>&-
}


# 解决问题2
service2(){
	openfile
	trap close EXIT

	local text
	while :
	do
		read -t 10 -u 9 text
		if [ $? -eq 0 ];then
			echo "$text"
		else
			break
		fi
	done | $PROGRM
}


if check_service;then
	echo "$@" > $FIFO
else
	service2 &
	#echo "start tts service pid: $!"
	echo "$@" > $FIFO
fi

