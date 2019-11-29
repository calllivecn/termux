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

SYS="$PREFIX/usr"

HOME="home"

tar -C $PREFIX --exclude $SYS --exclude $HOME --exclude */__pycache__ -zcvO . | tee "$sdcard/$OUTFILE" |sha256sum |awk -v filename="$OUTFILE" '{print $1,filename}' |tee "$sdcard/$OUTFILE_sha256"

