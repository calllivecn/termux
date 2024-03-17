#!/bin/bash
# date 2023-01-08 03:00:36
# author calllivecn <c-all@qq.com>



# 设计？！
#

usage(){
echo "\
Usage: ${0##*/} [option]
    
--help

-s,--script [script]            添加一个新任务
-l, --list                      查看当前的任务
--cancel [job id]               取消指定的id的任务
--interval [number]             指定运行的时间间隔，单位是秒钟。范围要求: >=900(至少要大于15分钟) 默认:900
                                1.不同品牌的手机对job-scheduler功能的支持程度不一样。使用时需要实测。
                                2.虽然这里可以指定间隔时间，但是有的手机不会准确的按照间隔运行。需要实测。
--not-forever                   手机重启后之前的任务是否还生效。bool:true
                                1.重启后是否生效，不同手机也需要实测。
"
}


get_abspath(){
python <<EOF
from pathlib import Path
f = Path("$1")
print(f.absolute())
EOF
}

job_run(){
    job_abspath=$(get_abspath "$1")

    job_ids=$(termux-job-scheduler -p |wc -l)
    
    	#--network none \ 这个不行 会直接卡死
    #termux-job-scheduler \
    #	--job-id $job_ids \
    #	--period-ms 900000 \
    #	--battery-not-low false \
    #	--persisted true \
    #	--script "$job_abspath"
    
    termux-job-scheduler \
    	--job-id $job_ids \
    	--period-ms $INTERVAL \
    	--battery-not-low false \
    	--persisted $FOREVER \
    	--script "$job_abspath"
}

# termux 工具本身的选项
JOB=
JOB_ID=
INTERVAL=900000
NETWORK=
FOREVER="true"
selected(){
    #for arg in "$@"
    local arg args index args_len tmp
    args=("$@")
    args_len=${#args[@]}

    index=0
    while [ $index -lt $args_len ];
    do
        arg=${args[$index]}
        case $arg in
            -h|--help)
                usage
                exit 0
                ;;
            -s|--script)
                index=$[index+1]
                JOB="${args[$index]}"
                ;;
            --interval)
                # 单位是秒钟
                index=$[index+1]
                tmp="${args[$index]}"
                INTERVAL=$[$tmp * 1000]
                ;;
            --not-forever)
                FOREVER="false"
                ;;
            --cancel)
                index=$[index+1]
                JOB_ID="${args[$index]}"
                termux-job-scheduler --cancel --job-id "$JOB_ID"
                exit 0
                ;;
            -l|--list)
                termux-job-scheduler -p
                exit 0
                ;;
            *)
                echo "未知参数: $arg"
                usage
                exit 1
                ;;
    
        esac
    
        index=$[index+1]
    done
}

main(){
    if [ $# -eq 0 ];then
        usage
        exit 0
    fi

    # 解析参数
    selected "$@"

    if [ -n "$JOB" ];then
        job_run "$JOB"
    fi

}


main "$@"

