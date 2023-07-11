#!/bin/bash
# date 2023-07-11 20:09:39
# author calllivecn <c-all@qq.com>


CWD=$(cd "$(dirname "${0}")";pwd)

CONF="${CWD}/miio.conf"

CWD=$(cd ${CWD}/.. ;pwd)
parent=$(cd ${CWD}/.. ;pwd)


PY="$parent/hoem/.venv/miio/bin/python"


if [ -x "$PY" ];then
    :
else
    echo "没有miio 虚拟环境"
    exit 1
fi

MIIO="$CWD/bin/miio.py"

if [ -r "$MIIO" ];then
    :
else
    echo "没有 ${MIIO} 文件"
    exit 1
fi

source "$CONF"

$PY 

