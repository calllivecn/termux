#!/bin/bash

# 一共3步

# 初始化工作
if [ ! -d ~/.vnc ];then
    mkdir ~/.vnc
fi
#xrdb $HOME/.Xresources
#startxfce4 &

# init 2 需要 把 xfce4-session 插入/etc/X11/Xsession 的开头

IP="10.1.2.6"

export USER=root
export HOME=/root
export DISPLAY=:1


LOCK="/tmp/.X1-lock"
X1="/tmp/.X11-unix/X1"

check(){
	ss -tnlp 2>/dev/null |grep -q ':5901'
}

# 启动vnc
boot(){

if [ -f $LOCK ];then
	vncserver -kill ${DISPLAY}
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
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1
}

if ! check;then
	boot
fi
