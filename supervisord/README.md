# supervisord 配置+使用说明

## update: 使用pyinstaller 打包，以解决，更新python 大版本后，supervisor 路径变化，导致的重启会失败的问题。

## 准备工作在 boot-start/shells/添加30-supervisord.sh 开机启动


## 初始化 准备工作

- 把当前目录 cp -av 到 root/.supervisord/ 以安装 supervisod
- cd root/.supervisord/
- mkdir -vp logs inis


## 然后在配置 inis/*.ini


## 最后启动supervisord

