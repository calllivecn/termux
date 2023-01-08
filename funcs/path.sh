#!/bin/bash
# date 2023-01-09 03:40:24
# author calllivecn <c-all@qq.com>

if echo $PATH |tr ':' '\n' |grep -q $HOME/bin;then
	:
else
	export PATH=$HOME/bin:$PATH
fi
