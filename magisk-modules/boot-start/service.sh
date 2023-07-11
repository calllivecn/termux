# date 2023-01-11 18:27:03
# author calllivecn <c-all@qq.com>

# 当前模块目录
CWD=$(cd "$(dirname "${0}")";pwd)

# 找到/data/adb/ 放日志. CWD 的上级目录
LOG_DIR=$(cd ${CWD}/.. ;pwd)
LOG_DIR=$(cd ${LOG_DIR}/.. ;pwd)

LOGS=${LOG_DIR}/logs

export BOOT_LOG=${LOGS}/boot.log

if [ ! -d $LOGS ];then
    mkdir -p $LOGS
    chmod 0750 $LOGS
fi

log(){
    local d=$(date +%F-%R:%S)
    # ui_print 只在安装时会在app 日志里输出
    #ui_print "$d: $@"
    echo "$d: $@" >> "$BOOT_LOG"
}


until [ "$(getprop sys.boot_completed)"x = 1x ];
do
	log "waiting ..."
	sleep 5
done

log "boot_completed=1"

# 启动 *.sh
for f in ${CWD}/shells/*.sh;
do
	if [ -r $f ];then
        shell=${f##*/}
        prefix_shell=${shell%.sh}
		log "启动 ${shell} ..."
		sh "$f" >> "${CWD}/logs/${prefix_shell}.log" 2>&1 &
	fi
done

