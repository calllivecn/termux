#!/usr/bin/env python3
# coding=utf-8
# date 2021-04-25 15:04:43
# author calllivecn <c-all@qq.com>


import json
import subprocess


def get_10001_sms():
    exitcode, sms = subprocess.getstatusoutput("termux-sms-list -t inbox -l 20")
    if exitcode != 0:
        raise Exception(f"执行出错: {sms}")

    return json.loads(sms)


def main():

    msg = []
    json_sms = get_10001_sms()
    #json_sms.reverse()
    for sms in json_sms:
        if sms["number"] == "10001" and sms["body"].startswith("尊敬的客户"):
            body = sms["body"].replace(";", "\n")
            msg.append((sms["number"], sms["received"], body))



    
    for s in msg:
        print("="*40)
        print(f"号码: {s[0]}")
        print(f"接收时间: {s[1]}")
        print(f"内容: {s[2]}")


if __name__ == "__main__":
    main()


