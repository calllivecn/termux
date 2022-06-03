

while :
do
	python testing/socket-shell/rshell.py client --addr mc.calllive.cc --port 16789 || echo "$(date +%F-%R) -- 失败"
	sleep 10
done
