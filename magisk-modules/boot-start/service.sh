# date 2023-01-11 18:27:03
# author calllivecn <c-all@qq.com>

CWD=${0%/*}
LOGS=${CWD}/logs
BOOT_LOG=${LOGS}/boot.log

if [ ! -d $LOGS ];then
    mkdir -p $LOGS
fi

until [ "$(getprop sys.boot_completed)"x = 1x ];
do
	echo "$(date +%F_%X): waiting ..." >> "$BOOT_LOG"
	sleep 1
done

MSG="$(date +%F_%X): boot_completed=1"

echo $MSG >> "$BOOT_LOG"

# 启动 *.sh
for f in ${CWD}/shells/*.sh;
do
	if [ -r $f ];then
        shell=${f##*/}
        prefix_shell=${shell%.sh}
		echo "启动 ${shell} ..." >> "$BOOT_LOG"
		sh "$f" >> "${CWD}/logs/${prefix_shell}.log" 2>&1 &
	fi
done

