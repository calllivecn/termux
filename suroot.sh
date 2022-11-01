#!/bin/bash
# date 2021-06-11 21:49:54
# author calllivecn <c-all@qq.com>

######################
#
# 启动root adbd: su -l -c "/data/data/adbd tcpip:15555" --> ~/.termux/boot/adbd
# 下载地址：https://github.com/evdenis/adb_root
#
######################

CWD="/data/data/com.termux/files"

export PATH=$CWD/home/bin:$CWD/usr/bin:$PATH

#export HOME=$CWD/home
export HOME=$CWD/root
cd $HOME

unset CWD

bash --init-file $HOME/.bashrc
