#!/bin/bash
# date 2019-11-28 02:35:06
# author calllivecn <c-all@qq.com>

PROGRAM_DIR="$(dirname $(pwd)/${0})"


copy(){
	local dir="$(dirname ${2})"

	if [ -d "$dir" ];then
		:
	else
		echo "$dir 目标目录不存在..." >&2
		echo "创建目录 $dir"
		mkdir -v -p "$dri"
		return 
	fi

	if [ -f "$1" ];then
		cp -v "$1" "$2"
	else
		echo "$1 不存在..." >&2
	fi
}

copy_dir(){

	if [ -d "$1" ];then
		echo "$1 要复制的目录不存在..." >&2
		return 
	fi

	if [ -d "$2" ];then
		echo "$2 目标目录不存在..." >&2
		return 
	else
		cp -va "$1" "$2"
	fi
}

update_apt_sources(){
	SOURCES=$PREFIX/etc/apt/sources.list
	
	if grep -qE "https://termux.org/" $SOURCES;then
		mv -v $SOURCES "${SOURCES}-bak"
		echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux stable main" > $SOURCES
	fi
}

#apt update



CONFIG="${PROGRAM_DIR}/config"

copy $CONFIG/profile $HOME/.profile

copy $CONFIG/bashrc $HOME/.bashrc

copy $CONFIG/vimrc $HOME/.vimrc

copy $CONFIG/git.globalconfig $HOME/.gitconfig

copy_dir ${PROGRAM_DIR}/shortcuts $HOME/.shortcuts


[ -d $HOME/.termux ] || mkdir $HOME/.termux

copy ${PROGRAM_DIR}/termux.properties $HOME/.termux/


copy_dir $PROGRAM_DIR/bin/ $HOME/

