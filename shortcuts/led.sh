#!/bin/bash
# date 2019-11-28 00:49:30
# author calllivecn <c-all@qq.com>

. $HOME/bin/liblock.sh


termux-torch on

read -t 5 -p "输入时间：" seconds

if [ "$seconds"x = x ];then
	sec=25
	echo "$sec 秒后关灯。"
elif [ $seconds -le 30 ];then
	sec=$[ seconds * 60 ]
	echo "$seconds 分钟后关灯。"
elif [ $seconds -gt 30 ];then
	sec=$seconds
	echo "$sec 秒后关灯。"
fi

sleep $sec

termux-torch off
