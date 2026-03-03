#!/usr/bin/env python3
"""
Gateway Watchdog - 监控 OpenClaw Gateway 稳定性
每 10 秒检查一次，连续 2 次失败自动重启

支持 Windows 和 Linux
"""

import subprocess
import time
import os
import sys
import platform
from pathlib import Path

# 根据系统选择日志路径
if platform.system() == "Windows":
    LOG_FILE = Path(os.path.expandvars("%USERPROFILE%")) / ".openclaw" / "gateway_watchdog.log"
else:
    LOG_FILE = Path.home() / ".openclaw" / "gateway_watchdog.log"

CHECK_INTERVAL = 10  # 秒
FAIL_THRESHOLD = 2   # 连续失败次数

def get_openclaw_cmd() -> list:
    """获取系统对应的 openclaw 命令"""
    system = platform.system()
    
    if system == "Windows":
        # Windows: openclaw.ps1
        return ["openclaw.ps1", "gateway", "status"]
    else:
        # Linux/Mac: openclaw
        return ["openclaw", "gateway", "status"]

def get_openclaw_restart_cmd() -> list:
    """获取系统对应的 openclaw 重启命令"""
    system = platform.system()
    
    if system == "Windows":
        return ["openclaw.ps1", "gateway", "restart"]
    else:
        return ["openclaw", "gateway", "restart"]

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
        cmd = get_openclaw_cmd()
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=15,
            shell=(platform.system() == "Windows")
        )
        return result.returncode == 0
    except Exception as e:
        log(f"检查失败: {e}")
        return False

def restart_gateway():
    """重启 Gateway"""
    try:
        log("Gateway 连续失败，准备重启...")
        cmd = get_openclaw_restart_cmd()
        subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60,
            shell=(platform.system() == "Windows")
        )
        log("Gateway 重启命令已发送")
        return True
    except Exception as e:
        log(f"重启失败: {e}")
        return False

def main():
    system = platform.system()
    log("=" * 50)
    log(f"Gateway Watchdog 启动 ({system})")
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
