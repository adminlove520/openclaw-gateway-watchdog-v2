#!/usr/bin/env python3
"""
Gateway Watchdog - 监控 OpenClaw Gateway 稳定性
每 10 秒检查一次，连续 2 次失败自动重启
"""

import subprocess
import time
import os
import sys
from pathlib import Path

LOG_FILE = Path(os.path.expanduser("~/.openclaw/gateway_watchdog.log"))
CHECK_INTERVAL = 10  # 秒
FAIL_THRESHOLD = 2   # 连续失败次数

def log(msg: str):
    """写日志到文件 + stdout"""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def check_gateway() -> bool:
    """检查 Gateway 是否正常运行"""
    try:
        result = subprocess.run(
            ["openclaw", "gateway", "status"],
            capture_output=True,
            text=True,
            timeout=15
        )
        return result.returncode == 0
    except Exception as e:
        log(f"检查失败: {e}")
        return False

def restart_gateway():
    """重启 Gateway"""
    try:
        log("Gateway 连续失败，准备重启...")
        subprocess.run(
            ["openclaw", "gateway", "restart"],
            capture_output=True,
            text=True,
            timeout=60
        )
        log("Gateway 重启命令已发送")
        return True
    except Exception as e:
        log(f"重启失败: {e}")
        return False

def main():
    log("=" * 50)
    log("Gateway Watchdog 启动")
    log(f"检查间隔: {CHECK_INTERVAL}s, 失败阈值: {FAIL_THRESHOLD}")
    log("=" * 50)

    consecutive_failures = 0

    while True:
        try:
            if check_gateway():
                if consecutive_failures > 0:
                    log(f"Gateway 恢复正常 (之前连续失败 {consecutive_failures} 次)")
                    consecutive_failures = 0
            else:
                consecutive_failures += 1
                log(f"Gateway 检查失败 ({consecutive_failures}/{FAIL_THRESHOLD})")

                if consecutive_failures >= FAIL_THRESHOLD:
                    restart_gateway()
                    consecutive_failures = 0  # 重置计数

        except Exception as e:
            log(f"循环异常: {e}")

        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
