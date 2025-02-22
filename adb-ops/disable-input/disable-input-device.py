
import os
import sys
import logging
import argparse
import threading
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


def disable_device(path: Path):

    logger.info(f"启动: {path}") # 这种后台进程输出了，也看不到

    with open(path, "rb") as fd: 
        devfd = ev.Device(fd)
        devfd.grab()

        for e in devfd.events():
            logger.debug(f"{e}")


def main():
    parse = argparse.ArgumentParser(usage="%(prog)s --help")
    parse.add_argument("--debug", action="store_true", help="开启debug日志")
    parse.add_argument("devs", nargs="+", help="/dev/input/XXX")
    args = parse.parse_args()

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
