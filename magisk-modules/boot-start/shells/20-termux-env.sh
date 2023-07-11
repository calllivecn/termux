# 启动 termux env


TERMUX_HOME="/data/data/com.termux/files"

if [ -d "$TERMUX_HOME/usr/bin" ];then
    export PATH=$PATH:$COM_TERMUX/usr/bin
fi

CWD=$(cd $(dirname "${0}");pwd)

cd ${CWD}
echo ${CWD}

# 检测是否已安装 bash tmux

if type bash && type tmux;then
    :
else
    echo "需要安装bash 才能正确引导 termux env"
    exit 1
fi

# 查看有没有需要引导的 *.sh
TERMUX_BOOT4ROOT="$TERMUX_HOME/.boot4root"
if ls $TERMUX_BOOT4ROOT/*.sh >/dev/null 2>&1 ;then
    echo "开始引导termux for root 环境 ..."
else
    echo "没有需要开机从root引导的*.sh"
    exit 0
fi

HOME="$TERMUX_HOME/root"


SESSION="daemon"
TMUX_SOCK="$HOME/.tmux.sock"
TMUX_BOOT_LOG="$HOME/.zx/logs/boot.logs"

if [ -d "$HOME/.zx/logs" ];then
    :
else
    mkdir -vp "$HOME/.zx/logs"
fi

log(){
    echo "$(date +%F_%X): $@" >> $TMUX_BOOT_LOG
}

# auto start
auto_start(){
    local i
    for i in $TERMUX_BOOT4ROOT/*.sh;
    do
        if [ -r $i ];then
            if tmux -S $TMUX_SOCK new-window -t "$SESSION" -n "${i##*/}" -d "bash $i" ;then
                 log "boot done --> $i"
            else
                 log "boot fail --> $i"
            fi
        fi
        sleep 1
    done
}

check_tmux_daemon(){
    if tmux -S $TMUX_SOCK list-session -F "#{session_name}" 2>/dev/null |grep -q "$SESSION" ;then
        return 0
    else
        return 1
    fi
}

if check_tmux_daemon;then
    echo "tmux session: $SESSION alread start"
else
    echo "tmux session: $SESSION start done"
    tmux -S $TMUX_SOCK new -s $SESSION -d "bash"
    auto_start
fi




