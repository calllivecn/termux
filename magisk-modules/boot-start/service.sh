# date 2023-01-11 18:27:03
# author calllivecn <c-all@qq.com>

CWD=${0%/*}

until [ "$(getprop sys.boot_completed)"x = 1x ];
do
	echo "$(date +%F_%X): waiting ..." >> ${CWD}/zx.logs
	sleep 1
done


MSG="$(date +%F_%X): boot_completed=1"

echo $MSG 

echo $MSG >> ${CWD}/zx.logs
echo $MSG >> /data/adb/zx.logs

# 启动 *.sh
for f in ${CWD}/ash-shells/*.sh;
do
	if [ -r $f ];then
		echo "启动 ${f} ..."
		sh "$f" &
	fi
done

