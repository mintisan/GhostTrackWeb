#!/bin/bash

# GhostTrack Web 分架构镜像导出脚本
# 为特定架构创建离线部署包

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 参数检查
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ 用法: $0 <架构> [版本]${NC}"
    echo "支持的架构: amd64, arm64"
    echo "示例: $0 amd64 latest"
    exit 1
fi

ARCH=$1
VERSION=${2:-"latest"}
DOCKER_USERNAME="mintisan"

# 架构映射
case $ARCH in
    "amd64"|"x86_64"|"intel")
        PLATFORM="linux/amd64"
        ARCH_NAME="x86_64"
        ;;
    "arm64"|"aarch64"|"m1"|"m2")
        PLATFORM="linux/arm64"
        ARCH_NAME="arm64"
        ;;
    *)
        echo -e "${RED}❌ 不支持的架构: $ARCH${NC}"
        echo "支持的架构: amd64, arm64"
        exit 1
        ;;
esac

EXPORT_DIR="ghosttrack-offline-${ARCH_NAME}-$(date +%Y%m%d-%H%M%S)"

echo -e "${BLUE}📦 分架构离线包导出工具${NC}"
echo "=============================================="
echo -e "${BLUE}🏗️ 导出配置:${NC}"
echo -e "   🖥️  目标架构: ${YELLOW}$ARCH_NAME${NC}"
echo -e "   🐳 Docker平台: ${YELLOW}$PLATFORM${NC}"
echo -e "   🏷️  版本: ${YELLOW}$VERSION${NC}"
echo -e "   📁 输出目录: ${YELLOW}$EXPORT_DIR${NC}"
echo ""

# 创建导出目录
mkdir -p "$EXPORT_DIR"
cd "$EXPORT_DIR"

# 拉取指定架构的镜像
echo -e "${BLUE}📥 拉取 $ARCH_NAME 架构镜像...${NC}"

FRONTEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-frontend:${VERSION}"
BACKEND_IMAGE="${DOCKER_USERNAME}/ghosttrack-backend:${VERSION}"
STANDALONE_IMAGE="${DOCKER_USERNAME}/ghosttrack-frontend-standalone:${VERSION}"

echo "拉取前端镜像..."
docker pull --platform $PLATFORM $FRONTEND_IMAGE

echo "拉取后端镜像..."
docker pull --platform $PLATFORM $BACKEND_IMAGE

echo "拉取独立前端镜像..."
docker pull --platform $PLATFORM $STANDALONE_IMAGE

# 导出镜像
echo -e "${BLUE}📤 导出镜像文件...${NC}"

echo "导出前端镜像..."
docker save $FRONTEND_IMAGE -o ghosttrack-frontend-${VERSION}-${ARCH_NAME}.tar

echo "导出后端镜像..."
docker save $BACKEND_IMAGE -o ghosttrack-backend-${VERSION}-${ARCH_NAME}.tar

echo "导出独立前端镜像..."
docker save $STANDALONE_IMAGE -o ghosttrack-frontend-standalone-${VERSION}-${ARCH_NAME}.tar

# 创建架构特定的docker-compose文件
cat > docker-compose.yml << EOF
# GhostTrack Web 离线部署配置 - $ARCH_NAME 架构
# 适用于 $ARCH_NAME 架构的服务器

services:
  # 后端API服务
  backend:
    image: mintisan/ghosttrack-backend:${VERSION}
    container_name: ghosttrack-backend
    restart: unless-stopped
    ports:
      - "8088:8000"
    environment:
      - PYTHONPATH=/app
    networks:
      - ghosttrack-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  # 前端Web服务
  frontend:
    image: mintisan/ghosttrack-frontend:${VERSION}
    container_name: ghosttrack-frontend
    restart: unless-stopped
    ports:
      - "8192:80"
    depends_on:
      - backend
    networks:
      - ghosttrack-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  ghosttrack-network:
    driver: bridge

volumes:
  app-data:
    driver: local
