#!/bin/bash
#
# 停止 Gateway Watchdog
#

PID_FILE="/root/.openclaw/gateway_watchdog.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "未找到 PID 文件，可能未运行"
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null 2>&1; then
    echo "停止 Gateway Watchdog (PID: $PID)..."
    kill "$PID"
    rm -f "$PID_FILE"
    echo "✅ 已停止"
else
    echo "进程已不存在，清理 PID 文件"
    rm -f "$PID_FILE"
fi
