#!/bin/bash

# GhostTrack Web VPS 一键部署脚本
# 适用于 Ubuntu/Debian/CentOS 系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_FRONTEND_PORT=8192
DEFAULT_BACKEND_PORT=8088
DEFAULT_VERSION="latest"
DEPLOY_MODE="dockerhub"  # 默认使用DockerHub镜像

# 显示欢迎信息
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    GhostTrack Web 部署器                     ║"
echo "║              OSINT 工具 - VPS 一键部署脚本                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# 显示帮助信息
show_help() {
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  $0 [选项]"
    echo ""
    echo -e "${YELLOW}选项:${NC}"
    echo "  -h, --help                显示帮助信息"
    echo "  -p, --port FRONTEND_PORT  设置前端端口 (默认: $DEFAULT_FRONTEND_PORT)"
    echo "  -b, --backend-port PORT   设置后端端口 (默认: $DEFAULT_BACKEND_PORT)"
    echo "  -v, --version VERSION     指定版本号 (默认: $DEFAULT_VERSION)"
    echo "  -m, --mode MODE           部署模式: dockerhub|源码 (默认: dockerhub)"
    echo "  --no-install              跳过 Docker 安装检查"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo "  $0                        # 使用默认配置部署(从 DockerHub 拉取)"
    echo "  $0 -p 80 -b 8000          # 自定义端口"
    echo "  $0 -v 1.0.0               # 部署特定版本"
    echo "  $0 -m 源码                # 从源码构建部署"
    echo ""
}

# 解析命令行参数
FRONTEND_PORT=$DEFAULT_FRONTEND_PORT
BACKEND_PORT=$DEFAULT_BACKEND_PORT
VERSION=$DEFAULT_VERSION
SKIP_INSTALL=false
DEPLOY_MODE="dockerhub"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--port)
            FRONTEND_PORT="$2"
            shift 2
            ;;
        -b|--backend-port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -m|--mode)
            DEPLOY_MODE="$2"
            shift 2
            ;;
        --no-install)
            SKIP_INSTALL=true
            shift
            ;;
        *)
            echo -e "${RED}❌ 未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${BLUE}📋 部署配置:${NC}"
echo -e "   🌐 前端端口: ${YELLOW}$FRONTEND_PORT${NC}"
echo -e "   🔧 后端端口: ${YELLOW}$BACKEND_PORT${NC}"
echo -e "   📦 版本: ${YELLOW}$VERSION${NC}"
echo -e "   🚀 部署模式: ${YELLOW}$DEPLOY_MODE${NC}"
echo ""

# 检测系统类型
detect_os() {
    if [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

# 安装 Docker
install_docker() {
    local os_type=$(detect_os)
    
    echo -e "${BLUE}🔧 安装 Docker...${NC}"
    
    case $os_type in
        "debian")
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        "rhel")
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            sudo systemctl start docker
            sudo systemctl enable docker
            ;;
        *)
            echo -e "${RED}❌ 不支持的操作系统，请手动安装 Docker${NC}"
            exit 1
            ;;
    esac
    
    # 将当前用户添加到 docker 组
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}⚠️  请重新登录以使 Docker 权限生效${NC}"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        if [[ "$SKIP_INSTALL" == "true" ]]; then
            echo -e "${RED}❌ Docker 未安装且跳过安装选项${NC}"
            exit 1
        fi
        echo -e "${YELLOW}⚠️  Docker 未安装，开始安装...${NC}"
        install_docker
    else
        echo -e "${GREEN}✅ Docker 已安装${NC}"
    fi
    
    # 检查 Docker 是否运行
    if ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}🔄 启动 Docker 服务...${NC}"
        sudo systemctl start docker
    fi
}

