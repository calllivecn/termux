#!/bin/bash
# date 2019-11-28 00:49:30
# author calllivecn <c-all@qq.com>

termux-torch on

read -t 5 -p "输入时间s(默认30秒)：" seconds

sec=${seconds:-25}

echo "$sec 秒后关灯。"

sleep $sec

termux-torch off
