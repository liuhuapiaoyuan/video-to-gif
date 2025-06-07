@echo off
chcp 65001 >nul

echo.
echo =================================
echo     Video-GIF 工具演示
echo =================================
echo.

echo 这是一个演示脚本，展示如何使用 video-gif 工具
echo 📦 本工具已内置 FFmpeg，无需单独安装！
echo.

echo 📋 可用的命令选项：
echo.
echo 1. 查看帮助信息：
echo    video-gif.exe --help
echo.
echo 2. 查看版本信息：
echo    video-gif.exe --version
echo.
echo 3. 转换文件夹中的MP4文件（默认设置）：
echo    video-gif.exe "C:\path\to\video\folder"
echo.
echo 4. 自定义帧率和宽度：
echo    video-gif.exe --fps 15 --width 640 "C:\path\to\video\folder"
echo.
echo 5. 静默模式（不显示进度条）：
echo    video-gif.exe --quiet "C:\path\to\video\folder"
echo.
echo 6. 拖拽使用（推荐）：
echo    将包含MP4文件的文件夹直接拖拽到 video-gif.bat 文件上
echo.

echo 💡 使用提示：
echo - ✅ 已内置 FFmpeg 7.1.1，开箱即用
echo - 支持的输入格式：MP4
echo - 输出格式：GIF
echo - 默认设置：10fps, 480px宽度
echo - GIF文件将保存在与MP4文件相同的目录中
echo.

echo 🎯 特性：
echo - 无需安装 FFmpeg，内置最新版本
echo - 自动批量转换文件夹中的所有MP4文件
echo - 智能缩放，保持视频比例
echo - 进度条显示转换状态
echo - 支持静默模式
echo.

echo 按任意键退出演示...
pause >nul 