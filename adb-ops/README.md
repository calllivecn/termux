# 通过adb shell or root 的方式操作 安卓


## 安装libevdev 库, 要先启用 x11 仓库

- apt install x11-repo
- apt install libevdev
- cd ../../usr/lib/
- ln -vs libevdev.so libevdev.so.2
- cd keyboardmouse
- python list-inputs.py # 查看输出
