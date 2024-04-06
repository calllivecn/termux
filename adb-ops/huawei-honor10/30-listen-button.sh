

# 监听音量键(不同安卓版本，或者，不同手机都需要实测后使用)
LISTEN_FILE="/dev/input/event1"

BUTTON_SHELL_DIR="$HOME/.30-listen-button"

VIBRATE_DURATION_DEV=/sys/class/leds/vibrator/duration
VIBRATE_ACTIVATE_DEV=/sys/class/leds/vibrator/activate


log(){
    local t=$(date +%F_%T)
    echo "${t}:" "$@"
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
    echo 100 > "$VIBRATE_DURATION_DEV"
    echo 1 > "$VIBRATE_ACTIVATE_DEV"
}

# 向量指令执行成功时
vector_ok(){
    echo 500 > "$VIBRATE_DURATION_DEV"
    echo 1 > "$VIBRATE_ACTIVATE_DEV"
}

# 向量指令执行失败时
vector_fail(){

    echo 100 > "$VIBRATE_DURATION_DEV"

    local c=0
    while [ $c -lt 3 ];
    do
        echo 1 > "$VIBRATE_ACTIVATE_DEV"
        sleep 0.2
        
        c=$[c+1]
    done
}


# 没有对应指令时
vector_command_not_found(){
    echo 3000 > "$VIBRATE_DURATION_DEV"
    echo 1 > "$VIBRATE_ACTIVATE_DEV"
}

# 执行向量指定
vector(){
    local v=$1
    local vector_sh="${BUTTON_SHELL_DIR}/${v}.sh"

    if [ -r "${vector_sh}" ];then

        bash "${vector_sh}"
        if [ $? -eq 0 ];then
            vector_ok
        else
            vector_fail
        fi

    else
        # 如果没有对应的指令向量。
        vector_command_not_found
    fi

}

count=0
while :
do
    result=$(getch)

    if [ "$result"x = "ok"x ];then
        count=$[count + 1]
        log "音量键被按下一次: ${count}"
        vibrate

    elif [ "$result"x = "timeout"x ];then
        # 说明超时, 可能是指令
        if [ $count -ge 2 ];then
            log "调用向量: $count"
            vector $count
        fi
        count=0
    fi

done
