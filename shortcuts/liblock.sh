#!/bin/bash
# date 2019-11-29 18:53:39
# author calllivecn <c-all@qq.com>


WAKEUP_LOCK(){

	local APPS WAKEUP_LOCK=$PREFIX/tmp/wakeup.lock

	if [ -f $WAKEUP_LOCK ];then
		APPS=$(cat $WAKEUP_LOCK)
		APPS=$[APPS + 1]
		echo $APPS > $WAKEUP_LOCK
	else
		termux-wake-lock
		echo 1 > $WAKEUP_LOCK
		return
	fi

}

WAKEUP_UNLOCK(){

	local APPS WAKEUP_LOCK=$PREFIX/tmp/wakeup.lock

	if [ -f $WAKEUP_LOCK ];then
		APPS=$(cat $WAKEUP_LOCK)
		APPS=$[APPS - 1]
		echo $APPS > $WAKEUP_LOCK
	else
		echo "ERROR: $WAKEUP_LOCK Not found." >&2
		return 1
	fi

	if [ $APPS -eq 0 ];then
		termux-wake-unlock
		rm $WAKEUP_LOCK
	fi

}


WAKEUP_LOCK

trap WAKEUP_UNLOCK EXIT

