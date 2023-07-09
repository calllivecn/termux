#!/bin/bash

# machive="localhost:15555" 使用localhost 连接 打不开scrcpy 图形界面。不知道原因
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

adb_tmp=$(mktemp -p /tmp adb-XXXXX.sh)

echo '#!/bin/bash' > "$adb_tmp"
echo 'adb -P 16666 "$@"' >> "$adb_tmp"

chmod +x "$adb_tmp"

#export ADB_TRACE=1
export ADB="$adb_tmp"

trap "rm -v ${adb_tmp}" EXIT

#scrcpy -S -s "${machive}" --power-off-on-close --show-touches --render-driver=software -b 2M --max-fps 8 --max-size 800
# v2.1
scrcpy -S -s "${machive}" --power-off-on-close --show-touches --no-audio --render-driver=software --max-fps 30 --max-size 800

kill_exit

date +%F-%R
