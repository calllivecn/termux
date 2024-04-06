
# 5: 开关 蓝牙
bluetooth_on_off(){
    local status
    status=$(settings get global bluetooth_on)
    if [ "$status"x = 1x ];then
        svc bluetooth disable
    elif [ "$status"x = 0x ];then
        svc bluetooth enable
    fi
}

bluetooth_on_off
