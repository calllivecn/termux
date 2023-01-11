# date 2023-01-11 18:27:03
# author calllivecn <c-all@qq.com>


s=0
until [ $(getprop sys.boot_completed) -eq 1 ];
do
	echo "waiting ...  ${s}s"
	sleep $s
	s=$[s + 5]
done


MSG="$(date +%F_%X): 安装时执行的？"

echo $MSG 
ui_print $MSG

echo $MSG >> ${MODPATH}/zx.logs
echo $MSG >> /data/adb/zx.logs

