#!/bin/bash
# date 2021-09-24 16:44:24
# author calllivecn <c-all@qq.com>


# 模拟从图标启动app

# 启动app, 不过需要root权限。
#am start -n net.christianbeier.droidvnc_ng/.MainActivity
am start -n com.wireguard.android/.activity.MainActivity


# 查看包的启动 MainActivity
# 1. 切换到root。
# 2. pm list packages |grep "$packagename"
# 3. dumpsys package "$packagename" |grep -A 1 "android.intent.action.MAIN"
#    or pm dump "$packagename" |grep -A 1 "android.intent.action.MAIN"
# 4. 找到这样一行：“android.intent.action.MAIN:” 它下面一行就是了
#         54ed60c com.termux/.app.TermuxActivity filter d428d44
#
