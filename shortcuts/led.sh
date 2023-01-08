#!/bin/bash
# date 2023-01-09 05:56:39
# author calllivecn <c-all@qq.com>

termux-torch on

echo -n "输入时间分钟(默认3分钟后关闭)："
read -t 10 minute

if [ "$minute"x = x ];then
	minute=3
fi

echo "$minute 分钟后关灯。"
sleep $[minute * 60]

termux-torch off
