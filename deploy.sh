#!/bin/bash

# GhostTrack Web 部署脚本
# 适用于Ubuntu/Debian VPS

set -e

echo \"🚀 开始部署 GhostTrack Web 应用...\"

# 更新系统
echo \"📦 更新系统包...\"
sudo apt update && sudo apt upgrade -y

# 安装Docker
if ! command -v docker &> /dev/null; then
    echo \"🐳 安装 Docker...\"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
fi

# 安装Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo \"🔧 安装 Docker Compose...\"
    sudo curl -L \"https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 创建应用目录
APP_DIR=\"/opt/ghosttrack\"
echo \"📁 创建应用目录: $APP_DIR\"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# 进入应用目录
cd $APP_DIR

# 如果存在旧版本，先停止
if [ -f \"docker-compose.yml\" ]; then
    echo \"🛑 停止旧版本...\"
    docker-compose down
fi

# 克隆或更新代码
if [ -d \".git\" ]; then
    echo \"🔄 更新代码...\"
    git pull origin main
else
    echo \"📥 克隆代码...\"
    git clone https://github.com/HunxByts/GhostTrack.git .
fi

# 构建并启动服务
echo \"🏗️ 构建并启动服务...\"
docker-compose up -d --build

# 等待服务启动
echo \"⏳ 等待服务启动...\"
sleep 30

# 检查服务状态
echo \"✅ 检查服务状态...\"
docker-compose ps

# 显示访问信息
echo \"\"
echo \"🎉 部署完成！\"
echo \"📍 前端访问地址: http://$(curl -s ifconfig.me)\"
echo \"🔧 后端API地址: http://$(curl -s ifconfig.me):8000\"
echo \"📊 服务状态: docker-compose ps\"
echo \"📝 查看日志: docker-compose logs -f\"
echo \"\"
echo \"🔥 GhostTrack Web 已成功部署！\"

# 设置防火墙规则（如果需要）
echo \"🛡️ 配置防火墙...\"
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 8000/tcp
    echo \"防火墙规则已添加\"
fi

echo \"✨ 部署脚本执行完成！\"