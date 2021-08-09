#!/usr/bin/env python3
# coding=utf-8
# date 2021-08-09 12:30:21
# author calllivecn <c-all@qq.com>

import time
import random
import threading
from subprocess import run
from datetime import (
        datetime,
        timedelta,
        )


# 闹钟时间

T=(
        (0, 39),
        (9, 55), # 09:55
        (19, 45), # 19:45
        )



exit_lock = threading.Lock()

def input_exit():
    with exit_lock:
        input("按回车键退出...")
        print("alarm exit")


def alarm():
    th = threading.Thread(target=input_exit, daemon=True)
    th.start()

    while exit_lock.locked():
        run('termux-toast -g top "打卡"'.split())
        run("termux-vibrate -d 1500".split())
        time.sleep(3)


def rand(number=10):
    return random.choice(range(-number, number))


def rand_time():
    """
    在设置的闹钟点，周围随机10分钟的时间点。
    """
    cur = datetime.now()

    T_rand = []
    for h, m in T:
        delta = timedelta(minutes=rand())
        alarm_click = datetime(cur.year, cur.month, cur.day, h, m, 0)
        dt = alarm_click + delta

        T_rand.append((dt.hour, dt.minute))

    print("随机的时间：", T_rand)

    return T_rand

def T_rand_pop(cur, t_rand):
    tmp = []
    for t in t_rand:
        if t == cur:
            continue
        else:
            tmp.append(t)
    return tmp


T_rand = rand_time()

#test_t = [(1, 2), (1, 3)]
#T_rand = test_t

while True:
    cur = datetime.now()
    print((cur.hour, cur.minute))

    if len(T_rand) <= 0:
        T_rand = rand_time()
        #T_rand = test_t

    if (cur.hour, cur.minute) in T_rand:
        print("闹钟提示")
        alarm()
        T_rand = T_rand_pop((cur.hour, cur.minute), T_rand)
    else:
        time.sleep(40)



