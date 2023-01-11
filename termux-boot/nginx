#!/data/data/com.termux/files/usr/bin/bash
# date 2023-01-09 10:44:58
# author calllivecn <c-all@qq.com>


if [ -r $PREFIX/etc/hostname ];then
	export TERMUX_HOSTNAME="$(cat $PREFIX/etc/hostname)"
else
	export TERMUX_HOSTNAME="termux_boot"
fi

if ps -e -o pid,cmd |grep -v grep |grep nginx |grep -q master > /dev/null 2>&1;then
    echo "nginx 已经启动"
else
    echo "nginx 启动完成"
    tmux -S $HOME/.tmux.sock new-window -t $TERMUX_HOSTNAME -d "nginx"
fi
#########