EOF

# 创建独立前端配置
cat > docker-compose-standalone.yml << EOF
# GhostTrack Web 独立前端配置 - $ARCH_NAME 架构
# 仅部署前端，无需后端服务

services:
  # 独立前端Web服务
  frontend:
    image: mintisan/ghosttrack-frontend-standalone:${VERSION}
    container_name: ghosttrack-frontend-standalone
    restart: unless-stopped
    ports:
      - "8080:80"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  default:
    driver: bridge
EOF

# 创建架构特定的部署脚本
cat > deploy-offline.sh << 'EOF'
#!/bin/bash

# GhostTrack Web 离线部署脚本
# 架构特定版本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 GhostTrack Web 离线部署${NC}"
echo "=========================================="

# 检测当前系统架构
SYSTEM_ARCH=$(uname -m)
case $SYSTEM_ARCH in
    "x86_64")
        EXPECTED_ARCH="x86_64"
        ;;
    "aarch64"|"arm64")
        EXPECTED_ARCH="arm64"
        ;;
    *)
        echo -e "${YELLOW}⚠️  无法确定系统架构: $SYSTEM_ARCH${NC}"
        ;;
esac

# 检查架构匹配
PACKAGE_ARCH=$(basename $(pwd) | grep -o 'x86_64\|arm64' || echo "unknown")
if [ "$PACKAGE_ARCH" != "unknown" ] && [ "$EXPECTED_ARCH" != "$PACKAGE_ARCH" ]; then
    echo -e "${YELLOW}⚠️  架构警告:${NC}"
    echo -e "   系统架构: ${YELLOW}$EXPECTED_ARCH${NC}"
    echo -e "   包架构:   ${YELLOW}$PACKAGE_ARCH${NC}"
    echo ""
    read -p "是否继续部署? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}❌ 部署已取消${NC}"
        exit 0
    fi
fi

# 检查Docker环境
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker 未安装，请先安装 Docker${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
    echo -e "${RED}❌ Docker Compose 未安装，请先安装 Docker Compose${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker 环境检查通过${NC}"

# 选择部署模式
echo ""
echo -e "${YELLOW}选择部署模式:${NC}"
echo "1) 完整应用 (前端 + 后端)"
echo "2) 仅前端展示"
echo ""

read -p "请选择 (1-2): " choice

case $choice in
    1)
        DEPLOY_MODE="full"
        COMPOSE_FILE="docker-compose.yml"
        echo -e "${BLUE}📦 选择: 完整应用部署${NC}"
        ;;
    2)
        DEPLOY_MODE="frontend"
        COMPOSE_FILE="docker-compose-standalone.yml"
        echo -e "${BLUE}📦 选择: 仅前端部署${NC}"
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

# 导入镜像
echo -e "${BLUE}📥 导入Docker镜像...${NC}"

if [ "$DEPLOY_MODE" = "full" ]; then
    echo "导入后端镜像..."
    docker load -i ghosttrack-backend-*-${PACKAGE_ARCH}.tar
    echo "导入前端镜像..."
    docker load -i ghosttrack-frontend-*-${PACKAGE_ARCH}.tar
else
    echo "导入独立前端镜像..."
    docker load -i ghosttrack-frontend-standalone-*-${PACKAGE_ARCH}.tar
fi

echo -e "${GREEN}✅ 镜像导入完成${NC}"

# 停止旧服务
echo -e "${BLUE}🛑 停止旧服务...${NC}"
docker-compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true

# 启动服务
echo -e "${BLUE}🚀 启动服务...${NC}"
docker-compose -f "$COMPOSE_FILE" up -d

echo -e "${YELLOW}⏳ 等待服务启动...${NC}"
sleep 15

# 检查服务状态
echo -e "${BLUE}🔍 检查服务状态...${NC}"
docker-compose -f "$COMPOSE_FILE" ps

