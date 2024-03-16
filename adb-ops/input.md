# input 命令使用 

- 这是文档：https://developer.android.com/reference/android/view/KeyEvent

## keyevent <code> 和安卓版本， 设备有关。

- keyevent <code>

```
3：HOME 键
4：返回键

5：通话键
6：结束通话键

7 ~ 16 ：KEYCODE_0 数字0 ~ 9
10：KEYCODE_3 数字3
11：相机键
12：清除键

19：方向上键
20：方向下键
21：方向左键
22：方向右键
23：方向中心键

24：音量增加键
25：音量减小键
26：电源键(KEYCODE_POWER)
27：摄像头键

28：清除键

29：A键
30：B键
31：C键
32：D键
33：E键
34：F键

61: TAB键KEYCODE_TAB
66: 回车键KEYCODE_ENTER


82: KEYCODE_MENU

224: 键码常量：唤醒键。唤醒设备。行为有点像 KEYCODE_POWER 但如果设备已经唤醒则没有任何效果。

```



- wm 命令

```
您可以使用 ADB 工具和 wm 命令来暂时禁用 Android 设备的屏幕输入。首先，您需要在电脑上安装 ADB 工具并确保您的手机已经开启了 USB 调试模式。然后，您可以按照以下步骤操作：

将手机连接到电脑。
打开命令提示符窗口。
输入 adb shell wm overscan 0,0,0,0 并按回车键。
这样，您的手机屏幕输入将被暂时禁用。要重新启用屏幕输入，您可以在命令提示符窗口中输入以下命令：

adb shell wm overscan reset

adb shell wm size # 查看手机屏幕分辨率和当前使用的分辨率: 输出示例
Physical size: 1080x2280
Override size: 720x1520

```



