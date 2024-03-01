# huawei honor10 通电自动开机

- 哦～吼吼这样可以通电自动开机（有点问题就是这样启动的 magisk app 没有了。权限还在。。。已修好）


## 在 Android 10 及更高版本中，sys.boot_from_charger_mode 属性已被弃用。要设置通电自动开机，您可以使用以下方法：

- 方法一：使用 settings put 命令
    1. 将您的设备连接到电脑。
    2. 在电脑上打开命令行工具，并输入以下命令：

    ```shell
    adb shell settings put global persist.sys.boot_from_charger_mode 1
    ```

## 注意:

 - 该命令需要 root 权限。


## 方法二：修改 init.rc 文件

    1. 在您的设备上安装 TWRP 或其他自定义恢复工具。
    2. 使用 TWRP 或其他自定义恢复工具将 init.rc 文件备份到您的电脑。
    3. 在电脑上编辑 init.rc 文件，添加以下行：

    ```shell
    on charger.
        class_start charger
        setprop sys.powerctl reboot
    ```

    4. 将编辑后的 init.rc 文件刷写回您的设备。

## 注意:

 - 修改 init.rc 文件可能会导致设备无法启动。请谨慎操作。



## 方法三：使用第三方应用程序

可以使用第三方应用程序来设置通电自动开机。例如，Tasker 是一款功能强大的自动化应用程序，可以用于设置通电自动开机。

- 使用 Tasker 设置通电自动开机

1. 在您的设备上安装 Tasker 应用程序。
2. 打开 Tasker 应用程序，创建一个新的任务。
3. 在任务中，添加以下操作：
4. 条件: 电池电量 > 0%
5. 动作: 执行命令 "settings put global persist.sys.boot_from_charger_mode 1"
6. 保存任务并激活它。

## 注意:

- Tasker 应用程序需要付费才能使用。