# 创建部署目录
create_deployment() {
    local deploy_dir="ghosttrack-web"
    
    echo -e "${BLUE}📁 创建部署目录...${NC}"
    mkdir -p $deploy_dir
    cd $deploy_dir
    
    # 根据部署模式创建不同的 docker-compose.yml
    if [[ "$DEPLOY_MODE" == "源码" ]]; then
        echo -e "${YELLOW}📦 克隆源代码...${NC}"
        if [[ ! -d ".git" ]]; then
            git clone https://github.com/mintisan/GhostTrackWeb.git .
        fi
        
        # 创建带构建选项的 docker-compose.yml
        cat > docker-compose.yml << EOF
services:
  # 后端API服务
  backend:
    # 优先使用DockerHub镜像，如果不存在则从本地构建
    image: mintisan/ghosttrack-backend:${VERSION}
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ghosttrack-backend
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT}:8000"
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
    # 优先使用DockerHub镜像，如果不存在则从本地构建
    image: mintisan/ghosttrack-frontend:${VERSION}
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ghosttrack-frontend
    restart: unless-stopped
    ports:
      - "${FRONTEND_PORT}:80"
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
    else
        # 仅使用DockerHub镜像的配置
        cat > docker-compose.yml << EOF
services:
  # 后端API服务
  backend:
    image: mintisan/ghosttrack-backend:${VERSION}
    container_name: ghosttrack-backend
    restart: unless-stopped
    ports:
      - "${BACKEND_PORT}:8000"
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
      - "${FRONTEND_PORT}:80"
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
    fi

    echo -e "${GREEN}✅ 部署配置创建完成${NC}"
}

# 启动服务
start_services() {
    echo -e "${BLUE}🚀 拉取镜像并启动服务...${NC}"
    
    # 拉取最新镜像
    docker pull mintisan/ghosttrack-frontend:${VERSION}
    docker pull mintisan/ghosttrack-backend:${VERSION}
    
    # 启动服务
    docker compose up -d
    
    echo -e "${BLUE}⏳ 等待服务启动...${NC}"
    sleep 15
    
    # 检查服务状态
    docker compose ps
}

# 验证部署
verify_deployment() {
    echo -e "${BLUE}🔍 验证部署状态...${NC}"
    
    # 检查后端健康状态
    if curl -f http://localhost:${BACKEND_PORT}/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 后端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 后端服务启动失败${NC}"
        docker compose logs backend
        return 1
    fi
    
    # 检查前端健康状态
    if curl -f http://localhost:${FRONTEND_PORT}/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ 前端服务运行正常${NC}"
    else
        echo -e "${RED}❌ 前端服务启动失败${NC}"
        docker compose logs frontend
        return 1
    fi
}

# 显示部署信息
show_deployment_info() {
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    
    echo ""
    echo -e "${GREEN}🎉 GhostTrack Web 部署成功！${NC}"
    echo ""
    echo -e "${YELLOW}📍 访问地址:${NC}"
    echo -e "   🌐 前端访问: ${BLUE}http://${server_ip}:${FRONTEND_PORT}${NC}"
    echo -e "   🔧 后端API: ${BLUE}http://${server_ip}:${BACKEND_PORT}${NC}"
    echo ""
    echo -e "${YELLOW}🛠️  管理命令:${NC}"
    echo -e "   查看状态: ${BLUE}docker compose ps${NC}"
    echo -e "   查看日志: ${BLUE}docker compose logs -f${NC}"
    echo -e "   停止服务: ${BLUE}docker compose down${NC}"
    echo -e "   重启服务: ${BLUE}docker compose restart${NC}"
    echo -e "   更新服务: ${BLUE}docker compose pull && docker compose up -d${NC}"
    echo ""
    echo -e "${YELLOW}📚 功能模块:${NC}"
    echo -e "   🌍 IP 地址追踪"
    echo -e "   📱 手机号码追踪"
    echo -e "   👤 用户名追踪"
    echo -e "   📍 本机 IP 查询"
    echo ""
}

# 主流程
main() {
    echo -e "${BLUE}🔍 检查系统环境...${NC}"
    check_docker
    
    echo -e "${BLUE}📁 准备部署环境...${NC}"
    create_deployment
    
    echo -e "${BLUE}🚀 启动服务...${NC}"
    start_services
    
    echo -e "${BLUE}✅ 验证部署...${NC}"
    if verify_deployment; then
        show_deployment_info
    else
        echo -e "${RED}❌ 部署验证失败${NC}"
        exit 1
    fi
}

# 运行主流程
main