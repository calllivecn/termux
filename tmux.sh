S="/data/data/com.termux/files/usr/var/run/tmux-10156/default"
S="/data/data/com.termux/files/home/.tmux.sock"

if [ -S $S ];then
	tmux -S $S attach
else
	tmux -S $S
fi
