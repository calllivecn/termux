
TERMUX_HOME="/data/data/com.termux/files"

if [ -d "${TERMUX_HOME}/root" ];then
    :
else
    mkdir -vp "${TERMUX_HOME}/root"
fi

export HOME="${TERMUX_HOME}/root"


echo "define HOME direcory: $HOME"

# 之前启动的有这报错。。。 ttyd: not found
# wait PATH ???
if type ttyd;then
    :
else
    sleep 3
fi


# 配合 nginx 使用
ttyd -i 127.0.0.1 -p 57681 \
	--cwd $HOME \
	bash --login
	#bash --init-file bashrc
