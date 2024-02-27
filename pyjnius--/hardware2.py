#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-27 21:36:58
# author calllivecn <c-all@qq.com>

from jnius import autoclass
DisplayMetrics = autoclass('android.util.DisplayMetrics')
metrics = DisplayMetrics()
print('DPI', metrics.getDeviceDensity())



