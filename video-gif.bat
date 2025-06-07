@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo =================================
echo     Video to GIF 转换工具
echo =================================
echo.

REM 检查是否提供了参数（拖拽的文件夹）
if "%~1"=="" (
    echo 使用方法：
    echo 1. 将包含MP4文件的文件夹拖拽到此批处理文件上
    echo 2. 或者在命令行中使用: video-gif.bat "文件夹路径"
    echo.
    echo 示例：video-gif.bat "C:\My Videos"
    echo.
    pause
    exit /b 1
)

REM 获取拖拽的文件夹路径
set "input_folder=%~1"

REM 检查文件夹是否存在
if not exist "%input_folder%" (
    echo ❌ 错误：文件夹不存在 "%input_folder%"
    echo.
    pause
    exit /b 1
)

REM 检查是否为文件夹
if not exist "%input_folder%\*" (
    echo ❌ 错误：指定的路径不是文件夹 "%input_folder%"
    echo.
    pause
    exit /b 1
)

echo 📁 输入文件夹: %input_folder%
echo.

REM 获取批处理文件所在目录
set "script_dir=%~dp0"

REM 检查video-gif.exe是否存在
set "exe_path=%script_dir%target\release\video-gif.exe"
if not exist "%exe_path%" (
    set "exe_path=%script_dir%video-gif.exe"
    if not exist "!exe_path!" (
        echo ❌ 错误：找不到video-gif.exe文件
        echo 请确保video-gif.exe文件与此批处理文件在同一目录下
        echo 或者先运行 "cargo build --release" 命令编译项目
        echo.
        pause
        exit /b 1
    )
)

echo 🚀 开始转换...
echo.

REM 运行转换程序
"%exe_path%" "%input_folder%"

REM 检查转换结果
if %errorlevel% == 0 (
    echo.
    echo ✅ 转换完成！
    echo 📂 GIF文件已保存到: %input_folder%
) else (
    echo.
    echo ❌ 转换过程中发生错误
)

echo.
echo 按任意键退出...
pause >nul 