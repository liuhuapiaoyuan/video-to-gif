@echo off
chcp 65001 >nul

echo.
echo =================================
echo     自动更新发布文件
echo =================================
echo.

REM 检查是否存在编译好的文件
if not exist "target\release\video-gif.exe" (
    echo ❌ 错误：未找到编译好的 video-gif.exe
    echo 请先运行: cargo build --release
    echo.
    pause
    exit /b 1
)

REM 创建或清理发布目录
echo 📁 准备发布目录...
if exist releases rmdir /s /q releases
mkdir releases

REM 复制必要文件到发布目录
echo 📦 复制发布文件...
copy target\release\video-gif.exe releases\ >nul
copy ffmpeg.exe releases\ >nul
copy video-gif.bat releases\ >nul
copy README.MD releases\ >nul
copy LICENSE releases\ >nul

echo ✅ 发布文件已更新！
echo 📁 发布目录: releases\
echo.
echo 📋 包含文件：
echo   - video-gif.exe (主程序)
echo   - ffmpeg.exe (FFmpeg库)
echo   - video-gif.bat (拖拽脚本)
echo   - README.MD (说明文档)
echo   - LICENSE (许可证)
echo. 