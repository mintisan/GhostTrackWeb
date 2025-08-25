#!/bin/bash

# GhostTrack Web Docker 构建脚本
# 支持版本标签和多架构构建

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 读取版本号
VERSION=$(cat package.json | grep '"version"' | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d ' ')
if [ -z "$VERSION" ]; then
    echo -e "${RED}❌ 无法读取版本号${NC}"
    exit 1
fi

# DockerHub 用户名（需要修改为实际的DockerHub用户名）
DOCKER_USERNAME="${DOCKER_USERNAME:-mintisan}"

# 镜像名称
FRONTEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-frontend"
BACKEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-backend"

echo -e "${BLUE}🚀 开始构建 GhostTrack Web Docker 镜像${NC}"
echo -e "${YELLOW}📦 版本: ${VERSION}${NC}"
echo -e "${YELLOW}🏷️  前端镜像: ${FRONTEND_IMAGE}:${VERSION}${NC}"
echo -e "${YELLOW}🏷️  后端镜像: ${BACKEND_IMAGE}:${VERSION}${NC}"

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

# 显示构建的镜像
echo -e "${GREEN}✅ 构建完成！${NC}"
echo -e "${YELLOW}📋 构建的镜像:${NC}"
docker images | grep "${DOCKER_USERNAME}/ghosttrack"

echo ""
echo -e "${GREEN}🎉 Docker 镜像构建成功！${NC}"
echo -e "${YELLOW}💡 接下来可以执行以下命令:${NC}"
echo -e "   📤 推送到 DockerHub: ${BLUE}./docker-push.sh${NC}"
echo -e "   🧪 本地测试: ${BLUE}docker-compose up -d${NC}"