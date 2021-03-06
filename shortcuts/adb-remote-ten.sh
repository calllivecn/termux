#!/bin/bash
# date 2021-04-23 17:56:20
# author calllivecn <c-all@qq.com>

termux-wake-lock


CONNECT="127.0.0.1:15555"

adb_connect(){

	sleep 5

	while :
	do
		if ssh ten "adb devices" |grep -P "$CONNECT\tdevice";then
			echo -e "\033[32madb 已连接~ $(date "+%F %R:%S")\033[0m"
		else

			echo -e "\033[31madb connect 重试...\033[0m"

			ssh ten "adb disconnect $CONNECT"
			ssh ten "adb connect $CONNECT"

		fi
			
		sleep 300
	done

}


forward(){
	c=0
	while :
	do
		c=$[c + 1]
		echo -e "\033[32mconnect... ten\033[0m"
		ssh -vNR 127.0.0.1:15555:127.0.0.1:15555 ten
		echo -e "\033[32msleep 5...\033[0m"
		sleep 5
		echo -e "\033[31mconnect 断开重连 第${c}次 时间：$(date "+%F %R:%S")\033[0m"
	done
}

adb_connect &

forward
