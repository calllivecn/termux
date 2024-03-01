#!/bin/bash
# date 2019-11-25 21:21:14
# author calllivecn <c-all@qq.com>

speak(){
	#termux-tts-speak "$@"
	tts.sh "$@"
}

say_time(){
	speak "$(date +%R)"
}

say_date(){
	speak "$(date +%F)"
}

jsonfmt(){
	python $HOME/bin/jsonfmt.py "$@"
}

say(){

	speak "$1"
	sleep 1
	speak "$1"
	sleep 1.5
	speak "$1"
}


confirm(){
	# 每5分钟，提示一次，提示5次。
	for i in $(seq 3);
	do
		speak "$1"
		sleep 3
		#sleep 300
	done
}


input_number(){
	# usage: $0 <title> <default number>
	local js
	js=$(termux-dialog text -t "$1" -i $2 -n |jsonfmt -d text)
	if [ "$js"x = x ];then
		echo $2
	else
		echo $js
	fi
}


煮饭(){
	sleep $[30*60]
	say "饭好了"
}

煮稀饭_old(){

	local enter

	echo "15分钟后打开盖子。"
	speak "请15分钟后打开盖子。"
	sleep $[15*60]

	say "稀饭要开盖了"
	echo "打开后按回车确认:"
	read enter
	echo "当前时间：$(date +%F-%R)"

	echo "20分钟后会煮好。"
	speak "20分钟后会煮好。"
	sleep $[20*60]

	echo "现在关闭电源，合上盖子，闷5分钟。(按回车开始计时):"
	speak "现在关闭电源，合上盖子，闷5分钟。(按回车开始计时):"
	read enter
	echo "当前时间：$(date +%F-%R)"
	sleep $[5*60]

	echo "稀饭好了！！！"
	echo "当前时间：$(date +%F-%R)"
	say "稀饭好了！！！"
}

煮稀饭(){
	say "35分钟后会煮好。"
	sleep $[35*60]
	say "稀饭好了，可以去降温了～"
	speak "降温3分钟"
}

洗衣服(){
	local t

	#read -t 10 -p "输入洗衣时间(单位分钟,默认40分钟)：" t
	t=$(input_number "输入洗衣时间(单位分钟,默认40分钟)：" 40)
	
	t=${t:-40}

	echo "当前洗衣时间：$t"

	sleep $[t * 60]

	say "衣服洗好了"

}

烧喝的水(){
	sleep $[5 * 60]
	say "喝的水烧好了"
}

烧洗澡水(){
	sleep $[30 * 60]
	say "洗澡水烧好了"
}

测试一下(){
	#speak "测试一下 say"
	confirm "听听这句话的等待时间"
}

烧水11分钟(){
	sleep $[11 * 60]
	say "烧水11分钟"
}


funcs=(煮饭
	煮稀饭
	洗衣服
	烧喝的水
	烧洗澡水
	烧水11分钟
	测试一下)

main_old(){
	local choice
	PS3="输入数字选择："
	select choice in ${funcs[@]};
	do
		echo "开始时间：$(date +%F-%R)"
		speak "执行任务: $choice" &
		$choice
		break
	done
}


main(){
	local choice="" task
	for task in ${funcs[@]};
	do
		if [ "$choice"x = x ];then
			choice="${task}"
		else
			choice="${choice},${task}"
		fi
	done

	task=$(termux-dialog radio -t "选择一个任务：" -v "$choice" | jsonfmt -d text)
	if ! [ "$task"x = x ];then
		echo "开始时间：$(date +%F-%X)"
		echo "执行任务: $task"
		speak "执行任务: $task"
		$task
		echo "结束时间：$(date +%F-%X)"
	fi

}

main
