# OpenClaw Gateway Watchdog

> Gateway 24/7 稳定运行 watchdog

## 为什么需要

**不要用 OpenClaw 自己的 cron 监控 Gateway。** Gateway 挂了，cron job 根本收不到 wake event，形成死锁。

## 解决方案

用独立的 watchdog 跑在 OpenClaw 进程外部，每 10 秒检查一次，连续 2 次失败自动重启。

## 安装

```bash
# 克隆或下载
git clone https://github.com/adminlove520/openclaw-gateway-watchdog.git
cd openclaw-gateway-watchdog
```

## 使用方法

```bash
# 启动 watchdog（自动检测 openclaw 路径）
python gateway_watchdog.py start

# 查看状态
python gateway_watchdog.py status

# 重启 Gateway
python gateway_watchdog.py restart

# 停止 watchdog
python gateway_watchdog.py stop
```

## 特性

- ✅ 自动检测 Windows/Linux
- ✅ 自动查找 openclaw 命令路径
- ✅ 路径保存到配置文件 (`~/.openclaw/gateway_watchdog.json`)
- ✅ 单文件，无多余脚本
- ✅ 支持自定义检查间隔和失败阈值

## 配置

首次运行会自动检测 openclaw 并保存路径到:
- Windows: `C:\Users\<用户名>\.openclaw\gateway_watchdog.json`
- Linux: `~/.openclaw/gateway_watchdog.json`

## 日志

- Windows: `C:\Users\<用户名>\.openclaw\gateway_watchdog.log`
- Linux: `~/.openclaw/gateway_watchdog.log`

## 命令行选项

```bash
python gateway_watchdog.py start --interval 10 --threshold 2
```

| 参数 | 默认值 | 说明 |
|------|--------|------|
| --interval | 10 | 检查间隔(秒) |
| --threshold | 2 | 连续失败次数 |

---

🦞 小溪的作品
