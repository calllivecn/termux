#!/bin/bash
# date 2019-06-11 14:52:06
# author calllivecn <c-all@qq.com>


PROXY_ADDR="http://192.168.0.3:9999"

URLs="termux.org
dl.bintray.com
"
APT_OPTION=""
for http in $URLs
do
	for scheme in http https
	do
		APT_OPTION="$APT_OPTION -o Acquire::${scheme}::Proxy::${http}=$PROXY_ADDR "
	done
done


if [ "$1"x = "debug"x ];then
	shift
	echo apt $APT_OPTION "$@"
else
	apt $APT_OPTION "$@"
fi

