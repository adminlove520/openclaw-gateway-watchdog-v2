@echo off
REM OpenClaw Gateway Watchdog 启动脚本
REM 用 nohup + setsid 确保断终端也不死

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PYTHON_SCRIPT=%SCRIPT_DIR%gateway_watchdog.py"
set "LOG_FILE=C:\Users\whoami\.openclaw\gateway_watchdog.log"
set "PID_FILE=C:\Users\whoami\.openclaw\gateway_watchdog.pid"

REM 确保日志目录存在
if not exist "%LOG_FILE%" (
    echo. > "%LOG_FILE%"
)

REM 检查 Python 脚本是否存在
if not exist "%PYTHON_SCRIPT%" (
    echo 错误: 找不到 %PYTHON_SCRIPT%
    exit /b 1
)

REM 检查是否已经运行
if exist "%PID_FILE%" (
    set /p OLD_PID=<"%PID_FILE%"
    for /f "tokens=5" %%a in ('wmic process where "ProcessId=%OLD_PID%" get Name 2^>nul') do (
        if "%%a"=="" (
            del "%PID_FILE%" 2>nul
        ) else (
            echo Watchdog 已在运行 (PID: %OLD_PID%)
            exit /b 0
        )
    )
)

echo 启动 Gateway Watchdog...
start /b python "%PYTHON_SCRIPT%" >> "%LOG_FILE%" 2>&1

timeout /t 2 /nobreak >nul

for /f "tokens=5" %%a in ('wmic process where "name='python.exe'" get ProcessId 2^>nul') do (
    set "NEW_PID=%%a"
)

if defined NEW_PID (
    echo !NEW_PID! > "%PID_FILE%"
    echo Gateway Watchdog 已启动 (PID: !NEW_PID!)
    echo 日志文件: %LOG_FILE%
    echo. ✅ 启动成功
) else (
    echo. ❌ 启动: %LOG_FILE失败，请检查日志%
    exit /b 1
)
