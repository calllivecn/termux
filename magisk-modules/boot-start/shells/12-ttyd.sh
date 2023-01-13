
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

ttyd -p 8886 \
	-c 'zx:huawei.linux' \
	--ssl --ssl-cert server.crt --ssl-key server.key \
	--cwd $HOME \
	bash --login
	#bash --init-file bashrc
