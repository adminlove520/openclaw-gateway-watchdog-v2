#!/bin/bash
#
# 查看 Gateway Watchdog 状态
#

PID_FILE="/root/.openclaw/gateway_watchdog.pid"
LOG_FILE="/root/.openclaw/gateway_watchdog.log"

echo "=== Gateway Watchdog 状态 ==="

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "状态: 🟢 运行中"
        echo "PID: $PID"
    else
        echo "状态: 🔴 已停止 (PID 文件过期)"
    fi
else
    echo "状态: 🔴 未运行"
fi

echo ""
echo "=== 最近日志 (最后 10 行) ==="
if [ -f "$LOG_FILE" ]; then
    tail -n 10 "$LOG_FILE"
else
    echo "日志文件不存在"
fi

echo ""
echo "=== Gateway 状态 ==="
openclaw gateway status
