# 从root shell 切换到 termux tmux。
1. source termux/su2termux.sh
2. bash termux/tmux.sh


# termux 被关闭后，这样重新启动。
1. 删除 tmux 留下的 sock 文件: $HOME/.tmux.sock
2. bash am-start-termux.sh
3. source termux/su2termux.sh
4. bash termux/tmux.sh
5. proot-distro login ubutnu
6. vncserver.sh start
7. vnc 连接...

