# 启动 supervisord

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
    if [ -d "$TERMUX_HOME" ];then
        timeout="true"
        break
    else
        log "等待: ${TERMUX_HOME}目录挂载上来。。。"
        sleep 5
    fi
done

if [ "$timeout"x = falsex ];then
    log "可能有问了，${TERMUX_HOME} 目录一直没挂载上来"
    exit 1
fi


# 启动太早了？目录还没挂载上来？
if [ -d "$TERMUX_HOME/.local/bin" ];then
    export PATH=$TERMUX_HOME/.local/bin:$PATH
else
    log "termux app 没有安装？"
    exit 1
fi


log ${CWD}
timeout="false"
for i in $(seq 1 60)
do
    if type supervisord;then
        timeout="true"
        log "在PATH中找到了 supervisord"
        break
    else
        ls -lh $TERMUX_HOME/.local/bin/
        log "需要安装 supervisord 才能正确引导"
	sleep 5
    fi
done

if [ "$timeout"x = falsex ];then
    log "可能有问了，supervisord 可以执行文件一直没有好:"
    exit 1
fi

# 还是需要把TERMUX_HOME_USR_BIN 添加到 PATH
export PATH=/data/data/com.termux/files/usr/bin:$PATH


# set root in HOME
export HOME="$TERMUX_HOME"
notexists_make "$HOME"

export SUPERVISORD_ROOT="$HOME/.supervisord"
notexists_make "$SUPERVISORD_ROOT"

#export TMP="$TERMUX_HOME/usr/tmp/"

export LD_LIBRARY_PATH=$HOME/.stow/supervisor/libso
supervisord -c "$SUPERVISORD_ROOT/supervisord.ini" && log "supervisord 启动成功"

