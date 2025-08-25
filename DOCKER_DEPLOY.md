# GhostTrack Web - Docker 发布与部署指南

## 📦 DockerHub 镜像

GhostTrack Web 提供预构建的 Docker 镜像，可以直接从 DockerHub 拉取使用：

- **前端镜像**: `mintisan/ghosttrack-frontend`
- **后端镜像**: `mintisan/ghosttrack-backend`

## 🚀 快速部署（推荐）

### 方式一：一键 VPS 部署

适用于 Ubuntu/Debian/CentOS 系统：

```bash
# 下载部署脚本
curl -fsSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/deploy-vps.sh -o deploy-vps.sh
chmod +x deploy-vps.sh

# 运行部署（使用默认端口 8192:前端, 8088:后端）
./deploy-vps.sh

# 或者自定义端口
./deploy-vps.sh -p 80 -b 8000
```

### 方式二：Docker Compose 部署

1. 下载 docker-compose 文件：
```bash
curl -fsSL https://raw.githubusercontent.com/mintisan/GhostTrackWeb/main/docker-compose.prod.yml -o docker-compose.yml
```

2. 启动服务：
```bash
docker compose up -d
```

3. 访问应用：
- 前端：http://your-server-ip:8192
- 后端API：http://your-server-ip:8088

### 方式三：手动 Docker 运行

```bash
# 创建网络
docker network create ghosttrack-network

# 启动后端
docker run -d \
  --name ghosttrack-backend \
  --network ghosttrack-network \
  -p 8088:8000 \
  --restart unless-stopped \
  mintisan/ghosttrack-backend:latest

# 启动前端
docker run -d \
  --name ghosttrack-frontend \
  --network ghosttrack-network \
  -p 8192:80 \
  --restart unless-stopped \
  mintisan/ghosttrack-frontend:latest
```

## 🏷️ 版本管理

### 可用标签

- `latest`: 最新稳定版本
- `1.0.0`, `1.1.0` 等: 特定版本号

### 使用特定版本

```bash
# 部署特定版本
docker pull mintisan/ghosttrack-frontend:1.0.0
docker pull mintisan/ghosttrack-backend:1.0.0

# 或者在 VPS 部署脚本中指定版本
./deploy-vps.sh -v 1.0.0
```

## 🔧 管理命令

### 查看服务状态
```bash
docker compose ps
```

### 查看日志
```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f frontend
docker compose logs -f backend
```

### 更新服务
```bash
# 拉取最新镜像并重启
docker compose pull && docker compose up -d
```

### 停止服务
```bash
docker compose down
```

### 重启服务
```bash
docker compose restart
```

## 🛠️ 开发者发布流程

### 准备环境

1. 确保已安装 Docker 和 Docker Compose
2. 拥有 DockerHub 账户并登录：
   ```bash
   docker login
   ```

### 发布新版本

1. 更新版本号（编辑 `package.json`）
2. 运行发布脚本：
   ```bash
   # 完整发布（构建 + 推送）
   ./docker-release.sh
   
   # 仅构建
   ./docker-release.sh --build-only
   
   # 仅推送
   ./docker-release.sh --push-only
   
   # 指定版本
   ./docker-release.sh -v 1.2.0
   ```

### 发布脚本说明

- `docker-build.sh`: 仅构建 Docker 镜像
- `docker-push.sh`: 仅推送镜像到 DockerHub
- `docker-release.sh`: 完整发布流程（构建 + 推送）

## 🌐 访问地址

部署成功后，可以通过以下地址访问：

- **前端应用**: http://your-server-ip:8192
  - 主页: `/`
  - IP 追踪: `/ip-tracker`
  - 手机号追踪: `/phone-tracker`
  - 用户名追踪: `/username-tracker`
  - 本机 IP: `/my-ip`

- **后端 API**: http://your-server-ip:8088
  - 健康检查: `/health`
  - API 文档: `/docs`

## 🔒 安全建议

1. **防火墙配置**: 确保只开放必要的端口
2. **反向代理**: 建议使用 Nginx 作为反向代理并配置 SSL
3. **定期更新**: 定期更新到最新版本以获取安全修复

## 📞 支持

如果在部署过程中遇到问题：

1. 查看容器日志：`docker compose logs -f`
2. 检查端口是否被占用：`netstat -tlnp | grep :8192`
3. 确保防火墙允许相关端口
4. 提交 Issue 到 GitHub 项目页面

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。