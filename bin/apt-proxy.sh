#!/bin/bash
# date 2019-06-11 14:52:06
# author calllivecn <c-all@qq.com>


PROXY_ADDR="http://127.0.0.1:9999"
PROXY_ADDR="http://192.168.13.105:9999"

URLs="termux.org
dl.bintray.com"

APT_OPTION=""

apt_proxy(){
	for http in $URLs
	do
		for scheme in http https
		do
			APT_OPTION="$APT_OPTION -o Acquire::${scheme}::Proxy::${http}=$PROXY_ADDR "
		done
	done
}

apt_ignore(){
	for http in $URLs
	do
		for scheme in http https
		do
			APT_OPTION="$APT_OPTION -o Acquire::${scheme}::Proxy::${http}=$PROXY_IGNORE "
		done
	done
}



if [ "$1"x = "debug"x ];then
	shift
	echo apt $APT_OPTION "$@"

elif [ "$1"x = "ignore"x ];then
	shift
	apt_ignore
	apt $APT_OPTION "$@"

else
	apt_proxy
	apt $APT_OPTION "$@"
fi

