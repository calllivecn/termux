#!/bin/bash

set -xe

safe_exit(){
	rm -vf "$FIFO"
}

#trap safe_exit ERR EXIT SIGINT SIGTERM

sdcard="/storage/emulated/0"

OUTFILE="termux-backup-$(date +%F).tar.gz"
OUTFILE_sha256="termux-backup-$(date +%F).tar.gz.sha256"

#FIFO=$(mktemp -u)
#mkfifo "$FIFO"

apt clean

cd

cd ..

tar --exclude home/.cache --exclude */__pycache__ -zcvO . | tee "$sdcard/$OUTFILE" |sha256sum |awk -v filename="$OUTFILE" '{print $1,filename}' |tee "$sdcard/$OUTFILE_sha256"

