# 成功打包 

## 成功打包了，libevdev py库 + 它使用了ctypes 方式， 导入了 libevdev.so.2 C库。

- 需要在py文件中添加这段代码：

```python
# 获取可执行文件所在的目录
if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
    so_path = Path(sys._MEIPASS) / "so_dir" 
elif __file__:
    so_path = os.path.dirname(__file__)

# 添加 .so 库所在的目录
logger.info(f"添加动态库路径: {so_path}")

if 'LD_LIBRARY_PATH' in os.environ:
    os.environ['LD_LIBRARY_PATH'] = str(so_path) + os.pathsep + os.environ['LD_LIBRARY_PATH']
else:
    os.environ['LD_LIBRARY_PATH'] = str(so_path)

```

- 需要在 *.spec 配置文件中，添加：

```python
    binaries=[("libevdev.so.2", "so_dir")],
    ...
    hiddenimports=["libevdev"],
    ...
```