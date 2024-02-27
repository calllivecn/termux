#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-02 02:54:14
# author calllivecn <c-all@qq.com>

from jnius import autoclass

# 加载 Android 库
android = autoclass('android.os.Environment')
#android = autoclass('android')

# 获取 SD 卡路径
sdcard_path = android.getExternalStorageDirectory().getPath()

print(sdcard_path)



