#!/bin/bash
# date 2022-08-15 20:05:48
# author calllivecn <c-all@qq.com> 


# 0. 上传到网盘 
# 1. 怎么让刚录制完成的上传，并处本地保留指定个数的记录？ 
# 2. 有可能会断网。这期间需要保存，并检测网络，在网络恢复时，继续上传。 


. ~/.venv/aliyunpan/bin/activate

#############
# 配置 begin
#############

IPWEBCAM_ROOT="$HOME/storage/shared/ipwebcam-videos"
IPWEBCAM_DIR="$IPWEBCAM_ROOT/rec"
IPWEBCAM_DIR="$IPWEBCAM_ROOT/modet"
ALIYUNDRIVE_DIR="/ipwebcam"

# 本地保留多少个
SAVE_COUNT=12
UPLOAD_CUR_FILE="${IPWEBCAM_ROOT}/.progress"

############
# 配置 end
############

cd "$IPWEBCAM_DIR"

upload(){
	# 上传
	aliyunpan upload "$1" "$ALIYUNDRIVE_DIR"
	if [ $? -eq 0 ];then
		# 记录下上传成功的文件的时间，之后好对比。
		touch -r "$1" "$UPLOAD_CUR_FILE"
		echo "${video} 上传成功。"
	fi
}


delete(){
	cur=1
	for video in $VIDEOS_REVERSE
	do
		if [ $cur -gt $SAVE_COUNT ];then
			# video 要比已经上传的要旧才能删除
			if [ $video -ot $UPLOAD_CUR_FILE ];then
				echo "超过本地保存数，并且已经上传，执行清理。"
				rm -v $video
			fi
		fi
		cur=$[cur + 1]
	done
}


main(){
	# 更新列表
	VIDEOS="$(ls -tr)"
	VIDEOS_REVERSE="$(ls -t)"
	TOTAL_COUNT="$(ls -tr |wc -l)"

	cur=1
	for video in $VIDEOS
	do
		if [ $video -nt $UPLOAD_CUR_FILE ];then
			if  [ $cur -eq $TOTAL_COUNT ];then
				echo "最新的还在录制中，本次上传已经完成。"
				break
			else
				upload "$video"
			fi
		fi
		cur=$[cur + 1]
	done

	delete
}


while :
do
	date +%F_%X
	main
	sleep $[1*60]
done
