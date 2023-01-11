#!/bin/bash
# date 2023-01-12 00:29:43
# author calllivecn <c-all@qq.com>



# post-fs-data 里需要使用resetprop -n 

resetprop -n sys.boot_from_charger_mode 1


# on charger
# 
#   class_start charger #这段自带不用删也可以,而且听说某些系统需要先进入charger流程，否则会卡第一屏
# 
#   setprop sys.powerctl reboot #添加进这段

#resetprop -n sys.powerctl reboot
