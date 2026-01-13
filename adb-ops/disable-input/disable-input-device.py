
import os
import sys
import logging
import argparse
import threading
import toml
from pathlib import Path

import libevdev as ev


def getlogger(level=logging.INFO):
    fmt = logging.Formatter("%(asctime)s %(levelname)s line:%(lineno)d %(message)s", datefmt="%Y-%m-%d-%H:%M:%S")

    stream = logging.StreamHandler(sys.stdout)
    stream.setFormatter(fmt)

    logger = logging.getLogger("disable-input-button")
    logger.setLevel(level)
    logger.addHandler(stream)
    return logger


logger = getlogger()

"""
# 获取可执行文件所在的目录
if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
    so_path = Path(sys._MEIPASS) / "so_dir" 
elif __file__:
    so_path = os.path.dirname(__file__)

# 添加 .so 库所在的目录
logger.info(f"添加动态库路径: {so_path}")

if 'LD_LIBRARY_PATH' in os.environ:
    os.environ['LD_LIBRARY_PATH'] = str(so_path) + os.pathsep + os.environ['LD_LIBRARY_PATH']
else:
    os.environ['LD_LIBRARY_PATH'] = str(so_path)
"""

def find_device_path(devname: str = "", vid: int = -1, pid: int = -1) -> list[str]:

    if devname == "" and vid == -1 and pid == -1:
        raise ValueError(f"需要有 <devname> or <vid> <pid>")

    baseinput="/dev/input"

    inputs = []
    for devnode in os.listdir(baseinput):
        devpath = Path(baseinput) / devnode
        if not devpath.is_dir():
            inputs.append(devpath)
    

    devs: list[ev.Device] = []
    for devnode in inputs:
        with open(devnode, "rb") as fp:
            try:
                # 以只读方式打开设备
                device = ev.Device(fp)

                # 获取设备信息
                vid = device.id["vendor"]
                pid = device.id["product"]
                bus = device.id["bustype"]

                if devname != "":
                    if devname == device.name:

            except OSError as e:
                logger.warning(f"{devnode=} [Error: {e}]")
            except Exception as e:
                logger.warning(f"{devnode=} [Error: {e}]")

    return devs




def disable_device(path: Path):

    logger.info(f"启动: {path}") # 这种后台进程输出了，也看不到

    with open(path, "rb") as fd: 
        devfd = ev.Device(fd)
        devfd.grab()

        for e in devfd.events():
            if logger.level >= logging.DEBUG:
                logger.debug(f"{e}")


def main():
    parse = argparse.ArgumentParser(usage="%(prog)s")
    parse.add_argument("--debug", action="store_true", help="开启debug日志")
    parse.add_argument("--parse", action="store_true", help=argparse.SUPPRESS)
    groups = parse.add_mutually_exclusive_group()
    groups.add_argument("--toml", action="store", help="指定配置文件")
    groups.add_argument("--devs", nargs="*", help="/dev/input/XXX")
    
    args = parse.parse_args()

    if args.parse:
        logger.info(f"{args}")
        sys.exit(0)
    
    if args.toml is None and args.devs is None:
        parse.print_help()
        logger.error(" 使用 配置文件 方式和 指定设备节点 方式，必须有一项。(两种方式都指定了，使用 配置文件 方式)")
        sys.exit(1)
    elif args.toml:
        devs = toml.load(args.toml)
    elif args.devs:
        devs = args.devs
    else:
        logger.error("未知错误")


    if args.debug:
        logger.setLevel(logging.DEBUG)

    
    threads: list[threading.Thread] = []
    for dev in args.devs:
        th = threading.Thread(target=disable_device, args=(Path(dev),))
        th.start()
        threads.append(th)
    
    for th in threads:
        th.join()
        logger.info(f"退出：{th.name}")


if __name__ == "__main__":
    main()
