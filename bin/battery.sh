#!/bin/bash
# date 2023-07-08 18:27:28
# author calllivecn <c-all@qq.com>

get_timestamp(){
python <<EOF
import time
print(time.time())
EOF
}

sub(){
python <<EOF
i = $1 - $2
if i > 5:
    print(0)
else:
    print(round(i, 3))
EOF
}

t1=
t2=
while :
do
    echo "==============="
    t1=$(get_timestamp)
    date "+%F_%T"
    termux-battery-status
    t2=$(get_timestamp)
    t3=$(sub $t2 $t1)
    sleep $t3
done
