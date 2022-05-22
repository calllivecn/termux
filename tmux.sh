S="/data/data/com.termux/files/usr/var/run/tmux-10156/default"

if [ -S $S ];then
	tmux -S $S attach
else
	tmux -S $S
fi
