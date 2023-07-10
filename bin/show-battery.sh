#!/data/data/com.termux/files/usr/bin/bash
# date 2023-07-10 22:35:46
# author calllivecn <c-all@qq.com>


# 需要 root or shell 权限

while :
do
    echo "==================="
    date "+%F_%X"
    dumpsys battery
    sleep 5
done

