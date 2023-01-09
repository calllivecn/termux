#!/bin/bash
# date 2023-01-06 03:13:28
# author calllivecn <c-all@qq.com> 


# 需求
# 0. 在文件大于500M时合并上传, 或者 最新未上传文件时间戳录制超过1小时,时合并上传。


# 设计
# 1. 先把modet/里完成的视频移动到新位置，检查大小，和时间间隔。
# 2. 上传单独一个线程做, 在一个目录里有就上传。

. ~/.venv/aliyunpan/bin/activate

#############
# 配置 begin
#############

IPWEBCAM_ROOT="$HOME/storage/shared/ipwebcam-videos"

cd $IPWEBCAM_ROOT

# 一直录制时的目录
#IPWEBCAM_DIR="$IPWEBCAM_ROOT/rec"
IPWEBCAM_DIR="rec"
# 动物检测时的录制目录
IPWEBCAM_DIR="modet"

ALIYUNDRIVE_DIR="/ipwebcam"

# 每6小时合并一次
UPLOAD_INTERVAL=$[6*3600]
UPLOAD_DIR=".upload"
#UPLOAD_CUR_FILE="${IPWEBCAM_ROOT}/.progress"

# 如果merge 后的大小超过 500M 就移动到上传目录上传
MERGE_SIZE=500
MERGE_TXT=".merge.txt"
MERGE_DIR=".merge"

############
# 配置 end
############


############
# 检测依赖工具 和 初始化
############
check_depends(){
	local flag="true"
	#if ! type -p jsonfmt.py >/dev/null 2>&1 ;then
	#	flag="false"
	#	echo "需要安装 jsonfmt.py 工具: https://github.com/calllivecn/mytools"
	#fi

	if ! type -p ffmpeg >/dev/null 2>&1 ;then
		flag="false"
		echo "需要安装 ffmpeg 工具: apt install ffmepg"
	fi

	if ! type -p aliyunpan >/dev/null 2>&1 ;then
		flag="false"
		echo "需要安装 aliyunpan 工具: pip install aliyunpan"
	fi

	if [ $flag != "true" ];then
		exit 1
	fi
}

check_depends


# 初始化
aliyunpan mkdir "$ALIYUNDRIVE_DIR"

if [ ! -d $UPLOAD_DIR ];then
	mkdir -v $UPLOAD_DIR
fi

if [ ! -d $MERGE_DIR ];then
	mkdir -v $MERGE_DIR
fi

############
# 检测依赖工具 end
############


upload(){
	# 上传, 成功后删除
	aliyunpan upload "$1" "$ALIYUNDRIVE_DIR"
	if [ $? -eq 0 ];then
		# 记录下上传成功的文件的时间，之后好对比。
		#touch -r "$1" "$UPLOAD_CUR_FILE"
		echo "${video} 上传成功。"
		rm -v "$1"
		return 0
	else
		echo "${video} 上传失败。"
		return 1
	fi
}

# 后台运行
thread_upload(){
	local v
	while :
	do
		for v in $(ls -tr $UPLOAD_DIR)
		do
			if ! upload "$UPLOAD_DIR/$v";then
				echo "上传失败10分钟后重试..."
				sleep $[9*60]
				break
			fi
		done
		sleep 60
	done
}


# 生成对应大小的空白视频(暂时没用，以后优化在使用。)
empty_video(){
	local w="$1" h="$2" v="${w}x${h}.mkv"
	if [ -f $v ];then
		return
	else
		ffmpeg -loglevel error -f lavfi -i color=white:s=${w}x${h} -vcodec h264 -t 1 "${v}"
	fi
}


# 查看 最新未上传文件时间戳录制超过1小时,时合并上传。
time_interval_check(){
	local t t_start t_cur interval last_video

	last_video=$(ls -tr $MERGE_DIR| head -n 1)

	if [ "$last_video"x = x ];then
		return 1
	fi

	t=$(stat "$MERGE_DIR/$last_video" |grep Access |tail -n 1)
	t_start=$(date +%s -d "${t#Access: }")

	t_cur=$(date +%s)

	interval=$[t_cur - t_start]

	if [ $interval -ge $UPLOAD_INTERVAL ];then
		return 0
	else
		return 1
	fi
}

merge_size_check(){
	sizeMB=$(du -sm $MERGE_DIR| awk '{print $1}')

	if [ $sizeMB -ge $MERGE_SIZE ];then
		return 0
	else
		return 1
	fi
}

# 把新生成的视频移动到临时 merge 目录
move2merge(){
	local v cur=0
	
	for v in $(ls -t $IPWEBCAM_DIR)
	do
		cur=$[cur + 1]

		if [ $cur -le 1 ];then
			continue
		fi


		mv "$IPWEBCAM_DIR/$v" "$MERGE_DIR"
	done

}

# 生成merge 新文件名
mergefilename(){

	local t ts last_video new_video prefix suffix

	last_video=$(ls -tr $MERGE_DIR| head -n 1)
	new_video=$(ls -t $MERGE_DIR| head -n 1)

	t=$(stat "$MERGE_DIR/$last_video" |grep Access |tail -n 1)
	ts=$(date +%s -d "${t#Access: }")
	prefix=$(date +%F-%H-%M-%S -d @${ts})

	t=$(stat "$MERGE_DIR/$new_video" |grep Modify |tail -n 1)
	ts=$(date +%s -d "${t#Modify: }")
	suffix=$(date +%F-%H-%M-%S -d @${ts})

	echo "${prefix}__${suffix}.mkv"

}

# 生成合并列表, 并合并。
merge(){
	# usage: $0 <output.mkv>
	local f
	for f in $(ls -tr $MERGE_DIR);
	do
		printf $"file '%s/%s'\n" ${MERGE_DIR##*/} $f
		echo "file '1280x720.mkv'"
	done > "$MERGE_TXT"

	ffmpeg -loglevel error -f concat -safe 0 -i "$MERGE_TXT" -codec copy $1
	if [ $? -eq 0 ];then
		rm -v $MERGE_DIR/*
	fi
}


main(){

	thread_upload &
	thread_upload_pid=$!
	trap "kill $thread_upload_pid" EXIT
	echo "上传线程启动"
	
	local merge_flag filename

	merge_flag=n
	while :
	do
		# 把新生成的视频移动到临时 merge 目录
		move2merge

		#echo "time_interval_check()..."
		if time_interval_check;then
			merge_flag=y
		fi

		#echo "merge_size_check()..."
		if merge_size_check;then
			merge_flag=y
		fi

		if [ $merge_flag = y ];then
			echo -n "merge 的文件名: "
			filename=$(mergefilename)
			echo $filename

			if merge $filename;then
				mv -v $filename "$UPLOAD_DIR"
			fi
		fi

		merge_flag=n
		echo -n "LOOP: "
		date +%F-%X
		sleep $[1*60]
	done

}


main
