
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

mt_wifi_ap_off = MatchTemplate(temps_dir / "03-wifi-ap-off.png")
mt_wifi_ap_on = MatchTemplate(temps_dir / "03-wifi-ap-on.png")


adb = AdbCmd("adb")

wf = Workflow(adbcmd=adb)

# 唤醒，点亮屏幕 + 输入密码解锁
adb.keyevent(KeyEvent.WAKEUP)
adb.swipe(100, 500, 100, 0)
adb.text("159753")


# 向下，拉出来状态栏
adb.swipe(0, 0, 0, 200)
wf.wait_click(mt_wifi_ap_off)



