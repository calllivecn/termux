#!/bin/bash
# date 2024-07-20 22:07:59
# author calllivecn <calllivecn@outlook.com>


###################
#
# 配置区
# 设备环境：xiaomi11 miui11 android13
# 
###################


# 配置电池位置
BATTERY_UEVENT=/sys/class/power_supply/battery/uevent

# 配置充电暂停开头 miui11
CHARGER_OFF="echo 0 > /sys/devices/platform/soc/soc:qcom,pmic_glink/soc:qcom,pmic_glink:qcom,battery_charger/power_supply/battery/constant_charge_current"
CHARGER_ON="echo 5850000 > /sys/devices/platform/soc/soc:qcom,pmic_glink/soc:qcom,pmic_glink:qcom,battery_charger/power_supply/battery/constant_charge_current"


#在让电池保持在指定范围里40%~60%
BATTERY_KEEP_RANGE=(50 60)

#充电状态的字段名一般是(只使用了这两个, 每个不同的设备都需要具体查看这个值)："Not charging" "Charging"
STATUS_NAME=("Not charging" "Charging" "Discharging")

# 电流乘放系数
CURRENT_FACTOR=-1000000
# 电压乘放系数
VOLTAGE_FACTOR=1000000
# 电池温度乘放系数
TEMP_FACTOR=10

###################
#
# 配置区
#
###################

set -eu

# 电量百分比
CAPACITY=
# 电压
VOLTAGE=
# 电流
CURRENT_NOW=

# 温度
TEMP=

HEALTH=
CHARGER_STATUS=


# 这里是计数出来的值
WATTs=
# 当前电池容量/设计电池容量 百分比
CAPACITY_PERCETAGE=

get_info(){
    local info
    info=$(cat $BATTERY_UEVENT)
    CAPACITY=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_CAPACITY=)(.*)')

    VOLTAGE=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_VOLTAGE_NOW=)(.*)')
    VOLTAGE=$(echo |awk -v V=$VOLTAGE -v F=$VOLTAGE_FACTOR '{print V/F}')

    CURRENT_NOW=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_CURRENT_NOW=)(.*)')
    CURRENT_NOW=$(echo |awk -v A=$CURRENT_NOW -v F=$CURRENT_FACTOR '{print A/F}')

    TEMP=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_TEMP=)(.*)')
    TEMP=$(echo |awk -v T=$TEMP -v F=$TEMP_FACTOR '{print T/F}')

    WATTs=$(echo |awk -v A=$CURRENT_NOW -v V=$VOLTAGE '{print A*V}')

    HEALTH=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_HEALTH=)(.*)')
    CHARGER_STATUS=$(echo "$info" |grep -oP '(?<=POWER_SUPPLY_STATUS=)(.*)')

}

log(){
    echo "$(date +%F_%T): $*"
}

show(){
cat <<EOF
当前健康状态: $HEALTH
当前充电状态: $CHARGER_STATUS
当前电池电量: ${CAPACITY}%
当前电压: ${VOLTAGE}V
当前电流: ${CURRENT_NOW}A
当前温度: ${TEMP}℃
当前功率: ${WATTs}w
EOF
}

battery_keep_monitor(){
    while :;
    do
        get_info
	# 没有连接着电源
        if [ "$CHARGER_STATUS" = "${STATUS_NAME[2]}" ];then
            log "没有连接着电源，不做操作。"

	# 是在插着电源，但没有充电时
        elif [ "$CHARGER_STATUS" = "${STATUS_NAME[1]}" ];then
            if [ "$CAPACITY" -ge "${BATTERY_KEEP_RANGE[1]}" ];then
                show
                log "关闭充电..."
                eval "$CHARGER_OFF"

            elif [ "$CAPACITY" -lt "${BATTERY_KEEP_RANGE[0]}" ];then
                show
                log "开始充电..."
                eval "$CHARGER_ON"
            fi

	else
            echo "电源状态未知..."

        fi

        sleep 60
    done
}

main(){
    case "${1:-battery}" in 
        --show)
            while :;
            do
                echo -en "\033c"
                get_info
                show
                sleep 1
            done
            ;;
        *)
            battery_keep_monitor
            ;;
    esac
}

main "$@"

