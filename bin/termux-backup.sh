#!/bin/bash
#
#
# termux-backup 也是使用 tar 的 shell 脚本， 并且 包含了 $PREFIX/var/lib/proot-distro/ 目录
#


set -e

FIFO=$(mktemp -u)

DATE=$(date +%F_%X)

FILENAME="termux-backup-${TERMUX_HOSTNAME}-${DATE}.tza"
FILENAME_SHA256="${FILENAME}.sha256"


OUTFILE="${HOME}/storage/shared/${FILENAME}"
OUTFILE_SHA256="${HOME}/storage/shared/${FILENAME_SHA256}"

errror_exit_clear(){
	rm -vf "${OUTFILE}"
	rm -vf "${OUTFILE_SHA256}"
}

safe_exit(){
	rm -vf "$FIFO"
}

trap safe_exit EXIT

trap error_exit_clear SIGTERM SIGINT ERR

mkfifo "$FIFO"

#apt clean

#SYS="--exclude=usr/tmp/* --exclude=usr/run/* --exclude=usr/var/run/*"
#USER_EXCLUDE="--exclude=home/storage --exclude */__pycache__"

if [ "$1"x = x ];then
	echo "Usage: <password>"
	echo "Usage: <password> [prompt]"
	exit 1

elif [ -n "$1" ] && [ "$2"x = x ];then
	time { termux-backup --ignore-read-failure - | zstd -T0 -c | crypto.py -i - -o - -k "$2" | tee "$OUTFILE" |sha256sum |awk -v filename="$FILENAME" '{print $1,filename}' |tee "$OUTFILE_SHA256"; }

elif [ -n "$1" ] && [ -n "$2" ];then
	time { termux-backup --ignore-read-failure - | zstd -T0 -c | crypto.py -i - -o - -k "$1" -p "$2" | tee "$OUTFILE" |sha256sum |awk -v filename="$FILENAME" '{print $1,filename}' |tee "$OUTFILE_SHA256"; }

else
	echo "未知选项"
	echo "Usage: <password>"
	echo "Usage: <password> [prompt]"
	exit 1
fi


