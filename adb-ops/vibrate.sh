# 一次执行的持续时间范围：默认: 200ms
# echo 1000 > /sys/class/leds/vibrator/duration
# 执行：echo 1 > /sys/class/leds/vibrator/activate
#
vibrate(){
    local duration="$1"
    d=$(cat /sys/class/leds/vibrator/duration)
    count=$[duration*1000/$d]

    for i in $(seq $count)
    do
        echo 1 > /sys/class/leds/vibrator/activate
        sleep $[d/1000]
    done
}


vibrate 5

