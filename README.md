# OpenClaw Gateway Watchdog

> Gateway 24/7 稳定运行 watchdog

## 为什么需要

**不要用 OpenClaw 自己的 cron 监控 Gateway。** Gateway 挂了，cron job 根本收不到 wake event，形成死锁。

## 解决方案

用独立的 watchdog 跑在 OpenClaw 进程外部，每 10 秒检查一次，连续 2 次失败自动重启。

## 文件说明

| 文件 | 说明 |
|------|------|
| `gateway_watchdog.py` | 核心脚本 |
| `start_watchdog.bat` | Windows 启动脚本 |
| `start_watchdog.sh` | Linux 启动脚本 |
| `stop_watchdog.bat` | Windows 停止脚本 |
| `stop_watchdog.sh` | Linux 停止脚本 |
| `status_watchdog.bat` | Windows 状态脚本 |
| `status_watchdog.sh` | Linux 状态脚本 |

## 使用方法

### Windows

```batch
:: 启动
start_watchdog.bat

:: 查看状态
status_watchdog.bat

:: 停止
stop_watchdog.bat
```

### Linux

```bash
# 启动
./start_watchdog.sh

# 查看状态
./status_watchdog.sh

# 停止
./stop_watchdog.sh
```

### Docker (推荐)

```bash
# 后台运行
docker run -d --name watchdog \
  -v /var/run/docker.sock:/var/run/docker.sock \
  your-image

# 或用 docker-compose
```

## 日志

- Windows: `C:\Users\<用户名>\.openclaw\gateway_watchdog.log`
- Linux: `/root/.openclaw/gateway_watchdog.log`

## 配置

| 参数 | 默认值 | 说明 |
|------|--------|------|
| CHECK_INTERVAL | 10 | 检查间隔(秒) |
| FAIL_THRESHOLD | 2 | 连续失败次数 |

修改 `gateway_watchdog.py` 顶部的常量即可。

## 原理

| 方案 | 问题 |
|------|------|
| OpenClaw cron | Gateway 挂了 → cron 收不到 → 死锁 |
| 外部 watchdog | Gateway 挂了 → 外部进程检测到 → 触发重启 |

---

🦞 小溪的作品
