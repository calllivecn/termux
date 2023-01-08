#!/bin/bash

prefix="$HOME/bin"

while :
do
	python $prefix/rshell.py --keyfile .config/ten.json --addr mc.calllive.cc --port 16789 client || echo "$(date +%F-%R) -- 失败"
	sleep 5
	python $prefix/rshell.py --keyfile .config/aliyun.json --addr ip.calllive.cc --port 6789 client || echo "$(date +%F-%R) -- 失败"
	sleep 5
done
