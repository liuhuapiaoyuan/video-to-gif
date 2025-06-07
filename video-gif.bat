@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo =================================
echo     Video to GIF 转换工具
echo =================================
echo.

REM 检查是否提供了参数（拖拽的文件夹或文件）
if "%~1"=="" (
    echo 使用方法：
    echo 1. 将包含MP4文件的文件夹拖拽到此批处理文件上
    echo 2. 将单个MP4文件拖拽到此批处理文件上
    echo 3. 或者在命令行中使用: video-gif.bat "路径"
    echo.
    echo 示例：
    echo   video-gif.bat "C:\My Videos"
    echo   video-gif.bat "C:\My Videos\video.mp4"
    echo.
    pause
    exit /b 1
)

REM 获取拖拽的路径（文件夹或文件）
set "input_path=%~1"

REM 检查路径是否存在
if not exist "%input_path%" (
    echo ❌ 错误：路径不存在 "%input_path%"
    echo.
    pause
    exit /b 1
)

REM 检查是文件夹还是文件
if exist "%input_path%\*" (
    echo 📁 输入文件夹: %input_path%
    set "input_type=folder"
) else (
    echo 📄 输入文件: %input_path%
    set "input_type=file"
)
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
"%exe_path%" "%input_path%"

REM 检查转换结果
if %errorlevel% == 0 (
    echo.
    echo ✅ 转换完成！
    if "%input_type%"=="folder" (
        echo 📂 GIF文件已保存到: %input_path%
    ) else (
        for %%F in ("%input_path%") do set "output_dir=%%~dpF"
        echo 📂 GIF文件已保存到: !output_dir!
    )
) else (
    echo.
    echo ❌ 转换过程中发生错误
)

echo.
echo 按任意键退出...
pause >nul 