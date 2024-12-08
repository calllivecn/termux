# 使用pyinstaller 把 supervisor 打包独立的可执行文件。以防止 python 更新时，破坏了 supervisor的启动和执行。


## 需要在 virtualenv 中打包

```shell
virtualenv ~/.venv/supervisor/

. ~/.venv/supervisor/bin/activate

pip install pyinstaller supervisor


pyinstaller supervisord.spec
pyinstaller supervisorctl.spec

# 生成dist/目录下

# ! 在执行时，需要设置临时目录 export TMP=/data/data/com.termux/files/usr/tmp

```
