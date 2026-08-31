#!/usr/bin/env python3
"""
Wayland 语音注入服务端
运行在 Wayland 桌面环境的 Linux 上。
接收 Termux 客户端发来的文本，通过 wl-copy + wl-paste 注入当前焦点输入框。

通信协议：长度前缀帧（4字节大端长度头 + UTF-8 消息体），不使用 \\n 分隔。
支持 argparse 命令行参数。
"""
import argparse
import shutil
import socket
import struct
import subprocess
import sys
import threading

# 单条消息最大字节数（防止异常长度），10 MB 足够
MAX_MSG_SIZE = 10 * 1024 * 1024


# ---------------- 长度前缀协议 ----------------
def send_msg(sock: socket.socket, data: bytes) -> None:
    """发送一条消息：4字节长度头 + 消息体"""
    header = struct.pack("!I", len(data))
    sock.sendall(header + data)


def send_str(sock: socket.socket, text: str) -> None:
    send_msg(sock, text.encode("utf-8"))


def recv_exact(sock: socket.socket, n: int) -> bytes:
    """精确接收 n 字节，连接断开时抛异常"""
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            raise ConnectionError("连接已关闭")
        buf += chunk
    return buf


def recv_msg(sock: socket.socket) -> bytes:
    """接收一条消息：先读 4 字节长度，再读消息体"""
    header = recv_exact(sock, 4)
    (length,) = struct.unpack("!I", header)
    if length > MAX_MSG_SIZE:
        raise ValueError(f"消息过大: {length} 字节")
    return recv_exact(sock, length)


def recv_str(sock: socket.socket) -> str:
    return recv_msg(sock).decode("utf-8", errors="replace")


# ---------------- 注入逻辑 ----------------
def check_deps() -> None:
    """启动前检查必要命令"""
    missing = [c for c in ("wl-copy", "wl-paste", "mouse.pyz") if not shutil.which(c)]
    if missing:
        print(f"❌ 缺少命令: {', '.join(missing)}")
        print("   安装: sudo apt install wl-clipboard wtype")
        sys.exit(1)


def inject_text(text: str) -> None:
    """wl-copy 写入剪贴板，再 wl-paste 注入当前焦点窗口"""
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

    cmd = ["wl-paste"]
    cmd = ["mouse.pyz", "--ctrlkey", "v"]

    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        print(f"   ⚠️  {cmd} 失败: {result.stderr.decode(errors='replace').strip()}")
    else:
        print(f"   ✅ 注入成功: {text}")


# ---------------- 客户端处理 ----------------
def handle_client(conn: socket.socket, addr, secret: str) -> None:
    try:
        # 第一条消息必须是 token
        token = recv_str(conn)
        if token != secret:
            print(f"   ❌ 鉴权失败，断开: {addr}")
            send_str(conn, "AUTH FAILED")
            return
        print(f"   🔐 鉴权通过: {addr}")
        send_str(conn, "AUTH OK")

        # 循环接收文本并注入
        while True:
            text = recv_str(conn)
            if text.strip():
                inject_text(text)
    except ConnectionError:
        print(f"   🔌 连接关闭: {addr}")
    except Exception as e:
        print(f"   ⚠️  处理 {addr} 出错: {e}")
    finally:
        conn.close()


# ---------------- 主入口 ----------------
def parse_args():
    parser = argparse.ArgumentParser(
        description="Wayland 语音注入服务端（长度前缀协议 + token 鉴权）"
    )
    parser.add_argument("--host", default="0.0.0.0",
                        help="监听地址（默认 0.0.0.0）")
    parser.add_argument("--port", type=int, default=9999,
                        help="监听端口（默认 9999）")
    parser.add_argument("--secret", default="my-secret-token",
                        help="鉴权密钥（默认 my-secret-token）")
    return parser.parse_args()


def main():
    args = parse_args()
    check_deps()

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((args.host, args.port))
    srv.listen(5)
    print(f"🟢 Wayland 语音注入服务已启动，监听 {args.host}:{args.port}")
    print("   在 Termux 运行 termux.py 即可开始使用")

    try:
        while True:
            conn, addr = srv.accept()
            print(f"📱 新连接: {addr}")
            threading.Thread(
                target=handle_client,
                args=(conn, addr, args.secret),
                daemon=True,
            ).start()
    except KeyboardInterrupt:
        print("\n🛑 服务已停止")
    finally:
        srv.close()


if __name__ == "__main__":
    main()
