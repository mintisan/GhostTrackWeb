#!/bin/bash

# GhostTrack Web 多架构 Docker 镜像构建脚本
# 支持 ARM64 (M系列Mac) 和 x86_64 (Intel) 架构

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 配置变量
DOCKER_USERNAME="mintisan"
VERSION=${1:-"latest"}
PLATFORMS="linux/amd64,linux/arm64"

echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              GhostTrack Web 多架构构建工具                   ║"
echo "║          支持 ARM64 (M系列) 和 x86_64 (Intel)                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}🏗️ 构建配置:${NC}"
echo -e "   🏷️  版本: ${YELLOW}$VERSION${NC}"
echo -e "   🖥️  目标平台: ${YELLOW}$PLATFORMS${NC}"
echo -e "   👤 Docker用户: ${YELLOW}$DOCKER_USERNAME${NC}"
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装，请先安装 Docker${NC}"
    exit 1
fi

# 检查是否启用了buildx
echo -e "${BLUE}🔍 检查Docker Buildx...${NC}"
if ! docker buildx version >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker Buildx 未启用${NC}"
    echo "请启用 Docker Buildx 或升级到 Docker 19.03+"
    exit 1
fi

# 创建或使用multi-arch builder
BUILDER_NAME="ghosttrack-multiarch"
echo -e "${BLUE}🔨 设置多架构构建器...${NC}"

if ! docker buildx inspect $BUILDER_NAME >/dev/null 2>&1; then
    echo "创建新的构建器: $BUILDER_NAME"
    docker buildx create --name $BUILDER_NAME --platform $PLATFORMS
else
    echo "使用现有构建器: $BUILDER_NAME"
fi

docker buildx use $BUILDER_NAME
docker buildx inspect --bootstrap

echo ""
echo -e "${YELLOW}选择构建选项:${NC}"
echo "1) 仅构建到本地（不推送）"
echo "2) 构建并推送到 DockerHub"
echo "3) 构建、推送并创建离线包"
echo ""

read -p "请选择 (1-3): " build_choice

case $build_choice in
    1)
        BUILD_ACTION="--load"
        PUSH_FLAG=false
        echo -e "${BLUE}📦 模式: 本地构建${NC}"
        ;;
    2)
        BUILD_ACTION="--push"
        PUSH_FLAG=true
        echo -e "${BLUE}📦 模式: 构建并推送${NC}"
        ;;
    3)
        BUILD_ACTION="--push"
        PUSH_FLAG=true
        CREATE_OFFLINE=true
        echo -e "${BLUE}📦 模式: 构建、推送并创建离线包${NC}"
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

echo ""

# 构建后端镜像
echo -e "${BLUE}🏗️ 构建后端镜像...${NC}"
cd backend
docker buildx build \
    --platform $PLATFORMS \
    --tag ${DOCKER_USERNAME}/ghosttrack-backend:${VERSION} \
    --tag ${DOCKER_USERNAME}/ghosttrack-backend:latest \
    $BUILD_ACTION .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 后端镜像构建成功${NC}"
else
    echo -e "${RED}❌ 后端镜像构建失败${NC}"
    exit 1
fi

cd ..

# 构建前端镜像
echo -e "${BLUE}🏗️ 构建前端镜像...${NC}"
cd frontend
docker buildx build \
    --platform $PLATFORMS \
    --tag ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION} \
    --tag ${DOCKER_USERNAME}/ghosttrack-frontend:latest \
    $BUILD_ACTION .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 前端镜像构建成功${NC}"
else
    echo -e "${RED}❌ 前端镜像构建失败${NC}"
    exit 1
fi

# 构建独立前端镜像
echo -e "${BLUE}🏗️ 构建独立前端镜像...${NC}"
docker buildx build \
    --platform $PLATFORMS \
    --file Dockerfile.standalone \
    --tag ${DOCKER_USERNAME}/ghosttrack-frontend-standalone:${VERSION} \
    --tag ${DOCKER_USERNAME}/ghosttrack-frontend-standalone:latest \
    $BUILD_ACTION .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 独立前端镜像构建成功${NC}"
else
    echo -e "${RED}❌ 独立前端镜像构建失败${NC}"
    exit 1
fi

cd ..

echo ""
echo -e "${GREEN}🎉 多架构镜像构建完成！${NC}"

if [ "$PUSH_FLAG" = true ]; then
    echo ""
    echo -e "${BLUE}📊 已推送到 DockerHub 的镜像:${NC}"
    echo -e "   🖼️  ${YELLOW}${DOCKER_USERNAME}/ghosttrack-backend:${VERSION}${NC}"
    echo -e "   🖼️  ${YELLOW}${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}${NC}"
    echo -e "   🖼️  ${YELLOW}${DOCKER_USERNAME}/ghosttrack-frontend-standalone:${VERSION}${NC}"
    
    echo ""
    echo -e "${BLUE}🔍 验证多架构支持:${NC}"
    echo "docker buildx imagetools inspect ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}"
fi

# 创建离线包（如果选择了选项3）
if [ "$CREATE_OFFLINE" = true ]; then
    echo ""
    echo -e "${BLUE}📦 创建多架构离线包...${NC}"
    
    # 先拉取刚推送的镜像到本地
    echo "拉取多架构镜像到本地..."
    docker pull --platform linux/amd64 ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}
    docker pull --platform linux/amd64 ${DOCKER_USERNAME}/ghosttrack-backend:${VERSION}
    docker pull --platform linux/amd64 ${DOCKER_USERNAME}/ghosttrack-frontend-standalone:${VERSION}
    
    echo "拉取ARM64镜像到本地..."
    docker pull --platform linux/arm64 ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}
    docker pull --platform linux/arm64 ${DOCKER_USERNAME}/ghosttrack-backend:${VERSION}
    docker pull --platform linux/arm64 ${DOCKER_USERNAME}/ghosttrack-frontend-standalone:${VERSION}
    
    # 创建分架构的离线包
    echo -e "${BLUE}📦 创建 x86_64 离线包...${NC}"
    ./docker-export-arch.sh amd64 $VERSION
    
    echo -e "${BLUE}📦 创建 ARM64 离线包...${NC}"
    ./docker-export-arch.sh arm64 $VERSION
fi

echo ""
echo -e "${YELLOW}🎯 使用建议:${NC}"
echo ""
echo -e "${BLUE}💡 在 x86_64 服务器上:${NC}"
echo "docker pull --platform linux/amd64 ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}"
echo ""
echo -e "${BLUE}💡 在 ARM64 服务器上:${NC}"
echo "docker pull --platform linux/arm64 ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}"
echo ""
echo -e "${BLUE}💡 自动选择架构（推荐）:${NC}"
echo "docker pull ${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}"
echo ""
echo -e "${GREEN}✨ 多架构 Docker 镜像已准备就绪！${NC}"