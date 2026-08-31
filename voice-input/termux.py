#!/usr/bin/env python3
"""
Termux 语音输入客户端
在 Termux 上运行，连接 Linux 服务端。
input() 调用安卓输入法（含语音识别），回车发送文本。
带 token 鉴权。
"""
import socket
import sys

# ================== 配置区 ==================
SERVER_HOST = "10.1.3.1"   # ← 改成你 Linux 机器的 IP
SERVER_PORT = 9999              # 与服务端一致
SECRET = "my-secret-token"      # 与服务端保持一致
# ============================================


def main():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((SERVER_HOST, SERVER_PORT))
    except Exception as e:
        print(f"❌ 连接失败: {e}")
        sys.exit(1)

    print(f"已连接 {SERVER_HOST}:{SERVER_PORT}，正在鉴权...")

    # 发送 token 鉴权
    s.sendall((SECRET + "\n").encode("utf-8"))

    # 检查鉴权结果（服务端失败时会发回 AUTH FAILED）
    s.settimeout(2.0)
    try:
        resp = s.recv(1024).decode("utf-8", errors="replace")
        if "AUTH FAILED" in resp:
            print("❌ 鉴权失败，请检查 SECRET 是否一致")
            s.close()
            sys.exit(1)
    except socket.timeout:
        pass  # 没有错误响应 = 鉴权通过
    s.settimeout(None)

    print("🔐 鉴权通过！输入后回车发送，Ctrl+C 退出")
    print("-" * 40)

    try:
        while True:
            try:
                text = input("🎤 ")
            except EOFError:
                break
            if not text.strip():
                continue
            s.sendall((text + "\n").encode("utf-8"))
            print("   ✅ 已发送")
    except (KeyboardInterrupt, BrokenPipeError, ConnectionResetError):
        print("\n👋 退出")
    finally:
        s.close()


if __name__ == "__main__":
    main()

