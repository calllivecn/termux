# date 2023-01-11 18:27:03
# author calllivecn <c-all@qq.com>

CWD=${0%/*}

LOG=${CWD}/zx.logs

until [ "$(getprop sys.boot_completed)"x = 1x ];
do
	echo "$(date +%F_%X): waiting ..." >> "$LOG"
	sleep 1
done


MSG="$(date +%F_%X): boot_completed=1"

echo $MSG 

echo $MSG >> "$LOG"
echo $MSG >> /data/adb/zx.logs

# 启动 *.sh
for f in ${CWD}/shells/*.sh;
do
	if [ -r $f ];then
		echo "启动 ${f} ..." >> "$LOG"
		sh "$f" &
	fi
done

