#!/usr/bin/env python3
"""
Wayland 语音注入服务端
在 Wayland 桌面环境的 Linux 上运行。
接收 Termux 客户端发来的文本，通过 wl-copy + wl-paste 注入当前焦点输入框。
带 token 鉴权。
"""
import socket
import subprocess
import threading
import shutil
import sys

# ================== 配置区 ==================
HOST = "0.0.0.0"          # 监听地址，0.0.0.0 表示所有网卡
PORT = 9999               # 监听端口
SECRET = "my-secret-token"  # ← 改成你自己的密钥（与客户端保持一致）
# ============================================


def check_deps():
    """启动前检查必要命令是否存在"""
    missing = [cmd for cmd in ("wl-copy", "wl-paste") if not shutil.which(cmd)]
    if missing:
        print(f"❌ 缺少命令: {', '.join(missing)}")
        print("   安装: sudo apt install wl-clipboard wtype")
        sys.exit(1)


def inject_text(text: str):
    """
    Wayland 注入流程：
    1. wl-copy 将文本写入 Wayland 剪贴板
    2. wl-paste 将剪贴板内容作为键盘输入发送到当前焦点窗口
    """
    # Step 1: 写入剪贴板
    p = subprocess.Popen(
        ["wl-copy"],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    _, err = p.communicate(text.encode("utf-8"))
    if p.returncode != 0:
        print(f"   ⚠️  wl-copy 失败: {err.decode(errors='replace').strip()}")
        return

    # Step 2: 粘贴到当前焦点窗口
    #cmd = ["wl-paste"]
    cmd = ["mouse.pyz", "--ctrlkey", "v"]
    result = subprocess.run(cmd, capture_output=True)

    if result.returncode != 0:
        print(f"   ⚠️  {cmd} 失败: {result.stderr.decode(errors='replace').strip()}")
    else:
        print(f"   ✅ 注入成功: {text}")


def handle_client(conn: socket.socket, addr):
    """处理单个客户端连接：先鉴权，再循环接收文本"""
    buf = b""
    authenticated = False
    try:
        while True:
            data = conn.recv(4096)
            if not data:
                break
            buf += data

            # 按行解析
            while b"\n" in buf:
                line, buf = buf.split(b"\n", 1)
                line = line.decode("utf-8", errors="replace")

                # 第一条消息必须是 token
                if not authenticated:
                    if line == SECRET:
                        authenticated = True
                        print(f"   🔐 鉴权通过: {addr}")
                    else:
                        print(f"   ❌ 鉴权失败，断开: {addr}")
                        conn.sendall("AUTH FAILED\n".encode())
                        return
                    continue

                # 已鉴权：注入文本
                if line.strip():
                    inject_text(line)
    finally:
        print(f"   🔌 断开: {addr}")
        conn.close()


def main():
    check_deps()

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((HOST, PORT))
    srv.listen(5)
    print(f"🟢 Wayland 语音注入服务已启动，监听 {HOST}:{PORT}")
    print("   在 Termux 运行 termux.py 即可开始使用")

    try:
        while True:
            conn, addr = srv.accept()
            print(f"📱 新连接: {addr}")
            threading.Thread(
                target=handle_client, args=(conn, addr), daemon=True
            ).start()
    except KeyboardInterrupt:
        print("\n🛑 服务已停止")
    finally:
        srv.close()


if __name__ == "__main__":
    main()

