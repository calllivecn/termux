#!/usr/bin/env python3
"""
Termux 语音输入客户端
运行在 Termux 上，连接 Linux 服务端。
input() 调用安卓输入法（含语音识别），回车发送文本。

通信协议：长度前缀帧（4字节大端长度头 + UTF-8 消息体），不使用 \\n 分隔。
支持 argparse 命令行参数。
"""
import argparse
import socket
import struct
import sys

MAX_MSG_SIZE = 10 * 1024 * 1024


# ---------------- 长度前缀协议 ----------------
def send_msg(sock: socket.socket, data: bytes) -> None:
    header = struct.pack("!I", len(data))
    sock.sendall(header + data)


def send_str(sock: socket.socket, text: str) -> None:
    send_msg(sock, text.encode("utf-8"))


def recv_exact(sock: socket.socket, n: int) -> bytes:
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            raise ConnectionError("连接已关闭")
        buf += chunk
    return buf


def recv_msg(sock: socket.socket) -> bytes:
    header = recv_exact(sock, 4)
    (length,) = struct.unpack("!I", header)
    if length > MAX_MSG_SIZE:
        raise ValueError(f"消息过大: {length} 字节")
    return recv_exact(sock, length)


def recv_str(sock: socket.socket) -> str:
    return recv_msg(sock).decode("utf-8", errors="replace")


# ---------------- 主入口 ----------------
def parse_args():
    parser = argparse.ArgumentParser(
        description="Termux 语音输入客户端（长度前缀协议 + token 鉴权）"
    )
    parser.add_argument("--host", default="192.168.1.100",
                        help="Linux 服务端 IP（默认 192.168.1.100）")
    parser.add_argument("--port", type=int, default=9999,
                        help="服务端端口（默认 9999）")
    parser.add_argument("--secret", default="my-secret-token",
                        help="鉴权密钥（默认 my-secret-token）")
    return parser.parse_args()


def main():
    args = parse_args()

    # 连接
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((args.host, args.port))
    except Exception as e:
        print(f"❌ 连接失败: {e}")
        sys.exit(1)

    print(f"已连接 {args.host}:{args.port}，正在鉴权...")

    # 发送 token 并等待响应
    try:
        send_str(s, args.secret)
        resp = recv_str(s)
    except Exception as e:
        print(f"❌ 鉴权通信失败: {e}")
        s.close()
        sys.exit(1)

    if resp != "AUTH OK":
        print(f"❌ 鉴权失败（服务端返回: {resp}），请检查 --secret")
        s.close()
        sys.exit(1)

    print("🔐 鉴权通过！输入后回车发送，Ctrl+C 退出")
    print("-" * 40)

    # 循环读取并发送
    try:
        while True:
            try:
                text = input("🎤 ")
            except EOFError:
                break
            if not text.strip():
                continue
            send_str(s, text)
            print("   ✅ 已发送")
    except (KeyboardInterrupt, BrokenPipeError, ConnectionResetError):
        print("\n👋 退出")
    finally:
        s.close()


if __name__ == "__main__":
    main()
