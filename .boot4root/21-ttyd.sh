
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


# 配合 nginx 使用, v1.7.4 开始web终端默认是只读，添加上-w才可读写。
ttyd -i 127.0.0.1 -p 57681 -W \
	--cwd $HOME \
	bash --login
	#bash --init-file bashrc
