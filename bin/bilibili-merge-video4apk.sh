#!/data/data/com.termux/files/usr/bin/bash
# 2026-08-18_08:44:45
# 在安卓系统上。合并bilibili app 已经下载的视频

if [ "$1"x = "--help"x ] || [ "$1"x = "-h"x ];then
	echo "通过文件管理器把, Android/data/tv.danmaku.bili/download/"
	echo "目录中的视频目录移动或者复制来当前目录下:"
	echo "一次合并多个视频"
	exit 0

elif [ -d "$1" ];then
	IN_DIR="${1%/}"

else
	echo 输入需要目录
	exit 1
fi


video_dir=
for fd in $IN_DIR/*/*;
do
	echo "开始检测：${fd}"

	if [ -d "$fd" ];then
		video_dir="$fd"
		continue
	fi

	if [ -f "$fd" ] && [ "${fd##*/}"x = "cover.jpg"x ];then
		cover_jpg="${fd}"
		echo "找到封面图片"
		continue
	fi

	if [ -f "$fd" ] && [ "${fd##*/}"x = "entry.json"x ];then
		entry_json="${fd}"
		echo "找到 entry.json"
		continue
	fi

done


if [ -z "$video_dir" ];then
	echo "没有找到视频，音频目录"
	exit 1
fi

#检测下载完成没有
result=$(jsonfmt.py -d is_completed ${entry_json})
if [ "$result"x = Truex ];then
	:
else
	echo "还没有下载完！"
	exit 1
fi

#拿到标题, 当做文件名
filename=$(jsonfmt.py -d title ${entry_json})

set -x
ffmpeg -i "${video_dir}/video.m4s" -i "${video_dir}/audio.m4s" \
  -attach "${cover_jpg}" -metadata:s:t mimetype=image/jpeg \
  -map 0:v -map 1:a \
  -c:v copy -c:a copy \
  "${filename}.mkv"

