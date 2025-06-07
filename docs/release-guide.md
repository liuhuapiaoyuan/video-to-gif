# 发布指南

本文档说明如何使用自动化工作流发布新版本的Video-GIF工具。

## 前置条件

1. 确保你有GitHub仓库的写权限
2. 所有代码更改已提交并推送到main分支
3. 工作目录干净（没有未提交的更改）

## 发布步骤

### 1. 更新版本信息

在发布前，需要更新以下文件中的版本号：

**Cargo.toml**
```toml
version = "1.2.3"  # 更新为新版本号
```

**src/main.rs**
```rust
#[command(version = "1.2.3")]  # 更新为新版本号
```

**README.MD**
在更新日志部分添加新版本的更改内容：
```markdown
### v1.2.3
- 🎉 新功能描述
- 🐛 修复的问题
- ✅ 改进的功能
```

### 2. 运行发布脚本

根据你的操作系统选择对应的脚本：

**Linux/macOS:**
```bash
./scripts/release.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\release.ps1
```

**强制发布 (跳过确认):**
```powershell
.\scripts\release.ps1 -Force
```

### 3. 监控自动构建

脚本执行后会显示GitHub Actions的链接，你可以：

1. 点击链接查看构建进度
2. 等待所有平台构建完成（通常需要10-15分钟）
3. 检查是否有构建错误

### 4. 验证发布

构建成功后：

1. 访问GitHub Release页面
2. 确认新Release已创建
3. 检查所有平台的文件都已上传：
   - `video-gif-x86_64-pc-windows-msvc.zip` (Windows)
   - `video-gif-x86_64-apple-darwin.tar.gz` (macOS)  
   - `video-gif-x86_64-unknown-linux-gnu.tar.gz` (Linux)
4. 验证Release Notes正确生成

## 自动化工作流说明

### GitHub Actions工作流

1. **CI工作流** (`.github/workflows/ci.yml`)
   - 在每次push和PR时运行
   - 执行测试、格式检查、clippy检查
   - 跨平台构建验证

2. **Release工作流** (`.github/workflows/release.yml`)
   - 在创建版本标签时触发
   - 构建Windows/macOS/Linux版本
   - 自动创建GitHub Release
   - 生成Release Notes
   - 上传构建文件

### 构建产物

- **Windows版本**: 包含`video-gif.exe`、`ffmpeg.exe`、`video-gif.bat`
- **macOS/Linux版本**: 包含`video-gif`可执行文件和安装脚本

## 故障排除

### 常见问题

1. **版本标签已存在**
   - 检查是否忘记更新版本号
   - 删除错误的标签: `git tag -d v1.2.3 && git push origin :refs/tags/v1.2.3`

2. **构建失败**
   - 检查GitHub Actions日志
   - 确认代码能在本地正常构建
   - 检查依赖是否正确

3. **FFmpeg下载失败**
   - 工作流会自动下载FFmpeg
   - 如果失败，可能是网络问题，重新运行即可

### 手动发布

如果自动化脚本失败，可以手动发布：

```bash
# 创建标签
git tag -a "v1.2.3" -m "Release v1.2.3"

# 推送标签
git push origin "v1.2.3"
```

## 最佳实践

1. **版本号规范**: 使用语义化版本号 (semantic versioning)
2. **更新日志**: 每个版本都应该有清晰的更新说明
3. **测试验证**: 发布前确保本地测试通过
4. **分支保护**: 重要更改应通过PR审核
5. **备份标签**: 重要版本可以创建backup分支

## 发布检查清单

- [ ] 更新Cargo.toml版本号
- [ ] 更新src/main.rs版本号  
- [ ] 在README.MD中添加更新日志
- [ ] 提交所有更改
- [ ] 工作目录干净
- [ ] 运行发布脚本
- [ ] 监控构建过程
- [ ] 验证Release创建成功
- [ ] 测试下载的文件
- [ ] 通知用户新版本发布 