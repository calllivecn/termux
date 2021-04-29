

sdcard="$HOME/storage/shared/Download/termux/bin/sms-flowcheck.py"
home="$HOME/termux/bin/sms-flowcheck.py"

if [ -r $sdcard ];then
	python $sdcard
elif [ -r $home ];then
	python $home
else
	echo "没有安装 sms-flow-check.py"
	echo "git clone https://github.com/calllivecn/termux.git"
	echo
fi

echo "回车退出"
read y
