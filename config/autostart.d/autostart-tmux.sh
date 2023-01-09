#!/bin/bash
# date 2023-01-09 10:44:58
# author calllivecn <c-all@qq.com>

SESSION=$TERMUX_HOSTNAME
if [ "$UID"x != "0"x ];then
    if tmux -S $HOME/.tmux.sock list-session 2>/dev/null |cut -d':' -f1 |grep -q $SESSION > /dev/null 2>&1;then
        echo "tmux session: $SESSION 已经启动"
    else
        echo "tmux session: $SESSION 启动完成"
        #tmux -S $HOME/.tmux.sock new -s $SESSION -d bash
        tmux -S $HOME/.tmux.sock new -s $SESSION -d proot-distro login ubuntu
    fi
fi
unset SESSION
#########