# 健康检查和显示结果
if [ "$DEPLOY_MODE" = "full" ]; then
    if curl -f http://localhost:8088/ >/dev/null 2>&1 && curl -f http://localhost:8192/ >/dev/null 2>&1; then
        echo -e "${GREEN}🎉 部署成功！${NC}"
        echo -e "${BLUE}📍 访问地址:${NC}"
        echo "  前端: http://localhost:8192"
        echo "  后端: http://localhost:8088"
    else
        echo -e "${RED}❌ 服务启动异常，请检查日志${NC}"
    fi
else
    if curl -f http://localhost:8080/ >/dev/null 2>&1; then
        echo -e "${GREEN}🎉 部署成功！${NC}"
        echo -e "${BLUE}📍 访问地址:${NC}"
        echo "  前端: http://localhost:8080"
        echo -e "${YELLOW}⚠️  注意: API功能不可用${NC}"
    else
        echo -e "${RED}❌ 服务启动异常，请检查日志${NC}"
    fi
fi

echo ""
echo -e "${BLUE}🛠️  管理命令:${NC}"
echo "  查看状态: docker-compose -f $COMPOSE_FILE ps"
echo "  查看日志: docker-compose -f $COMPOSE_FILE logs -f"
echo "  停止服务: docker-compose -f $COMPOSE_FILE down"
EOF

chmod +x deploy-offline.sh

# 创建README
cat > README.md << EOF
# GhostTrack Web 离线部署包 - $ARCH_NAME 架构

## 📋 包信息

- **目标架构**: $ARCH_NAME ($PLATFORM)
- **版本**: $VERSION
- **创建时间**: $(date)

## 📦 包含文件

- \`ghosttrack-frontend-${VERSION}-${ARCH_NAME}.tar\` - 前端镜像
- \`ghosttrack-backend-${VERSION}-${ARCH_NAME}.tar\` - 后端镜像
- \`ghosttrack-frontend-standalone-${VERSION}-${ARCH_NAME}.tar\` - 独立前端镜像
- \`docker-compose.yml\` - 完整应用配置
- \`docker-compose-standalone.yml\` - 前端专用配置
- \`deploy-offline.sh\` - 自动部署脚本

## 🚀 部署方法

### 自动部署（推荐）
\`\`\`bash
./deploy-offline.sh
\`\`\`

### 手动部署
\`\`\`bash
# 导入镜像
docker load -i ghosttrack-backend-${VERSION}-${ARCH_NAME}.tar
docker load -i ghosttrack-frontend-${VERSION}-${ARCH_NAME}.tar

# 启动服务
docker-compose up -d
\`\`\`

## 💻 系统要求

- **架构**: $ARCH_NAME
- **操作系统**: Linux
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## ⚠️ 重要提示

此离线包专为 **$ARCH_NAME 架构** 设计，不能在其他架构上运行。

如需其他架构的离线包，请使用：
\`\`\`bash
# x86_64 架构
./docker-export-arch.sh amd64

# ARM64 架构  
./docker-export-arch.sh arm64
\`\`\`
EOF

# 显示结果
TOTAL_SIZE=$(du -sh . | cut -f1)

echo ""
echo -e "${GREEN}✅ $ARCH_NAME 架构离线包创建完成！${NC}"
echo "=============================================="
echo -e "${BLUE}📁 包目录: ${YELLOW}$(pwd)${NC}"
echo -e "${BLUE}📦 包大小: ${YELLOW}$TOTAL_SIZE${NC}"
echo -e "${BLUE}🖥️  目标架构: ${YELLOW}$ARCH_NAME${NC}"
echo ""
echo -e "${BLUE}📋 包含文件:${NC}"
ls -lh *.tar *.yml *.sh *.md 2>/dev/null

echo ""
echo -e "${YELLOW}🚀 使用方法:${NC}"
echo "1. 上传到 $ARCH_NAME 架构的服务器"
echo "2. 运行: ./deploy-offline.sh"
echo ""
echo -e "${GREEN}✨ 架构特定离线包已准备就绪！${NC}"