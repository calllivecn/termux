#!/data/data/com.termux/files/usr/bin/bash
# date 2023-01-09 10:44:58
# author calllivecn <c-all@qq.com>


if [ -r $PREFIX/etc/hostname ];then
	export TERMUX_HOSTNAME="$(cat $PREFIX/etc/hostname)"
else
	export TERMUX_HOSTNAME="termux_boot"
fi

bash $HOME/.autostart.d/00-tmux.sh
