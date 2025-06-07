#!/bin/bash

# Video-GIF Release Script
# 用于创建版本标签并触发GitHub Actions自动发布

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}    Video-GIF Release Script${NC}"
echo -e "${BLUE}==================================${NC}"
echo

# 检查git状态
if [[ -n $(git status --porcelain) ]]; then
    echo -e "${RED}❌ 错误：工作目录不干净，请先提交所有更改${NC}"
    git status --short
    exit 1
fi

# 从Cargo.toml获取当前版本
CURRENT_VERSION=$(grep '^version = ' Cargo.toml | sed 's/version = "\(.*\)"/\1/')
echo -e "${BLUE}📦 当前版本: ${YELLOW}v$CURRENT_VERSION${NC}"

# 检查版本是否已存在标签
if git tag | grep -q "^v$CURRENT_VERSION$"; then
    echo -e "${RED}❌ 错误：版本 v$CURRENT_VERSION 的标签已存在${NC}"
    echo -e "${YELLOW}💡 提示：请更新 Cargo.toml 和 src/main.rs 中的版本号${NC}"
    exit 1
fi

# 检查README中是否有对应版本的更新日志
if ! grep -q "### v$CURRENT_VERSION" README.MD; then
    echo -e "${YELLOW}⚠️  警告：README.MD中未找到 v$CURRENT_VERSION 的更新日志${NC}"
    echo -e "${YELLOW}   建议在 README.MD 中添加本版本的更新说明${NC}"
    echo
    read -p "是否继续发布？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}📝 发布已取消，请添加更新日志后重试${NC}"
        exit 1
    fi
fi

echo
echo -e "${BLUE}🚀 准备发布版本: ${GREEN}v$CURRENT_VERSION${NC}"
echo
echo -e "${YELLOW}将执行以下操作：${NC}"
echo -e "  1. 创建标签: ${GREEN}v$CURRENT_VERSION${NC}"
echo -e "  2. 推送标签到远程仓库"
echo -e "  3. 触发GitHub Actions自动构建和发布"
echo

read -p "确认发布？(y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
    echo -e "${BLUE}📋 开始发布流程...${NC}"
    
    # 创建标签
    echo -e "${BLUE}🏷️  创建标签 v$CURRENT_VERSION...${NC}"
    git tag -a "v$CURRENT_VERSION" -m "Release v$CURRENT_VERSION"
    
    # 推送标签
    echo -e "${BLUE}📤 推送标签到远程仓库...${NC}"
    git push origin "v$CURRENT_VERSION"
    
    echo
    echo -e "${GREEN}✅ 发布流程已启动！${NC}"
    echo
    echo -e "${YELLOW}📋 接下来会发生什么：${NC}"
    echo -e "  1. GitHub Actions 将自动构建 Windows/macOS/Linux 版本"
    echo -e "  2. 自动创建 GitHub Release"
    echo -e "  3. 上传构建好的文件到 Release"
    echo -e "  4. 自动生成 Release Notes"
    echo
    echo -e "${BLUE}🔗 查看构建进度：${NC}"
    echo -e "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/' | sed 's/\.git$//')/actions"
    echo
    echo -e "${BLUE}📦 发布完成后可在这里下载：${NC}"
    echo -e "   https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/' | sed 's/\.git$//')/releases/latest"
    
else
    echo -e "${YELLOW}📝 发布已取消${NC}"
    exit 1
fi 