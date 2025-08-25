#!/bin/bash

# GhostTrack Web Docker 完整发布脚本
# 包含构建、推送和版本管理

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}GhostTrack Web Docker 发布脚本${NC}"
    echo ""
    echo -e "${YELLOW}用法:${NC}"
    echo "  $0 [选项] [版本号]"
    echo ""
    echo -e "${YELLOW}选项:${NC}"
    echo "  -h, --help          显示帮助信息"
    echo "  -b, --build-only    仅构建镜像，不推送"
    echo "  -p, --push-only     仅推送镜像，不构建"
    echo "  -v, --version       指定版本号（覆盖 package.json）"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0                  # 使用 package.json 版本，构建并推送"
    echo "  $0 --build-only     # 仅构建镜像"
    echo "  $0 -v 1.2.0         # 使用指定版本号"
    echo ""
}

# 解析命令行参数
BUILD_ONLY=false
PUSH_ONLY=false
CUSTOM_VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--build-only)
            BUILD_ONLY=true
            shift
            ;;
        -p|--push-only)
            PUSH_ONLY=true
            shift
            ;;
        -v|--version)
            CUSTOM_VERSION="$2"
            shift 2
            ;;
        *)
            if [[ -z "$CUSTOM_VERSION" ]]; then
                CUSTOM_VERSION="$1"
            fi
            shift
            ;;
    esac
done

# 读取版本号
if [[ -n "$CUSTOM_VERSION" ]]; then
    VERSION="$CUSTOM_VERSION"
else
    VERSION=$(cat package.json | grep '"version"' | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d ' ')
fi

if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ 无法读取版本号${NC}"
    exit 1
fi

# DockerHub 用户名（需要修改为实际的DockerHub用户名）
DOCKER_USERNAME="${DOCKER_USERNAME:-mintisan}"

# 镜像名称
FRONTEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-frontend"
BACKEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-backend"

echo -e "${PURPLE}🚀 GhostTrack Web Docker 发布流程${NC}"
echo -e "${YELLOW}📦 版本: ${VERSION}${NC}"
echo -e "${YELLOW}👤 DockerHub 用户: ${DOCKER_USERNAME}${NC}"
echo ""

# 如果只推送，跳过构建
if [[ "$PUSH_ONLY" == "true" ]]; then
    echo -e "${BLUE}📤 仅推送模式，跳过构建...${NC}"
else
    echo -e "${BLUE}🏗️  开始构建 Docker 镜像...${NC}"
    
    # 检查Docker是否运行
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker 未运行，请启动 Docker${NC}"
        exit 1
    fi
    
    # 构建前端镜像
    echo -e "${BLUE}🏗️  构建前端镜像...${NC}"
    docker build -t ${FRONTEND_IMAGE}:${VERSION} -t ${FRONTEND_IMAGE}:latest ./frontend
    
    # 构建后端镜像
    echo -e "${BLUE}🏗️  构建后端镜像...${NC}"
    docker build -t ${BACKEND_IMAGE}:${VERSION} -t ${BACKEND_IMAGE}:latest ./backend
    
    echo -e "${GREEN}✅ 构建完成！${NC}"
fi

# 如果只构建，跳过推送
if [[ "$BUILD_ONLY" == "true" ]]; then
    echo -e "${BLUE}🏗️  仅构建模式，跳过推送...${NC}"
    echo -e "${GREEN}🎉 构建完成！${NC}"
    exit 0
fi

echo -e "${BLUE}📤 开始推送到 DockerHub...${NC}"

# 检查是否已登录 DockerHub
if ! docker info | grep -q "Username" 2>/dev/null; then
    echo -e "${YELLOW}🔐 请先登录 DockerHub:${NC}"
    docker login
fi

# 检查镜像是否存在
if ! docker images | grep -q "${FRONTEND_IMAGE}"; then
    echo -e "${RED}❌ 前端镜像不存在，请先运行构建${NC}"
    exit 1
fi

if ! docker images | grep -q "${BACKEND_IMAGE}"; then
    echo -e "${RED}❌ 后端镜像不存在，请先运行构建${NC}"
    exit 1
fi

# 推送前端镜像
echo -e "${BLUE}📤 推送前端镜像...${NC}"
docker push ${FRONTEND_IMAGE}:${VERSION}
docker push ${FRONTEND_IMAGE}:latest

# 推送后端镜像
echo -e "${BLUE}📤 推送后端镜像...${NC}"
docker push ${BACKEND_IMAGE}:${VERSION}
docker push ${BACKEND_IMAGE}:latest

echo ""
echo -e "${GREEN}🎉 GhostTrack Web v${VERSION} 发布成功！${NC}"
echo ""
echo -e "${YELLOW}🌐 DockerHub 链接:${NC}"
echo -e "   📦 前端镜像: ${BLUE}https://hub.docker.com/r/${DOCKER_USERNAME}/ghosttrack-frontend${NC}"
echo -e "   📦 后端镜像: ${BLUE}https://hub.docker.com/r/${DOCKER_USERNAME}/ghosttrack-backend${NC}"
echo ""
echo -e "${YELLOW}💡 用户部署命令:${NC}"
echo -e "   ${BLUE}docker pull ${FRONTEND_IMAGE}:${VERSION}${NC}"
echo -e "   ${BLUE}docker pull ${BACKEND_IMAGE}:${VERSION}${NC}"
echo ""
echo -e "${YELLOW}📋 或者使用提供的 docker-compose 文件进行一键部署${NC}"