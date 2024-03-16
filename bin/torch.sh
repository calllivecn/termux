#!/bin/bash
# date 2024-03-16 22:51:36
# author calllivecn <c-all@qq.com>

# 开关手机上的闪光灯
# 有root 权限就很简单

# 手机指示灯的绿色 /sys/class/leds/green/brightness
# 手机指示灯的红色 /sys/class/leds/red/brightness
# 手机指示灯的蓝色 /sys/class/leds/blue/brightness

# 闪光灯 /sys/class/leds/torch/brightness

light="/sys/class/leds/torch/brightness"

if [ ! -f "$light" ];then
    echo "没有闪光灯：$light"
    exit 1
fi

STATUS=$(cat "$light")

if [ "$1"x = x ];then
    # 切换状态
    if [ "$STATUS"x = 1x ];then
        echo 0 > "$light"
    elif [ "$STATUS"x = 0x ];then
        echo 1 > "$light"
    fi

elif [ "$1"x = "--off"x ] || [ "$1"x = 0x ];then
    if [ "$STATUS"x = 1x ];then
        echo 0 > "$light"
    fi

elif [ "$1"x = "--on"x ] || [ "$1"x = 1x ];then
    if [ "$STATUS"x = 0x ];then
        echo 1 > "$light"
    fi
fi

