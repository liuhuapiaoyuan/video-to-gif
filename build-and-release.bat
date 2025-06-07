@echo off
chcp 65001 >nul

echo.
echo =================================
echo     Video-GIF 构建和发布脚本
echo =================================
echo.

echo 🔧 开始构建 video-gif...
echo.

REM 清理根目录下的可执行文件（如果存在）
if exist video-gif.exe (
    echo 🧹 清理根目录下的旧文件...
    del video-gif.exe
)

REM 构建项目
echo 🚀 编译项目 (Release模式)...
cargo build --release

if %ERRORLEVEL% neq 0 (
    echo ❌ 构建失败！
    pause
    exit /b 1
)

echo ✅ 构建成功！

REM 自动更新发布文件
echo 📦 自动更新发布文件...
call post-build.bat

echo.
echo 📋 发布文件列表：
if exist releases (
    dir releases
) else (
    echo ❌ 发布目录创建失败
)

echo.
echo 🎉 构建和发布完成！
echo 📁 发布文件位于: releases\ 目录
echo.
echo 💡 使用提示：
echo - 开发时：使用 "cargo build --release" 然后运行 "post-build.bat"
echo - 完整发布：使用此脚本 "build-and-release.bat"
echo - 拖拽使用：将文件或文件夹拖拽到 releases\video-gif.bat
echo.

pause 