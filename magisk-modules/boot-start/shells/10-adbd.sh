# 启动 adbd

# android11 以上，需要先在开发者选项里，进行一次无线配对。（还没有找到怎么从命令行启动时设置配对码）

# 设置adbd 使用的端口
setprop service.adb.tcp.port 15555

# #  关闭usb 监听(在android9 还是有效的，android13 实测没效果)
setprop service.adb.usb.enabled 0

# 每个手机+系统，最好都看看adbd的路径。
# adbd

# 使用绝对路径都会是你自己添加的adbd
#/data/data/adbd

