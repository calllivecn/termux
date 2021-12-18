#!/bin/bash

# 一共3步

# 初始化工作
if [ ! -d ~/.vnc ];then
    mkdir ~/.vnc
fi
#xrdb $HOME/.Xresources
#startxfce4 &

# init 2 需要 把 xfce4-session 插入/etc/X11/Xsession 的开头

export USER=root
export HOME=/root
export DISPLAY=:1

# 启动vnc
start(){
vncserver -geometry 600x960 -name remote-desktop :1
}

# vnc stop
stop(){
vncserver -kill :1
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1
}

"$1"
