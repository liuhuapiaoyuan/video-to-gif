@echo off
chcp 65001 >nul

echo.
echo =================================
echo     Video-GIF 构建脚本
echo =================================
echo.

echo 🔧 开始构建 video-gif...
echo.

REM 清理之前的构建
echo 📁 清理之前的构建文件...
if exist target\release\video-gif.exe del target\release\video-gif.exe
if exist releases rmdir /s /q releases

REM 清理根目录下的可执行文件（如果存在）
if exist video-gif.exe del video-gif.exe

REM 创建发布目录
echo 📁 创建发布目录...
mkdir releases 2>nul

REM 构建项目
echo 🚀 编译项目 (Release模式)...
cargo build --release

if %ERRORLEVEL% neq 0 (
    echo ❌ 构建失败！
    pause
    exit /b 1
)

echo ✅ 构建成功！

REM 复制文件到发布目录
echo 📦 准备发布文件...
copy target\release\video-gif.exe releases\
copy ffmpeg.exe releases\
copy video-gif.bat releases\
copy demo.bat releases\
copy README.MD releases\
copy LICENSE releases\

echo.
echo 📋 发布文件列表：
dir releases

echo.
echo 🎉 构建完成！
echo 📁 发布文件位于: releases\ 目录
echo.
echo 💡 提示：
echo - video-gif.exe: 主程序
echo - ffmpeg.exe: 内置FFmpeg (必需)
echo - video-gif.bat: 拖拽支持脚本
echo - demo.bat: 演示脚本
echo - README.MD: 使用说明
echo - LICENSE: 许可证文件
echo.
echo 📦 可以将 releases\ 目录中的所有文件打包分发
echo.

pause 