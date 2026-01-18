
import os
import sys
import logging
import argparse
import threading
import tomllib
import fcntl
from pathlib import Path

from typing import (
    Literal,
    BinaryIO,
)

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


# 设置为非阻塞模式
def open_nonblocking(devpath: Path) -> BinaryIO:
    fd = open(devpath, 'rb')
    flags = fcntl.fcntl(fd.fileno(), fcntl.F_GETFL, 0)
    fcntl.fcntl(fd.fileno(), fcntl.F_SETFL, flags | os.O_NONBLOCK)
    return fd


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

def find_device_path(name: str = "", vid: int = -1, pid: int = -1) -> str:
    """
    3种使用方式：
    1. 设备名过滤
    2. 或者使用 vid + pid 过滤。
    3. 设备名 + vid + pid 过滤。

    return: 返回 "" 空串，说明匹配的设备。
    """

    filter_method: Literal["1", "2", "3"]
    if name != "" and vid != -1 and pid != -1:
        #使用3方式
        filter_method = "3"
    
    elif vid != -1 and pid != -1:
        filter_method = "2"

    elif name != "":
        filter_method = "1"

    elif name == "" and vid == -1 and pid == -1:
        raise ValueError(f"需要有 <name> or <vid> <pid>")
    else:
        raise ValueError(f"需要有 <name> or <vid> <pid>")
    

    baseinput="/dev/input"

    inputs = []
    for devnode in os.listdir(baseinput):
        devpath = Path(baseinput) / devnode
        if not devpath.is_dir():
            inputs.append(devpath)
    

    for devnode in inputs:
        with open(devnode, "rb") as fp:
            try:
                # 以只读方式打开设备
                device = ev.Device(fp)

                # 获取设备信息
                dev_vid = device.id["vendor"]
                dev_pid = device.id["product"]
                # dev_bus = device.id["bustype"]

                match filter_method:

                    case "1":
                        if name == device.name:
                            return devnode
                    
                    case "2":
                        if vid == dev_vid and pid == dev_pid:
                            return devnode

                    case "3":
                        if name == device.name and vid == dev_vid and pid == dev_pid:
                            return devnode

            except OSError as e:
                logger.warning(f"{devnode=} [Error: {e}]")
            except Exception as e:
                logger.warning(f"{devnode=} [Error: {e}]")

    return ""




def disable_device(path: Path):

    logger.info(f"启动: {path}") # 这种后台进程输出了，也看不到

    with open(path, "rb") as fd: 
        devfd = ev.Device(fd)
        devfd.grab()

        for e in devfd.events():
            if logger.level >= logging.DEBUG:
                logger.debug(f"{e}")

CONFIG="""\
配置文件示例：

[[devnode]]

# 这里 name 和 vid pid 是可选的。
#   3种使用方式：
#   1. 设备名过滤
#   2. 或者使用 vid + pid 过滤。
#   3. 设备名 + vid + pid 过滤。

name = "Microsoft X-Box 360 pad"
vid = 0x9834
pid = 0x8837

[[devnode]]
# 如果有多个设备。可以添加多个配置。

"""

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

    if args.debug:
        logger.setLevel(logging.DEBUG)

    
    devs: list[str] = []
    if args.toml is None and args.devs is None:
        parse.print_help()
        logger.error(" 使用 配置文件 方式和 指定设备节点 方式，必须有一项。(两种方式都指定了，使用 配置文件 方式)")
        logger.info(f"{CONFIG}")
        sys.exit(1)


    elif args.toml:
        cfg = Path(args.toml)
        if cfg.exists():
            with open(cfg, "rb") as f:
                cfg_devnode = tomllib.load(f)

            logger.debug(f"{cfg_devnode=}")
            cfg_devs: list[dict[str, str|int]] = cfg_devnode["devname"]
            for dev in cfg_devs:
                result_dev = find_device_path(**dev)
                if result_dev != "":
                    devs.append(result_dev)

        else:
            logger.info(f"{CONFIG}")
            logger.error(f"配置文件 {args.toml} 不存在。")
            sys.exit(1)

    elif args.devs:

        devs = args.devs

    else:
        logger.error("未知错误")

    
    threads: list[threading.Thread] = []
    for dev in devs:
        th = threading.Thread(target=disable_device, args=(Path(dev),))
        th.start()
        threads.append(th)
    
    for th in threads:
        th.join()
        logger.info(f"退出：{th.name}")


if __name__ == "__main__":
    main()
