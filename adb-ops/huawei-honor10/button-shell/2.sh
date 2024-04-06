
touch_on_off(){
    local status torch_dev=/sys/class/leds/torch/brightness
    status=$(cat $torch_dev)
    if [ "$status"x = 1x ];then
        echo 0 > $torch_dev
    elif [ "$status"x = 0x ];then
        echo 1 > $torch_dev
    fi
}

touch_on_off

