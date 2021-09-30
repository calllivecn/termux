#!/bin/bash
# date 2021-09-29 16:34:13
# author calllivecn <c-all@qq.com>

# macive="localhost:15555" 使用localhost 连接 打不开scrcpy 图形界面。不知道原因
machive="10.1.2.6:15555"


if adb -P 16666 devices |grep "${machive}";then
    :
else
    adb -P 16666 connect "${machive}"
fi


echo '#!/bin/bash' | tee adb.sh
echo 'adb -P 16666 "$@"' | tee -a adb.sh
chmod +x ./adb.sh
#export ADB_TRACE=1
export ADB=./adb.sh

trap 'rm -v ./adb.sh' EXIT

scrcpy -S -s "${machive}" --render-driver=software -b 4M --max-fps 15 --max-size 800
