#!/bin/bash

# GhostTrack Web Docker 推送脚本
# 将镜像推送到 DockerHub

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

echo -e "${BLUE}📤 开始推送 GhostTrack Web Docker 镜像到 DockerHub${NC}"
echo -e "${YELLOW}📦 版本: ${VERSION}${NC}"

# 检查是否已登录 DockerHub
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}🔐 请先登录 DockerHub:${NC}"
    docker login
fi

# 检查镜像是否存在
if ! docker images | grep -q "${FRONTEND_IMAGE}"; then
    echo -e "${RED}❌ 前端镜像不存在，请先运行构建脚本${NC}"
    exit 1
fi

if ! docker images | grep -q "${BACKEND_IMAGE}"; then
    echo -e "${RED}❌ 后端镜像不存在，请先运行构建脚本${NC}"
    exit 1
fi

# 推送前端镜像
echo -e "${BLUE}📤 推送前端镜像 ${FRONTEND_IMAGE}:${VERSION}...${NC}"
docker push ${FRONTEND_IMAGE}:${VERSION}
docker push ${FRONTEND_IMAGE}:latest

# 推送后端镜像
echo -e "${BLUE}📤 推送后端镜像 ${BACKEND_IMAGE}:${VERSION}...${NC}"
docker push ${BACKEND_IMAGE}:${VERSION}
docker push ${BACKEND_IMAGE}:latest

echo ""
echo -e "${GREEN}🎉 Docker 镜像推送成功！${NC}"
echo -e "${YELLOW}🌐 DockerHub 链接:${NC}"
echo -e "   📦 前端镜像: ${BLUE}https://hub.docker.com/r/${DOCKER_USERNAME}/ghosttrack-frontend${NC}"
echo -e "   📦 后端镜像: ${BLUE}https://hub.docker.com/r/${DOCKER_USERNAME}/ghosttrack-backend${NC}"
echo ""
echo -e "${YELLOW}💡 其他用户现在可以通过以下命令拉取镜像:${NC}"
echo -e "   ${BLUE}docker pull ${FRONTEND_IMAGE}:${VERSION}${NC}"
echo -e "   ${BLUE}docker pull ${BACKEND_IMAGE}:${VERSION}${NC}"
echo -e "   ${BLUE}docker pull ${FRONTEND_IMAGE}:latest${NC}"
echo -e "   ${BLUE}docker pull ${BACKEND_IMAGE}:latest${NC}"