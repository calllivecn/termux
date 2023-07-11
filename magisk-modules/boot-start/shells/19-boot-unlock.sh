#!/data/data/com.termux/files/usr/bin/bash
# date 2023-07-10 22:35:46
# author calllivecn <c-all@qq.com>

CWD=$(cd $(dirname "${0}");pwd)
cd ${CWD}

# 相接在root 或者shell 用户下运行就行了。

PW_FILE="$CWD/.screen-lock"

# 读取密码, 必须为6位数字
if [ -r "$PW_FILE" ];then
    PW=$(cat "$PW_FILE")
else
    echo "需要配置密码: $PW_FILE"
    exit 1
fi

btn_interval="1"

# 查看屏幕是否是点亮状态:
# mWakefulness=Awake 或 mWakefulness=Asleep
if dumpsys power |grep -q "mWakefulness=Asleep";then

    # 按电源键
    input keyevent 26
    sleep "$btn_interval"

fi

# ~~暂时禁用屏幕输入~~ 没起作用
#wm overscan 0,0,0,0

# 向上滑动
input swipe 100 500 100 100 500
sleep "$btn_interval"

input text "$PW"
sleep "$btn_interval"

# 回车 (输入解锁密码后不需要回车)
#input keyevent 66

# 直接启动功能是安卓 7.0 及以上版本中的一项新功能，它允许应用程序在设备重启后立即运行，
# 而不需要用户首先解锁设备。但是，并不是所有应用程序都可以使用这项功能。
# 应用程序需要针对这项功能进行特殊配置才能使用它。
# 这里需要在开机后,先解锁下,并等3秒后.在锁上.
sleep 3
input keyevent 26


# 恢复 - 暂时禁用屏幕输入
#wm voerscan reset 
