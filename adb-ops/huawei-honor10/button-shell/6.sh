# 6: 开关 wifi热点

# 电源
KEY_POWER=26
KEY_TAB=61
KEY_ENTER=66
KEY_HOME=3
KEY_MENU=82

KEY_APP_SWITCH=187

KEY_POWER_224=224

KEY_UP=19
KEY_DOWN=20
KEY_LEFT=21
KEY_RIGHT=22

btn_interval=1

# 密码文件
PW="$HOME/.screen-lock"

key(){
    input keyevent $1
    sleep $btn_interval
}

click(){
    input tap "$1" "$2"
    sleep $btn_interval
}

input_text(){
    # 输入锁屏密码
    input text "$1"
    sleep $btn_interval
}

# 点亮屏幕和解锁
unlock_phone(){
    local password
    # 点亮度屏幕
    key $KEY_POWER_224
    
    # 查看没有没有锁屏, 有就先解锁
    if dumpsys window policy | grep -q "mDreamingLockscreen=true";then
        # 向上滑动解锁
        input swipe 0 500 0 100 200
        sleep $btn_interval
        
        # 如果有锁密码的话
        if [ -r "$PW" ];then
            password=$(cat "$PW")
            input_text "$password"
        else
            return 1
        fi

    fi
}

unlock_phone

# 进入wifi热点设置界面
while :;
do
    if am start -n com.android.settings/.TetherSettings 2>&1 |grep -q "Warning: Activity not started";then
        break
    fi
    sleep 1
done

# 改用直接点击坐标的方式
#
# 这是进入“便捷式WLAN热点”的位置
click 640 210

# 这是进入“WLAN热点” 开关的位置
click 640 200

key $KEY_HOME

# 打开最近任务, +清理
key $KEY_APP_SWITCH
input swipe 300 800 300 300 100
key $KEY_HOME

