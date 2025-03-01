# 启动 ttyd

CWD=$(cd $(dirname "${0}");pwd)
cd ${CWD}

LOG_DIR=$(cd ${CWD}/.. ;pwd)
LOG_DIR=$(cd ${LOG_DIR}/.. ;pwd)

# ~~BOOT_LOG_DIR 来自父脚本 service.sh~~ 
# 来不了，父目录的export 
log(){
    echo "$(date +%F_%X): $@"
}

notexists_make(){
    local d="$1"
    if [ -d "$d" ];then
        :
    else
        mkdir -vp "$d"
    fi
}


TERMUX_HOME="/data/calllivecn"
# 检测5分钟
timeout="false"
for i in $(seq 1 60)
do
    if ls -lh $TERMUX_HOME/.local/bin/ttyd $TERMUX_HOME/.supervisord/;then
        timeout="true"
        export PATH=$TERMUX_HOME/.local/bin:$PATH
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


log ${CWD}

if type ttyd;then
    :
else
    log "需要安装 ttyd 才能正确引导"
    exit 1
fi

# set root in HOME
export HOME="$TERMUX_HOME"
notexists_make "$HOME"

for i in $(seq 1 60)
do
    ttyd -6 -p 57682 -W -S -C $HOME/.supervisord/fullchain.pem -K $HOME/.supervisord/privkey.pem -c "zx:huawei.linux" --cwd $HOME /system/bin/sh && log "ttyd 启动成功"
    if [ $? -ne 0 ];then
        sleep 10
    else
        log "ttyd 退出"
        break
    fi
done

