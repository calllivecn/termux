#!/bin/bash
# date 2023-01-13 21:04:22
# author calllivecn <c-all@qq.com>

SESSION="daemon"
TMUX_SOCK=$HOME/.tmux.sock
TMUX_BOOT_LOG="$HOME/.zx/logs/boot.logs"

log(){
    echo "$(date +%F_%X): $@" >> $TMUX_BOOT_LOG
}

# auto start
auto_start(){
    local i
    for i in $HOME/.autostart.d/*.sh;
    do
        if [ -r $i ];then
            if tmux -S $TMUX_SOCK new-window -t "$SESSION" -d "bash $i" ;then
                 log "$i boot done"
            else
                 log "$i boot fail"
            fi
        fi
    done
}

if [ "$UID"x != "0"x ];then
    if tmux -S $TMUX_SOCK list-session -F "#{session_name}" 2>/dev/null |grep -q "$SESSION" ;then
        echo "tmux session: $SESSION alread start"
    else
        echo "tmux session: $SESSION start done"
        tmux -S $TMUX_SOCK new -s $SESSION -d "bash"
        auto_start
    fi
fi


