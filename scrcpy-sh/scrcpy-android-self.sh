#!/bin/bash

# machive="localhost:15555" 使用localhost 连接 打不开scrcpy 图形界面。不知道原因
machive="10.1.2.6:15555"
machive="127.0.0.1:15555"


if adb -P 16666 devices |grep "${machive}";then
	:
else
	adb -P 16666 connect "${machive}"
fi
	
kill_exit(){
	local scrcpy_server_pid
	scrcpy_server_pid=$(ps -ef |grep "scrcpy.Server" | grep -v grep | awk '{print $2}')
	if [ "$scrcpy_server_pid"x = x ];then
		echo "scrcpy.server normal exit."
	else
		echo "kill scrcpy_server.jar"
		kill "$scrcpy_server_pid"
	fi
}

echo '#!/bin/bash' | tee adb.sh
echo 'adb -P 16666 "$@"' | tee -a adb.sh
chmod +x ./adb.sh
#export ADB_TRACE=1
export ADB="./adb.sh"

trap 'rm -v ./adb.sh' EXIT

#scrcpy -S -s "${machive}" --power-off-on-close --show-touches --render-driver=software -b 2M --max-fps 8 --max-size 800
scrcpy -S -s "${machive}" --power-off-on-close --show-touches --render-driver=software --max-fps 30 --max-size 800
#scrcpy -S -s "${machive}" --power-off-on-close --show-touches --render-driver=metal -b 4M --max-fps 30 --max-size 800

kill_exit

date +%F-%R
