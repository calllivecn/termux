#!/bin/bash

# 0. 需要安装 tightvncserver
# 1. 安装窗口管理 openbox openbox-menu xfce4-terminal
# 2. 需要在 proot-distro 系统的中 .bashrc 中添加启动

# 一共3步
# 初始化工作
if [ ! -d ~/.vnc ];then
    mkdir ~/.vnc
fi


export USER=root
export HOME=/root
export DISPLAY=:1


LOCK="/tmp/.X1-lock"
X1="/tmp/.X11-unix/X1"

# 启动vnc
boot(){

if [ -f $LOCK ];then
	#vncserver -kill ${DISPLAY}
	rm -rf "$LOCK"
	rm -rf "$X1"
fi

#vncserver -geometry 600x960 -name remote-desktop -interface ${IP} ${DISPLAY}
vncserver -geometry 600x960 -name remote-desktop ${DISPLAY}
#vncserver -geometry 750x1600 -name remote-desktop ${DISPLAY}
}

# vnc stop
vnc_kill(){
	vncserver -kill ${DISPLAY}
}

boot
