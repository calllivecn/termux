#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-27 19:20:13
# author calllivecn <c-all@qq.com>

from time import sleep
from jnius import autoclass

# 使用 autoclass 函数获取 org.renpy.android.Hardware 类
Hardware = autoclass('org.renpy.android.Hardware')

# 打印 DPI
print('DPI is', Hardware.getDPI())

# 启用加速度计
Hardware.accelerometerEnable(True)

# 打印加速度计读数
for x in range(20):
    print(Hardware.accelerometerReading())
    sleep(0.1)


