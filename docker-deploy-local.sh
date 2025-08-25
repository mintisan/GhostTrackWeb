#!/bin/bash

# GhostTrack Web 本地Docker部署脚本
# 前端端口: 8192, 后端端口: 88

set -e

echo "🚀 开始构建 GhostTrack Web Docker 应用..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 停止并清理旧的容器
echo "🛑 停止并清理旧容器..."
docker-compose down --remove-orphans

# 清理旧的镜像（可选）
echo "🧹 清理未使用的镜像..."
docker image prune -f

# 构建并启动服务
echo "🏗️ 构建并启动服务..."
docker-compose up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查服务状态
echo "✅ 检查服务状态..."
docker-compose ps

# 检查服务健康状态
echo "🔍 检查服务健康状态..."
echo "检查后端健康状态..."
for i in {1..10}; do
    if curl -f http://localhost:8088/ >/dev/null 2>&1; then
        echo "✅ 后端服务启动成功!"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ 后端服务启动失败"
        docker-compose logs backend
        exit 1
    fi
    echo "等待后端服务启动... ($i/10)"
    sleep 3
done

echo "检查前端健康状态..."
for i in {1..10}; do
    if curl -f http://localhost:8192/ >/dev/null 2>&1; then
        echo "✅ 前端服务启动成功!"
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ 前端服务启动失败"
        docker-compose logs frontend
        exit 1
    fi
    echo "等待前端服务启动... ($i/10)"
    sleep 3
done

echo ""
echo "🎉 部署完成！"
echo "📍 前端访问地址: http://localhost:8192"
echo "🔧 后端API地址: http://localhost:8088"
echo ""
echo "📊 常用命令:"
echo "  查看服务状态: docker-compose ps"
echo "  查看日志: docker-compose logs -f"
echo "  停止服务: docker-compose down"
echo "  重启服务: docker-compose restart"
echo ""
echo "🔥 GhostTrack Web 已成功在本地Docker环境中部署！"