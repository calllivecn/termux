

# 监听音量键
LISTEN_FILE=/dev/input/event1


# 2:开关手电筒
torch_on_off(){
    local status torch_dev=/sys/class/leds/torch/brightness
    status=$(cat $torch_dev)
    if [ "$status"x = 1x ];then
        echo 0 > $torch_dev
    elif [ "$status"x = 0x ];then
        echo 1 > $torch_dev
    fi
}

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


# 4: 开关 数据连接(没有实测)
data_on_off(){
    local status
    status=$(settings get global wifi_on)
    if [ "$status"x = 1x ];then
        svc wifi disable
    elif [ "$status"x = 0x ];then
        svc wifi enable
    fi
}

getch(){
    # 按下和松开会产生两次
    timeout 2s dd if="$LISTEN_FILE" bs=8192 count=2 of=/dev/null >/dev/null 2>&1
    recode=$?
    if [ $recode -eq 0 ];then
        echo "ok"

    elif [ $recode -eq 124 ];then
        echo "timeout"

    elif [ $recode -eq 125 ];then
        echo "timeout"

    else
        echo "other"
    fi
}

# 振动一次，100ms。
vibrate(){
    echo 100 > /sys/class/leds/vibrator/duration
    echo 1 > /sys/class/leds/vibrator/activate
}

# 执行向量指定
vector(){
    local v=$1

    case $v in
        0)
            :
            ;;
        1)
            echo "为了防误按，向量指令1 忽略。"
            ;;
        2)
            # 开关手电筒
            torch_on_off
            ;;
        3)
            # 开关wifi
            wifi_on_off
            ;;
    esac
}

count=0
while :
do
    result=$(getch)

    if [ "$result"x = "ok"x ];then
        count=$[count + 1]
        echo "音量键被按下一次: ${count}"
        vibrate

    elif [ "$result"x = "timeout"x ];then
        # 说明超时
        echo "如果有指定向量就执行"
        if [ $count -ge 2 ];then
            vector $count
        fi
        count=0
    fi

done
