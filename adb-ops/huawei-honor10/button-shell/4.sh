
# 4: 开关 数据连接
data_on_off(){
    local status
    status=$(settings get global mobile_data)
    if [ "$status"x = 1x ];then
        svc data disable
    elif [ "$status"x = 0x ];then
        svc data enable
    fi
}

data_on_off
