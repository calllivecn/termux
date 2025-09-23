
# 拿到设备列表
devices=()
get_devs(){
	i=0
	echo "有多个设备，请选择："
	for dev in $(adb devices |grep -Ev "List of devices attached|^$" |awk '{print $1}')
	do
		devices[$i]="$dev"
		echo "$i) ${devices[$i]}"
		i=$[i+1]
	done
}

number=
select_dev(){
	while :;
	do
		read -p "请输入序号: " number
		if [ "$number"x = x ];then
			continue
		else
			if [ $number -le $i ] && [ $number -ge 0 ];then
				break
			else
				echo "输入范围:0 ～ ${i}"
				continue
			fi
		fi
	done
}

get_devs

if [ ${#devices[@]} -eq 1 ];then
	scrcpy -S -t --power-off-on-close --no-cleanup --no-audio
else
	select_dev
	scrcpy -s "${devices[$number]}" -S -t --power-off-on-close --no-cleanup --no-audio
fi

