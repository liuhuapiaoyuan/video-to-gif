# Video-GIF Release Script (PowerShell)
# 用于创建版本标签并触发GitHub Actions自动发布

param(
    [switch]$Force
)

# 设置错误处理
$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Blue
Write-Host "    Video-GIF Release Script" -ForegroundColor Blue  
Write-Host "==================================" -ForegroundColor Blue
Write-Host

# 检查git状态
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "❌ 错误：工作目录不干净，请先提交所有更改" -ForegroundColor Red
    git status --short
    exit 1
}

# 从Cargo.toml获取当前版本
$cargoContent = Get-Content "Cargo.toml"
$versionLine = $cargoContent | Where-Object { $_ -match '^version = "(.+)"' }
if ($versionLine -match '^version = "(.+)"') {
    $currentVersion = $matches[1]
} else {
    Write-Host "❌ 错误：无法从 Cargo.toml 读取版本号" -ForegroundColor Red
    exit 1
}

Write-Host "📦 当前版本: " -NoNewline -ForegroundColor Blue
Write-Host "v$currentVersion" -ForegroundColor Yellow

# 检查版本是否已存在标签
$existingTags = git tag
if ($existingTags -contains "v$currentVersion") {
    Write-Host "❌ 错误：版本 v$currentVersion 的标签已存在" -ForegroundColor Red
    Write-Host "💡 提示：请更新 Cargo.toml 和 src/main.rs 中的版本号" -ForegroundColor Yellow
    exit 1
}

# 检查README中是否有对应版本的更新日志
$readmeContent = Get-Content "README.MD" -Raw
if (-not ($readmeContent -match "### v$currentVersion")) {
    Write-Host "⚠️  警告：README.MD中未找到 v$currentVersion 的更新日志" -ForegroundColor Yellow
    Write-Host "   建议在 README.MD 中添加本版本的更新说明" -ForegroundColor Yellow
    Write-Host
    
    if (-not $Force) {
        $continue = Read-Host "是否继续发布？(y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Host "📝 发布已取消，请添加更新日志后重试" -ForegroundColor Yellow
            exit 1
        }
    }
}

Write-Host
Write-Host "🚀 准备发布版本: " -NoNewline -ForegroundColor Blue
Write-Host "v$currentVersion" -ForegroundColor Green
Write-Host
Write-Host "将执行以下操作：" -ForegroundColor Yellow
Write-Host "  1. 创建标签: " -NoNewline
Write-Host "v$currentVersion" -ForegroundColor Green
Write-Host "  2. 推送标签到远程仓库"
Write-Host "  3. 触发GitHub Actions自动构建和发布"
Write-Host

if (-not $Force) {
    $confirm = Read-Host "确认发布？(y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "📝 发布已取消" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host
Write-Host "📋 开始发布流程..." -ForegroundColor Blue

try {
    # 创建标签
    Write-Host "🏷️  创建标签 v$currentVersion..." -ForegroundColor Blue
    git tag -a "v$currentVersion" -m "Release v$currentVersion"
    
    # 推送标签
    Write-Host "📤 推送标签到远程仓库..." -ForegroundColor Blue
    git push origin "v$currentVersion"
    
    Write-Host
    Write-Host "✅ 发布流程已启动！" -ForegroundColor Green
    Write-Host
    Write-Host "📋 接下来会发生什么：" -ForegroundColor Yellow
    Write-Host "  1. GitHub Actions 将自动构建 Windows/macOS/Linux 版本"
    Write-Host "  2. 自动创建 GitHub Release"
    Write-Host "  3. 上传构建好的文件到 Release"
    Write-Host "  4. 自动生成 Release Notes"
    Write-Host
    
    # 获取远程仓库URL
    $remoteUrl = git config --get remote.origin.url
    $repoPath = $remoteUrl -replace '.*github\.com[:/]([^/]+/[^/]+).*', '$1' -replace '\.git$', ''
    
    Write-Host "🔗 查看构建进度：" -ForegroundColor Blue
    Write-Host "   https://github.com/$repoPath/actions"
    Write-Host
    Write-Host "📦 发布完成后可在这里下载：" -ForegroundColor Blue
    Write-Host "   https://github.com/$repoPath/releases/latest"
    
} catch {
    Write-Host "❌ 发布过程中出现错误：$($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 