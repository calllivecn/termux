#!/bin/bash
# date 2023-10-25 00:23:48
# author calllivecn <c-all@qq.com>

cd pyjnius
#export CFLAGS="-I/data/data/com.termux/files/usr/include/python3.9"
export CFLAGS="-I/data/data/com.termux/files/usr/include/python3.11"
export LDFLAGS="-L/data/data/com.termux/files/usr/lib"
python setup.py build_ext --inplace
python setup.py install

