
# 3: 开关 wifi
wifi_on_off(){
    local status
    status=$(settings get global wifi_on)
    if [ "$status"x = 1x ];then
        svc wifi disable
    elif [ "$status"x = 0x ];then
        svc wifi enable
    fi
}

wifi_on_off

