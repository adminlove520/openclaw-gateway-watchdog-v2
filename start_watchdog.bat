@echo off
REM OpenClaw Gateway Watchdog 启动脚本 (Windows)
REM 用 start /b 确保断终端也不死

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "PYTHON_SCRIPT=%SCRIPT_DIR%gateway_watchdog.py"
set "LOG_FILE=%USERPROFILE%\.openclaw\gateway_watchdog.log"
set "PID_FILE=%USERPROFILE%\.openclaw\gateway_watchdog.pid"

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
    wmic process where "ProcessId=%OLD_PID%" get Name >nul 2>&1
    if !errorlevel! equ 0 (
        echo Watchdog 已在运行 (PID: !OLD_PID!)
        exit /b 0
    ) else (
        del "%PID_FILE%" 2>nul
    )
)

echo 启动 Gateway Watchdog...
start /b python "%PYTHON_SCRIPT%" >> "%LOG_FILE%" 2>&1

timeout /t 2 /nobreak >nul

REM 查找 python 进程
for /f "tokens=5" %%a in ('wmic process where "name='python.exe'" get ProcessId /value 2^>nul') do (
    echo %%a | find "ProcessId" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=2 delims==" %%p in ("%%a") do (
            set "NEW_PID=%%p"
        )
    )
)

if defined NEW_PID (
    echo !NEW_PID! > "%PID_FILE%"
    echo Gateway Watchdog 已启动 (PID: !NEW_PID!)
    echo 日志文件: %LOG_FILE%
    echo. 
    echo ✅ 启动成功
) else (
    echo. 
    echo ❌ 启动失败，请检查日志: %LOG_FILE%
    exit /b 1
)
