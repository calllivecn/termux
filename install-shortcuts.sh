#!/bin/bash
# date 2020-06-15 20:34:42
# author calllivecn <c-all@qq.com>


files='datetime.sh
led.sh
liblock.sh
mc-检查-py
sshd
timer.sh
'

DIR=$(dirname "$(pwd)/${0}")

path="${DIR}/shortcuts"


for f in $(ls ${path}/*.sh ${path}/*.py)
do
	cp -vf "$f" ~/.shortcuts/
done
