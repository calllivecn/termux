#!/data/data/com.termux/files/usr/bin/sh
# date 2026-01-17 02:03:07
# author calllivecn <c-all@qq.com>

# ==========================================================
# 脚本用途：检测 supervisord 状态，未运行则根据指定配置启动
# 调用频率：外部定时触发（如 crontab 或 systemd timer）
# ==========================================================

# 1. 定义配置文件的绝对路径（建议根据实际情况修改）
CONF_FILE="$HOME/.supervisord/supervisord.ini"


LOG="$HOME/.supervisord/job-scheduler-boot.log"

if [ -d $HOME/.local/bin ];then
    export PATH=$HOME/.local/bin:$PATH
fi


# 2. 检测 supervisord 是否在运行
# supervisorctl pid 如果能获取到 PID 且返回值为 0，说明服务端正常
if supervisorctl pid >/dev/null 2>&1; then
    # 正常运行，直接退出
    # 这里不需要任何输出，保持 quiet 模式符合高级用户习惯
    exit 0
else
    # 3. 未运行或连接失败，尝试启动
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Supervisord is not running. Starting..." >> "$LOG"
    
    # 检查配置文件是否存在
    if [ ! -f "$CONF_FILE" ]; then
        echo "Error: Configuration file not found at $CONF_FILE" >> "$LOG"
        exit 1
    fi  

    # 执行启动命令
    # 注意：如果是在非交互式环境下，建议使用绝对路径调用 supervisord
    supervisord -c "$CONF_FILE"
    
    # 检查启动是否成功
    if [ $? -eq 0 ]; then
        echo "Supervisord started successfully." >> "$LOG"
    else
        echo "Failed to start Supervisord." >> "$LOG"
        exit 1
    fi  
fi
