@echo off
REM 这个脚本在 cargo build --release 后自动运行
REM 用于更新发布文件

echo 📦 自动更新发布文件...

REM 创建发布目录
if not exist releases mkdir releases

REM 复制文件
copy target\release\video-gif.exe releases\ >nul 2>&1
copy ffmpeg.exe releases\ >nul 2>&1
copy video-gif.bat releases\ >nul 2>&1
copy README.MD releases\ >nul 2>&1
copy LICENSE releases\ >nul 2>&1

echo ✅ 发布文件已自动更新到 releases\ 目录 