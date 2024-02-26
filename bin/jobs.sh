#!/bin/bash
# date 2023-01-08 03:00:36
# author calllivecn <c-all@qq.com>



# 设计？！
#






get_abspath(){
python <<EOF
from pathlib import Path
f = Path("$1")
print(f.absolute())
EOF
}


job_abspath=$(get_abspath "$1")


job_ids=$(termux-job-scheduler -p |wc -l)

	#--network none \ 这个不行 会直接卡死
termux-job-scheduler \
	--job-id $job_ids \
	--period-ms 900000 \
	--battery-not-low false \
	--persisted true \
	--script "$job_abspath"
