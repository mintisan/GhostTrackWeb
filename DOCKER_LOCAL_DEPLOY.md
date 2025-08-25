# GhostTrack Docker 本地部署指南

## 快速启动

### 前提条件
- Docker
- Docker Compose

### 端口配置
- **前端**: http://localhost:8192
- **后端API**: http://localhost:8088

### 一键部署
```bash
# 克隆项目
git clone https://github.com/HunxByts/GhostTrack.git
cd GhostTrack

# 运行本地Docker部署脚本
./docker-deploy-local.sh
```

### 手动部署
```bash
# 构建并启动服务
docker-compose up -d --build

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 服务验证
```bash
# 测试后端API
curl http://localhost:8088/

# 测试前端页面
curl http://localhost:8192/
```

## 常用命令

### 服务管理
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 重新构建并启动
docker-compose up -d --build
```

### 日志查看
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f frontend
docker-compose logs -f backend
```

### 清理
```bash
# 停止并删除容器、网络
docker-compose down

# 删除相关镜像
docker rmi ghosttrack-frontend ghosttrack-backend

# 清理未使用的镜像
docker image prune -f
```

## 服务架构

### 前端服务
- **端口**: 8192
- **技术栈**: React + TypeScript + Ant Design
- **Web服务器**: Nginx
- **构建工具**: Vite

### 后端服务
- **端口**: 8088 (容器内部8000)
- **技术栈**: FastAPI + Python 3.11
- **特性**: OSINT工具API，支持IP追踪、手机号追踪、用户名追踪

### 网络配置
- Docker网络: ghosttrack-network
- 前端可通过内部网络访问后端服务
- 自动API代理配置

## 开发调试

### 实时日志监控
```bash
# 监控所有服务日志
docker-compose logs -f

# 只监控前端
docker-compose logs -f frontend

# 只监控后端
docker-compose logs -f backend
```

### 进入容器调试
```bash
# 进入后端容器
docker-compose exec backend bash

# 进入前端容器
docker-compose exec frontend sh
```

## 故障排除

### 端口冲突
如果遇到端口冲突，可以修改 `docker-compose.yml` 中的端口映射：
```yaml
services:
  frontend:
    ports:
      - "你的端口:80"
  backend:
    ports:
      - "你的端口:8000"
```

### 服务无法启动
1. 检查日志：`docker-compose logs service_name`
2. 检查端口占用：`netstat -tlnp | grep 端口号`
3. 重新构建：`docker-compose up -d --build`

### 网络连接问题
1. 确认两个服务都在运行：`docker-compose ps`
2. 检查网络：`docker network ls`
3. 重启服务：`docker-compose restart`

## 注意事项

1. **端口配置**: 已配置避免常见端口冲突
2. **API配置**: 前端自动识别Docker环境并使用正确的API地址
3. **健康检查**: 内置服务健康检查机制
4. **数据持久化**: 当前配置不包含数据持久化，重启容器会丢失数据

## 访问应用

部署成功后，在浏览器中访问：
- **前端界面**: http://localhost:8192
- **后端API文档**: http://localhost:8088/docs

开始使用 GhostTrack 的强大 OSINT 功能！