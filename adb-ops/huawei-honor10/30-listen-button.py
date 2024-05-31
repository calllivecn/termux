"""
没有完成，先使用简单的 disable-input-device.py 的方式
"""

import os
import sys
import time
import logging
import selectors
import argparse
from pathlib import Path
from threading import (
        Thread,
        )


import libevdev as ev


def getlogger(level=logging.INFO):
    fmt = logging.Formatter("%(asctime)s %(levelname)s line:%(lineno)d %(message)s", datefmt="%Y-%m-%d-%H:%M:%S")

    stream = logging.StreamHandler(sys.stdout)
    stream.setFormatter(fmt)

    logger = logging.getLogger("30-listen-button")
    logger.setLevel(level)
    logger.addHandler(stream)
    return logger


logger = getlogger()

def print_event(e):
        print("Event: time {}.{:06d}, ".format(e.sec, e.usec), end='')
        if e.matches(ev.EV_SYN):
            if e.matches(ev.EV_SYN.SYN_MT_REPORT):
                print(f"++++++++++++++ {e.code.name} ++++++++++++ {e.value}")
            elif e.matches(ev.EV_SYN.SYN_DROPPED):
                print(f">>>>>>>>>>>>>> {e.code.name} >>>>>>>>>>>> {e.value}")
            else:
                print(f"-------------- {e.code.name} ------------ {e.value}")
        else:
            print("type {:02x} {} code {:03x} {:20s} value {:4d}".format(e.type.value, e.type.name, e.code.value, e.code.name, e.value))




class DisableInputDevice(Thread):

    def __init__(self, input_: Path):
        self.input = input_
        self.r, self.w = os.pipe()
        self.select = selectors.DefaultSelector()
        self.select.register(self.r)


    def run(self):
        self.disable_device(self.input)


    def exit(self) -> bool:
        os.write(self.w, b"exit")
        result = os.read(self.r, 8)
        if result == b"ok":
            return True
        else:
            return False
    

    def disable_device(self, path: Path):
        try:
            fd = open(path, "rb")
            devfd = ev.Device(fd)
        except Exception as e:
            logger.error(f"打开文件描述符 {path} 失败。")
            logger.error(f"异常: {e} ")
            return

        try:
            devfd.grab()
        except ev.device.DeviceGrabError:
            logger.warn(f"{path.name} grab() 失败")
            return


        self.select.register(devfd)

        while True:
            for key, mask in self.select.select(0.1):
                if key.fileobj is devfd:
                    e  = next(devfd.events())
                    if logger.level <= logging.DEBUG:
                        print_event(e)

                elif key.fileobj == self.r:
                    logger.info(f"安全退出线程：{self.name}")
                    os.close(fd)
                    break


def execute_cmd(command_vector: int, vector_dir: Path):
    pass



def functions(args: argparse.Namespace):
    """
    如果检测到, 音量键上下上下，四次连续按键事件，就进入功能模式:
        1. 1小时后，自动退出功能模式。
        2. 或者再次按上下上下四次。手动退出。
    """
    function_mode = False
    mode_time = 3600
    mode_time_start = 0

    volumeup = ev.InputEvent(ev.EV_KEY.KEY_VOLUMEUP, value=1)
    volumedown = ev.InputEvent(ev.EV_KEY.KEY_VOLUMEUP, value=1)

    select = selectors.DefaultSelector()

    with open(args.input, "rb") as fd:
        devfd = ev.Device(fd)

        select.register(devfd)

        key_timeout = 2
        t1 = time.time()
        key_seq = []

        command_vector: int = 0

        while True:

            for key, mask in select.select(2):

                e =  next(devfd.events())

                # 音量上下按被按下
                if (e.matches(ev.EV_KEY.KEY_VOLUMEDOWN) or e.matches(ev.EV_KEY.KEY_VOLUMEUP)) and e.value == 1:

                    if function_mode:
                        command_vector += 1
                    else:
                        key_seq.append(e)
            
            # 超时按键序列清理
            

            # 判断，是否进入功能模式, 不然清理序列
            if not function_mode and len(key_seq) == 4:
                if key_seq[0] == volumeup and key_seq[2] == volumeup and key_seq[1] == volumedown and key_seq[3] == volumedown:
                    function_mode = True
                    mode_time_start = time.time()
            else:
                key_seq = []


            # 功能模式的指令向量触发器
            if function_mode and command_vector > 1:

                # 执行指令向量
                if 

            else:
                command_vector = 0


            
            # 如果没有手动退出功能模式，1小后，自动退出
            if function_mode:
                mode_time_end = time.time()
                if (mode_time_end - mode_time_start) > mode_time:
                    function_mode = False




def main():

    parse = argparse.ArgumentParser(
        usage=" %(prog)s --input [device1 [device2 ] [...]]",
        description="监听音量键, 实现自定义按键功能。"
        "(不同安卓版本，或者，不同手机都需要实测后使用)"
        "如果检测到, 音量键上下上下，四次连续按键事件，就进入功能模式"
        ,
        )

    parse.add_argument("--volume", help="音量按键设备形如：/dev/input/eventX")

    parse.add_argument("-i", nargs="+", help="键盘 鼠标 按钮 等需要被禁用的输入设备，形如：/dev/input/eventX")
    
    parse.add_argument("-n", type=int, default=3, help="按几次进入功能模式")

    parse.add_argument("--debug", action="store_true", help=argparse.SUPPRESS)
    parse.add_argument("--parse", action="store_true", help=argparse.SUPPRESS)

    args = parse.parse_args()


    if args.parse:
        print(args)
        sys.exit(0)
    
    if args.debug:
        logger.setLevel(logging.DEBUG)
        # logger.setLevel(9)   
    
    functions(args)
    


if __name__ == "__main__":
    main()


        
