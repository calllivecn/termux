#!/bin/bash
# date 2019-11-28 02:35:06
# author calllivecn <c-all@qq.com>

SOURCES=$PREFIX/etc/apt/sources.list

if [ -f $SOURCES ];then
	mv -v $SOURCES "${SOURCES}-bak"
fi

echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux stable main" > $SOURCES

apt update
