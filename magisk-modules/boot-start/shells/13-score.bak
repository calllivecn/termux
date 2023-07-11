

# 注意 busybox 子命令的不同

apps="
com.termux
com.wireguard.android
com.pas.webcam
"

log(){
	echo "$(date +%F_%X): $@"
}

findpid(){
    local app="$1" pid cmdline
    for pid in $(ps |grep "$app" |grep -v grep |awk '{print $1}')
    do
        if [ -r /proc/$pid/cmdline ];then
            cmdline=$(cat /proc/$pid/cmdline)
        else
            cmdline=""
        fi

        if [ "$cmdline"x = "$app"x ];then
            echo $pid
            break
        fi
    done
}


SCORE="-1000"

app_score_adj(){
    #p=$(ps -o comm,pid)
    for app in $apps
    do
        #pid=$(ps -o comm,pid |grep -E "^${app} +[0-9]+" |awk '{print $2}')
        pid=$(findpid "$app")
        oom_score_adj="/proc/$pid/oom_score_adj"
        if [ -r $oom_score_adj ];then
            score=$(cat $oom_score_adj)
            if [ "$score"x != "$SCORE"x ];then
                echo -1000 > $oom_score_adj
	    	    log "app:$app pid:$pid oom_score_adj: $score --> $SCORE"
	    	fi
        #else
            #log "app:$app 可能已经退出"
        fi

    done
}



while :
do
    app_score_adj
    sleep 3
done

