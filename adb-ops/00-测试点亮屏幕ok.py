
import sys
from pathlib import Path

from libautogui import (
    KeyEvent,
    AdbCmd,
    MatchTemplate,
    Workflow,
)




cwd = Path(sys.argv[0]).parent

temps_dir = cwd / "temps"

mt_lock = MatchTemplate(temps_dir / "00-lock.png")


adb = AdbCmd("adb")

wf = Workflow(adbcmd=adb)

# 唤醒，点亮屏幕
adb.keyevent(KeyEvent.WAKEUP)
adb.swipe(100, 500, 100, 0)
adb.text("159753")


wf.wait_template(mt_lock)
print("点亮屏幕了.")


