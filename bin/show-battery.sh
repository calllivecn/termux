#!/data/data/com.termux/files/usr/bin/bash
# date 2023-07-10 22:35:46
# author calllivecn <c-all@qq.com>


# 在 dumpsys battery 命令的输出信息中，
# status 字段表示电池的当前状态，可能的值及其含义如下：
# 
# 1 或 unknown：未知状态。
# 2 或 charging：充电中。
# 3 或 discharging：未充电。
# 4 或 not charging：未充电。
# 5 或 full：电池已充满。
# health 字段表示电池的健康状态，可能的值及其含义如下：
# 
# 1 或 unknown：未知状态。
# 2 或 good：良好状态。
# 3 或 overheat：过热状态。
# 4 或 dead：损坏状态。
# 5 或 over voltage：过压状态。
# 6 或 unspecified failure：未指定的故障状态。
# 7 或 cold：过冷状态。


# 需要 root or shell 权限

while :
do
    echo "==================="
    date "+%F_%X"
    dumpsys battery
    sleep 5
done

