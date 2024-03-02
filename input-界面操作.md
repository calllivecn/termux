# adb获取手机设备蓝牙&热点&wifi状态并操作的笔记

## wifi

```
#获取状态

$ adb shell ps | grep wifi
#output中出现wpa_supplicant说明wifi处于开启状态，如果出现hostapd说明热点处于开启状态

$ adb shell dumpsys wifi | grep curState
#output中出现Active说明wifi处于开启状态



#操作改变状态
方法1：
$ adb shell svc wifi enable
#enable是打开，disable是关闭 如果output是killed，说明没有root权限，adb shell之后还要加su权限

方法2：
$ adb shell am start -n com.android.settings/.wifi.WifiSettings 或者 adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings

通过input keyevent 模拟用户输入实现, 每个机器都需要实测后才使用
$ adb shell input keyevent 20 # 20: 是方向下键
$ adb shell input keyevent 66 # 66: 是回车键

18 #不一定适用所有机型，需要事先测试
19 方法3：
20 adb shell am broadcast -a io.appium.settings.wifi --es setstatus enable
21 #这个是调用了appium的端口发布全局广播，打开wifi，使用后会有弹窗询问是否允许，需要点击掉弹窗
```

## 热点

```
#获取状态

在获取wifi状态中有提到

#操作改变状态

方法1： 
adb shell am start -n com.android.settings/.TetherSettings

adb shell input keyevent 61 # tab键
adb shell input keyevent 66
#不一定适用所有机型，需要事先测试

13 方法2：
14 #打开热点
15 adb shell service call connectivity 24 i32 0
16 #关闭热点
17 adb shell service call connectivity 25 i32 0

18 此操作需要root权限 ； 末尾的0是传递的参数，0是wifi网络共享，1是usb网络共享，2是蓝牙网络共享
19 更多信息可参考：https://android.stackexchange.com/questions/111226/using-adb-shell-how-i-can-disable-hotspot-tethering-on-lollipop-nexus-5
```


## 蓝牙

```
#获取状态
$ adb shell settings get global bluetooth_on
output是0或1，0代表关闭，1反之
$ adb shell dumpsys bluetooth_manager | grep enabled
output是true或者false，说明开启或关闭

#改变操作状态

方法1：
$ adb shell settings put global bluetooth_on 1
#末尾设置为0代表关闭，1反之

方法2：
$ adb shell svc bluetooth enable
#末尾设置为enable为开启，disable反之(这个方法输入命令后并不立即生效，重启设备才生效)

方法3：
$ adb shell am start -a android.bluetooth.adapter.action.REQUEST_ENABLE
#目前只能从关闭状态转为开启状态，并且运行指令后会有弹窗提示是否开启蓝牙

方法4：
adb shell am start -a android.settings.BLUETOOTH_SETTINGS
adb shell input keyevent 20
adb shell input keyevent 20
#同之前的启动方式，不一定适用所有机型

方法5：
adb shell am broadcast -a io.appium.settings.bluetooth --es setstatus enable
#这个是调用了appium的端口发布全局广播，打开蓝牙，打开后会有弹窗询问允许，脚本中需要添加点击掉弹窗的方法
```
