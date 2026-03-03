#!/bin/bash
#
# OpenClaw Gateway Watchdog 启动脚本
# 用 nohup + setsid 确保断终端也不死
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/gateway_watchdog.py"
LOG_FILE="/root/.openclaw/gateway_watchdog.log"
PID_FILE="/root/.openclaw/gateway_watchdog.pid"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 检查 Python 脚本是否存在
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "错误: 找不到 $PYTHON_SCRIPT"
    exit 1
fi

# 检查是否已经运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Watchdog 已在运行 (PID: $OLD_PID)"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# 用 setsid + nohup 启动，确保终端断开也不死
echo "启动 Gateway Watchdog..."
setsid nohup python3 "$PYTHON_SCRIPT" >> "$LOG_FILE" 2>&1 &

NEW_PID=$!
echo "$NEW_PID" > "$PID_FILE"

echo "Gateway Watchdog 已启动 (PID: $NEW_PID)"
echo "日志文件: $LOG_FILE"

# 等待 2 秒检查是否成功启动
sleep 2
if ps -p "$NEW_PID" > /dev/null 2>&1; then
    echo "✅ 启动成功"
else
    echo "❌ 启动失败，请检查日志: $LOG_FILE"
    exit 1
fi
