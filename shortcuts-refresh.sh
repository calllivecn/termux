#!/bin/bash
# date 2023-01-09 05:19:26
# author calllivecn <c-all@qq.com>

# 使用这个工具生成 或 刷新 .shortcuts脚本
# 
# 这样没用， shortcuts 使用的是用 sh 极简shell执行的很多功能没有
# .shortcuts init 
#
# 这样在miui实测下没用，sh shell 不认后添加的路径。。。$HOME/bin]
# 目前看好像是只能使用 /data/data/com.termux/files/usr/bin 下的执行命令
#
# 如果是 py 脚本安装到shortcuts 
# 1. 需要先把对应的 *.py 放到$PATH
# 2. 在echo 'type -p <name.py>' > termux/shortcuts/<short-name.py>


SHORT="$HOME/.shortcuts"
TERMUX_SHORT="$HOME/termux/shortcuts"

FUNCS=$HOME/termux/funcs

shell_head(){
# 清空 原文件
cat >"${SHORT}/${1}"<<EOF

# 如果需要长时间运行，termux-wake-lock是需要的
termux-wake-lock

# refresh date: $(date "+%F %X")
export PATH=$HOME/bin:$PREFIX/bin

EOF
}


shell_exit(){
cat >>"${SHORT}/${1}"<<EOF
################
#
# 这里是显示结果的收尾
#
###############

. $FUNCS/enter-exit.sh

#termux-wake-unlock

EOF
}

get_suffix(){
python <<EOF
from pathlib import Path
f = Path("$1")
print(f.suffix)
EOF
}

type_cmd(){
python <<EOF
from pathlib import Path
f = Path("$1")
print(f.suffix)
EOF
}

shell_body(){
	local script suffix="$2"

	if [ "$suffix"x = ".sh"x ];then
		script="bash $HOME/termux/shortcuts/$1"

	elif [ "$suffix"x = ".py"x ];then
		script="python $(bash $HOME/termux/shortcuts/$1)"

	else
		#script="$(type -p "$1")"
		echo "目前先不支持 *.sh *.py 之外的脚本"
	fi

cat >>"${SHORT}/${1}"<<EOF
#################
#
# 这里是添加执行命令的
#
################
$script

EOF

}


main(){
	local f suffix
	
	# 安装 或 刷新
	# 处理 *.sh
	for f in $(ls $TERMUX_SHORT)
	do

		suffix=$(get_suffix "$f")
		if [ "$suffix"x = ".sh"x ] || [ "$suffix"x = ".py"x ];then
			shell_head "$f"
			shell_body "$f"	"$suffix"
			shell_exit "$f"	

		else
			echo "$f: 没有安装"
			echo "目前先不支持 *.sh *.py 之外的脚本"
		fi
	done

}


main
