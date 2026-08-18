# supervisord 配置+使用说明

## update: 使用pyinstaller 打包，以解决，更新python 大版本后，supervisor 路径变化，导致的重启会失败的问题。

## 准备工作在 boot-start/shells/添加30-supervisord.sh 开机启动


## 初始化 准备工作

- 把当前目录 cp -av 到 root/.supervisord/ 以安装 supervisod
- cd root/.supervisord/
- mkdir -vp logs inis


## 然后在配置 inis/*.ini


## 最后启动supervisord


---


# 下面是为你编写的 `README.md` 说明文档，你可以直接复制并放置在脚本同级目录下：


# PyInstaller Termux Dependency Collector (`pyinstaller_termux_deps.py`)

在 Termux 环境下使用 PyInstaller 打包 Python 程序时，常因 `dlopen` 隐式加载或非标准 RPATH 等原因，导致部分 C/C++ 扩展或依赖库未被完全打包进 `_internal/` 目录。

`pyinstaller_termux_deps.py` 是一个用于自动修复此类隐式依赖丢失问题的工具。它通过调用 `ldd` 递归扫描打包生成目录中的所有 `.so` 文件，捕获依赖于 Termux 环境（默认 `/data/data/com.termux/files/`）的动态库，并将其补全复制到应用程序的 `_internal/` 目录中。

---

## 核心特性

* **多轮迭代递归收敛**：自动分析新补全的 `.so` 库本身的间接依赖，进行增量轮询扫描，直到所有依赖完全收敛。
* **`LD_LIBRARY_PATH` 实时注入**：每次执行 `ldd` 时自动包含 `_internal/` 目录，使 `ldd` 优先链接已复制的本地库，彻底消除误判定与重复拷贝。
* **SONAME 与版本号双重处理**：自动解析 `ldd` 输出的请求库名称（如 `libssl.so.3`）与磁盘真实文件名（如 `libssl.so.3.0.0`），确保两者在 `_internal/` 目录中均正常存在，避免运行时出现 `cannot open shared object file` 崩溃。
* **支持 Dry-Run 演练**：提供 `--dry-run` 标志，可提前预览需要补全的文件列表而不做任何实际写入。

---

## 环境要求

* Python 3.9+
* Linux / Termux 环境（必须包含 `ldd` 命令）

---

## 安装与设置

确保脚本具备可执行权限：

```bash
chmod +x pyinstaller_termux_deps.py

```

---

## 参数说明

```text
用法: pyinstaller_termux_deps.py [-h] -d CHECK_DIR [-p PREFIX] [--dry-run]

自动扫描并补全 PyInstaller 打包目录中缺失的动态链接库 (.so)

选项:
  -h, --help            显示帮助信息并退出
  -d CHECK_DIR, --check-dir CHECK_DIR
                        [必填] PyInstaller 打包生成的目录路径 (例如 dist/app 或 dist/app/_internal)
  -p PREFIX, --prefix PREFIX
                        需要捕获的共享库路径前缀 (默认: /data/data/com.termux/files/)
  --dry-run             仅演练显示需要复制的文件，不执行实际复制操作

```

---

## 使用示例

### 1. 标准补全工作流

在执行完 PyInstaller 打包命令后，运行本脚本对构建结果进行自动化修复：

```bash
# 1. PyInstaller 打包
pyinstaller --onedir main.py

# 2. 补全 Termux 依赖项
python3 pyinstaller_termux_deps.py --check-dir dist/main

```

### 2. 模拟演练（Dry-Run）

如果你只想检查打包结果缺失了哪些 Termux 动态库，而不希望改变文件系统：

```bash
python3 pyinstaller_termux_deps.py -d dist/main --dry-run

```

### 3. 自定义捕获前缀

如果你的交叉编译环境或安装路径不在默认的 Termux 目录，可以使用 `-p` 参数显式指定前缀：

```bash
python3 pyinstaller_termux_deps.py -d dist/main -p /data/data/com.myenv/

```

---

## 工作原理

1. **查找文件**：深度优先遍历 `--check-dir` 路径下包含 `.so` 的文件（如 `.so`, `.so.1`, `.so.1.8`）。
2. **依赖分析**：构造包含 `LD_LIBRARY_PATH=<check_dir>/_internal` 的隔离环境变量，调用 `ldd` 命令解析 ELF 依赖关系。
3. **筛选匹配**：使用正则筛选 `ldd` 输出中 `=>` 右侧指向目标路径前缀（默认 `/data/data/com.termux/files/`）的链接项。
4. **安全补全**：将依赖的 `.so` 文件拷贝至 `_internal/` 目录，并确保读/执行权限设置正确 (`0644`)。
5. **增量收敛**：重复步骤 1~4，直到上一轮循环中没有产生任何新文件的补充，表示依赖完全解决并安全退出。

