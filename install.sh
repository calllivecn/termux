#!/bin/bash
# date 2019-11-25 19:03:23
# author calllivecn <c-all@qq.com>


copy(){
	if [ -d "$2" ];then
		:
	else
		echo "$2 目标目录不存在..." >&2
		return 
	fi

	if [ -f "$1" ];then
		install -m0644 "$1" $HOME/
	else
		echo "$1 不存在..." >&2
	fi
}

copy_dir(){
	if [ -d "$1" ];then
		echo "$1 目录不存在..." >&2
		return 
	fi

	if [ -d "$2" ];then
		echo "$2 目标目录不存在..." >&2
		return 
	else
		cp -va "$1" "$2"
	fi
}

copy config/profile $HOME/.profile

copy config/bashrc $HOME/.bashrc

copy config/vimrc $HOME/.vimrc

copy config/git.globalconfig $HOME/.gitconfig


copy_dir shortctus $HOME/.shortctus

if [ -d $HOME/bin ];then
	copy termux-backup.sh $HOME/bin
else
	mkdir -v $HOME/bin
	copy termux-backup.sh $HOME/bin
fi

