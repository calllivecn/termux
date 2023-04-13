
export PATH=$PATH:/data/data/com.termux/files/usr/bin

CWD=$(cd $(dirname "${0}");pwd)
#CWD=$(readlink -f "${0}")

cd ${CWD}
echo ${CWD}

# HOME 需要 绝对路径
export HOME="$(readlink -f ${CWD}/../ttyd)"

echo "define HOME direcory: $HOME"

if [ ! -d $HOME ];then
	mkdir -p $HOME
fi

# 之前启动的有这报错。。。 ttyd: not found
# wait PATH ???
if type ttyd;then
    :
else
    sleep 1
fi

# v1.7.3 支持ipv6
ttyd -6 -p 8886 \
	-c 'zx:huawei.linux' \
	--ssl --ssl-cert server.crt --ssl-key server.key \
	--cwd $HOME \
	bash --login
	#bash --init-file bashrc
