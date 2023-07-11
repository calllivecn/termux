# input 命令使用 

- 这是文档：https://developer.android.com/reference/android/view/KeyEvent

## keyevent <code> 和安卓版本， 设备有关。

- keyevent <code>

```
3：HOME 键
4：返回键
5：拨号键
6：接听键
7：挂断键
8：音量减小键
9：音量增大键
10：KEYCODE_3
11：相机键
12：清除键
19：上键
20：下键
21：左键
22：右键
23：回车键(有时候有回车的效果)
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

66: keycode_enter

82: KEYCODE_MENU


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



