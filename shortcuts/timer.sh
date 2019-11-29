#!/bin/bash
# date 2019-11-25 21:21:14
# author calllivecn <c-all@qq.com>

. $HOME/bin/liblock.sh

speak(){
	termux-tts-speak "$@"
}

say_time(){
	speak "$(date +%R)"
}

say_date(){
	speak "$(date +%F)"
}

say(){

	local i

	for i in {1..3}
	do
		speak "$1"
		sleep 1
	done
}


confirm(){
	# 每5分钟，提示一次，提示5次。
	for i in $(seq 1 5);
	do
		say "$1"
		sleep 300
	done

}



煮饭(){
	sleep $[30*60]
	say "饭好了"
}

洗衣服(){
	local t

	read -t 5 -p "输入洗衣时间(单位分钟,默认40分钟)：" t
	
	t=${t:-40}

	echo "当前洗衣时间：$t"

	sleep $[t * 60]

	say "衣服洗好了"

}

烧喝的水(){
	sleep $[7 * 60]
	say "喝的水烧好了"
}

烧洗澡水(){
	sleep $[30 * 60]
	say "洗澡水烧好了"
}

测试一下(){
	speak "测试一下"
}

funcs=(煮饭
	洗衣服
	烧喝的水
	烧洗澡水
	测试一下)

main(){
	PS3="输入数字选择："
	select choice in ${funcs[@]};
	do
		echo "开始时间：$(date +%F-%R)"
		speak "$choice"
		#eval $choice
		$choice
		break
	done
}


termux-wake-lock
main
termux-wake-unlock
