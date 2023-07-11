# 启动 termux env

CWD=$(cd $(dirname "${0}");pwd)
cd ${CWD}

log(){
    echo "$(date +%F_%X): $@"
    echo "$(date +%F_%X): $@" >> $TMUX_BOOT_LOG >/dev/null 2>&1
}

notexists_make(){
    local d="$1"
    if [ -d "$d" ];then
        :
    else
        mkdir -vp "$d"
    fi
}


TERMUX_HOME="/data/data/com.termux/files"
# 检测5分钟
timeout="false"
for i in $(seq 1 60)
do
    if [ -d "$TERMUX_HOME" ];then
        timeout="true"
        break
    else
        log "等待目录挂载上来。。。"
        sleep 5
    fi
done

if [ "$timeout"x = falsex ];then
    log "可能有问了，${TERMUX_HOME} 目录一直没挂载上来"
    exit 1
fi


# 启动太早了？目录还没挂载上来？
if [ -d "$TERMUX_HOME/usr/bin" ];then
    export PATH=$PATH:$TERMUX_HOME/usr/bin
else
    log "termux app 没有安装？"
    exit 1
fi

log ${CWD}

if type bash && type tmux;then
    :
else
    log "需要安装bash 才能正确引导 termux 环境"
    exit 1
fi

HOME="$TERMUX_HOME/root"
notexists_make "$HOME"

SESSION="daemon4root"

TMUX_SOCK="$HOME/.tmux.sock"

TMUX_BOOT_LOG="$HOME/.zx/logs/boot4root.logs"
notexists_make "$HOME/.zx/logs"


# 查看有没有需要引导的 *.sh
TERMUX_BOOT4ROOT="$HOME/.boot4root"
if ls $TERMUX_BOOT4ROOT/*.sh >/dev/null 2>&1 ;then
    log "开始引导termux for root 环境 ..."
else
    log "没有需要开机从root引导的*.sh"
    exit 0
fi


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
    log "tmux session: $SESSION alread start"
else
    log "tmux session: $SESSION start done"
    tmux -S $TMUX_SOCK new -s $SESSION -d "bash"
    auto_start
fi


