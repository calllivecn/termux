#!/usr/bin/env python3
# coding=utf-8
# date 2023-07-12 03:11:08
# author calllivecn <c-all@qq.com>

import os
import sys
import time
import subprocess


import miio
from miio.chuangmi_plug  import ChuangmiPlug
from miio.exceptions import DeviceException



class Plugin:

    def __init__(self, ip, token):
        self.ip = ip 
        self.token = token

        self.device = ChuangmiPlug(ip=self.ip, token=self.token)

    def info(self):
        s = miio.device.Device(ip=self.ip, token=self.token)
        print(s.info())


    def status(self):
        """
        return: 0: 关， 1: 开， 2: 离线
        """

        try:
            status = self.device.status()
        except DeviceException as e:
            print("查询设备状态异常: {e=}")
            return 2

        if status.is_on:
            return 1
        else:
            return 0

    def on(self):
        try:
            x = self.device.on()
        except DeviceException as e:
            return False

        if x == ["ok"]:
            return True
        else:
            return False


    def off(self):
        try:
            x = self.device.off()
        except DeviceException as e:
            return False

        if x == ["ok"]:
            return True
        else:
            return False



# 查看电池电量和温度, 是否在充电

def getbattery():
    """
    return: (level, temp, charging)
    charging: --> bool
    1 或 unknown：未知状态。
    2 或 charging：充电中。
    3 或 discharging：未充电。
    4 或 not charging：未充电。
    5 或 full：电池已充满。
    """
    r = subprocess.run(["dumpsys", "battery"], stdout=subprocess.PIPE)
    r.check_returncode()
    
    r = r.stdout.decode()
    for t in [ t.strip() for t in r.splitlines() ]:
        if t.startswith("level:"):
            level = int(t.split(":").strip())
        
        if t.startswith("temperature:"):
            temp = int(t.split(":").strip()) /10

        if t.startswith("status:"):
            s = t.split(":").strip()

    
    if s == "2":
        charging = True
    elif s == "3" or s == "4" or s == "5":
        charging = False


    return level, temp, charging


def main():

    try:
        IP = os.environ["MIROBO_IP"]
        TOKEN = os.environ["MIROBO_TOKEN"]
    except Exception:
        print("设置环境变量: MIROBO_IP, MIROBO_TOKEN")
        sys.exit(1)


    dev = Plugin(IP, TOKEN)

    # 当前状态和 last状态

    while True:
        level, temp, charging = getbattery()

        if level <= 70:
            if charging is False:
                dev.on()

        elif level >= 80:
            if charging:
                dev.off()

        time.sleep(60)



if __name__ == "__main__":
    main()


