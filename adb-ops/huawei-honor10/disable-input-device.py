
import os
import sys
import signal
from pathlib import Path

import libevdev as ev

def exit_clear(pid_file: Path):
    if pid_file.exists:
        os.remove(pid_file)
    sys.exit(0)


def disable_device(pid_file, path):

    signal.signal(signal.SIGTERM, lambda sig, frame: exit_clear(pid_file))

    pid = os.getpid()
    # 保存下执行时的进程pid
    with open(pid_file, "w") as f:
        f.write(str(pid))

    # print(f"启动完成，PID: {pid}") # 这种后台进程输出了，也看不到

    with open(path, "rb") as fd: 
        devfd = ev.Device(fd)
        devfd.grab()

        for e in devfd.events():
            pass


def check_pid():
    prog = Path(sys.argv[0])
    path = Path(sys.argv[1])

    pid_file = prog.with_suffix(".pid")

    if pid_file.exists():
        with open(pid_file) as f:
            prev_pid = int(f.read(100))

        os.kill(prev_pid, 15)
        print(f"kill完成，PID: {prev_pid}")

    else:
        #启动新进程
        pid = os.fork()
        if pid == 0:
            disable_device(pid_file, path)

        print("已经启动子进程")



if __name__ == "__main__":
    check_pid()
