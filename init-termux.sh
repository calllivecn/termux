#!/bin/bash
# date 2019-11-28 02:35:06
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

cp -va config/profile $HOME/.profile

cp -va config/bashrc $HOME/.bashrc

cp -va config/vimrc $HOME/.vimrc

cp -va config/git.globalconfig $HOME/.gitconfig


copy_dir shortcuts $HOME/.shortcuts

[ -d $HOME/.termux ] || mkdir $HOME/.termux

cp -va termux.properties .termux/


if [ -d $HOME/bin ];then
	cp -va termux-backup.sh $HOME/bin
	cp -va liblock.sh $HOME/bin
else
	mkdir -v $HOME/bin
	cp -va termux-backup.sh $HOME/bin
	cp -va liblock.sh $HOME/bin
fi

SOURCES=$PREFIX/etc/apt/sources.list

#if grep -qE "https://termux.org/" $SOURCES;then
#	mv -v $SOURCES "${SOURCES}-bak"
#	echo "deb https://mirrors.tuna.tsinghua.edu.cn/termux stable main" > $SOURCES
#fi


install_deb(){
	apt install $(grep -Ev '^#|^$' termux-packages-backup.txt |tr '\n' ' ')
}

apt update

install_deb

