#!/data/data/com.termux/files/usr/bin/bash
# -------------------------------------------------------------------
# safe-tts.sh - 线程安全的 termux-tts-speak 封装脚本
# -------------------------------------------------------------------

# 1. 定义全局互斥锁文件
LOCK_FILE="${TMPDIR:-/tmp}/termux_tts.lock"

# 2. 安全朗读函数
safe_tts() {
    local text="$*"
    
    # 如果没有传入文本，尝试从标准输入 (stdin) 读取
    if [ -z "$text" ] && [ ! -t 0 ]; then
        text=$(cat)
    fi

    if [ -z "$text" ]; then
        echo "Usage: safe_tts <text_to_speak>" >&2
        return 1
    fi

    # 利用文件描述符 200 建立互斥锁
    # flock -x (排队等待独占锁)
    (
        # 尝试获取锁，如果其他进程在朗读，当前进程在此排队等待
        flock -x 200 || exit 1

        # 捕获异常中断 (INT/TERM)，确保用户 Ctrl+C 时清理底层卡死的 API 客户端
        trap 'pkill -9 -P $$ termux-api 2>/dev/null; exit 130' INT TERM

        # 调用 Termux 原生 TTS 朗读
        termux-tts-speak "$text"

    ) 200>"$LOCK_FILE"
}

# -------------------------------------------------------------------
# 测试/调用入口
# -------------------------------------------------------------------
# 如果该脚本被直接执行，而非 source 引入：
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    safe_tts "$@"
fi

