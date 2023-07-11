#!/bin/bash
# date 2022-04-15 06:35:56
# author calllivecn <c-all@qq.com>

CWD="/data/data/com.termux/files"

export PATH=$CWD/home/bin:$CWD/usr/bin:$PATH

export HOME=$CWD/home

unset CWD

bash --init-file $HOME/.bashrc

