#!/data/data/com.termux/files/usr/bin/bash
# date 2023-01-08 09:05:43
# author calllivecn <c-all@qq.com>
#

PROGRM="termux-tts-speak"
FIFO="$PREFIX/tmp/fifo-tts"

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


if check_service;then
	echo "$@" > $FIFO
else
	service &
	echo "start tts service pid: $!"
	echo "$@" > $FIFO
fi

